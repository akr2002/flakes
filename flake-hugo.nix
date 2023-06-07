{
  description = "A flake for publishing blog posts to https://blog.adityakumar.xyz/";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/23.05";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };
    stdenv.mkDerivation {
        name = "blog";
        buildInputs = [
        pkgs.hugo
        pkgs.rsync
        ];
        src = self;
        buildPhase = "hugo server";
        installPhase = "./deploy.sh";
      };
  };
}
