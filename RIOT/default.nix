{ stdenv, lib, fetchSWH, fetchFromGitHub, git, bash, python3, which, curl, binutils, gcc-arm-embedded, unzip, cacert }:

stdenv.mkDerivation rec {
  pname = "RIOT";
  version = "2021.04-RC3";

  src = fetchSWH {
    swhid = "2d14aee3b8b21563a0900f4ac7e0c8f935a9449b";
    sha256 = "1dzhnn6jqwpd5np24zss6wd7s4malq0fixwxjshm8p973bh5i865";
  };

  patches = [ ./issue_16359.patch ./deter.patch ];

  postPatch = ''
    for x in $(find . -executable -type f); do
      patchShebangs $x;
    done
    sed -i "s/\/usr\/bin\/env //g" makefiles/color.inc.mk
  '';

  BOARDS = [
    "iotlab-m3"
    "iotlab-a8-m3"
  ];

  # In order to fetch dependencies hidden in deep Makefile, we build the hello-world
  # example for the targeted boards
  buildPhase = ''
    OBJCOPY="arm-none-eabi-objcopy";
    for board in ${lib.concatStringsSep " " BOARDS}
    do
        echo "Building $board"
        make -C examples/hello-world/ BOARD=$board
        make clean -C examples/hello-world/ BOARD=$board
    done
    find ./ -wholename "*.git/index" -delete
    find ./ -wholename "*.git/logs/HEAD" -delete
    find ./ -wholename "*.git/logs/refs/remotes/origin/HEAD" -delete
    find ./ -wholename "*.git/logs/refs/heads/master" -delete
    find ./ -wholename "*.git/packed-refs" -delete
    find ./ -wholename "*.git/refs/heads/master" -delete
    find ./ -name ".pkg-state.git-patched.d" -delete
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  buildInputs =
    [
      git
      bash
      python3
      which
      curl
      binutils
      gcc-arm-embedded
      unzip
      cacert
    ];

  meta = with lib; {
    description = "Riot Operating System";
    homepage = "https://github.com/riot-os/riot";
    license = licenses.lgpl2;
    maintainers = with maintainers; [ rgrunbla ];
    platforms = platforms.unix;
  };

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "17ik4bjnar7lzv7c189nnldy426yc6mmwmbzxcj54s5pdas12c6y";
}
