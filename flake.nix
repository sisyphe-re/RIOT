{
  description = "A flake for building RIOT OS";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.09;
  inputs.fetchSWH.url = github:sisyphe-re/fetchSWH;

  outputs = { self, nixpkgs, fetchSWH }: {
    packages.x86_64-linux.RIOT =
      with import nixpkgs { system = "x86_64-linux"; };
      callPackage ./RIOT { fetchSWH = fetchSWH.lib.fetchSWH; };
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.RIOT;
  };
}
