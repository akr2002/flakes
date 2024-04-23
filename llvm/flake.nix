{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      };
      gccForLibs = pkgs.stdenv.cc.cc;
    in rec {
      packages = {
        llvm-toolchain = pkgs.llvmPackages_18.libcxxStdenv.mkDerivation rec {
          name = "LLVM";
          description = "LLVM-build toolchain";
          buildInputs = with pkgs; [
            bashInteractive
            git
            python3
            ninja
            cmake
            llvmPackages_18.llvm
            llvmPackages_18.stdenv
          ];

          src = pkgs.fetchFromGitHub {
            owner = "llvm";
            repo = "llvm-project";
            rev = "58d4470fa49443da1477a7d2e43685e91bbd6630";
            hash = "sha256-cLL8s5XTojhR5DfOUc+7N8Xl9zszzeNW7UDroZBvIFk=";
          };
          # where to find libgcc
          NIX_LDFLAGS = "-L${gccForLibs}/lib/gcc/${pkgs.targetPlatform.config}/${gccForLibs.version}";
          # teach clang about C startup file locations
          CFLAGS = "-B${gccForLibs}/lib/gcc/${pkgs.targetPlatform.config}/${gccForLibs.version} -B ${pkgs.stdenv.cc.libc}/lib";

          cmakeFlags = [
            "-S llvm"
            "-Dgcc-install-dir=${pkgs.gcc}"
            "-DC_INCLUDE_DIRS=${pkgs.stdenv.cc.libc.dev}/include"
            "-GNinja"
            # Debug for debug builds
            "-DCMAKE_BUILD_TYPE=Release"
            # inst will be our installation prefix
            "-DCMAKE_INSTALL_PREFIX=inst"
            #"-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON"
            # change this to enable the projects you need
            "-DLLVM_ENABLE_PROJECTS=clang"
            # enable libcxx* to come into play at runtimes
            #"-DLLVM_ENABLE_RUNTIMES=libcxx;libcxxabi;libunwind"
            # this makes llvm only to produce code for the current platform, this saves CPU time, change it to what you need
            "-DLLVM_TARGETS_TO_BUILD=host"
          ];

          dontConfigure = true;

          buildPhase = ''
            mkdir build
            cd build
            cmake $cmakeFlags $src/llvm
            ninja -j5 -v
          '';
          installPhase = ''
            runHook preInstall
            mkdir -pv $out
            ninja install
            cp -rv inst/* $out
            runHook postInstall
          '';
          devShell =
            pkgs.mkShell {
            };
        };
      };
      defaultPackage = packages.llvm-toolchain;
    });
}
