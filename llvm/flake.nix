{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
        let
        pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        };
        gccForLibs = pkgs.stdenv.cc.cc;
        in {
        name = "LLVM";
        description = "LLVM-build toolchain";
        devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
        bashInteractive
        python3
        ninja
        cmake
        llvmPackages_17.llvm
        ];
# where to find libgcc
        NIX_LDFLAGS="-L${gccForLibs}/lib/gcc/${pkgs.targetPlatform.config}/${gccForLibs.version}";
# teach clang about C startup file locations
        CFLAGS="-B${gccForLibs}/lib/gcc/${pkgs.targetPlatform.config}/${gccForLibs.version} -B ${pkgs.stdenv.cc.libc}/lib";

        cmakeFlags = [
          "-DGCC_INSTALL_PREFIX=${pkgs.gcc}"
            "-DC_INCLUDE_DIRS=${pkgs.stdenv.cc.libc.dev}/include"
            "-GNinja"
# Debug for debug builds
            "-DCMAKE_BUILD_TYPE=Release"
# inst will be our installation prefix
            "-DCMAKE_INSTALL_PREFIX=../inst"
            "-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON"
# change this to enable the projects you need
            "-DLLVM_ENABLE_PROJECTS=clang"
# enable libcxx* to come into play at runtimes
            "-DLLVM_ENABLE_RUNTIMES=libcxx;libcxxabi"
# this makes llvm only to produce code for the current platform, this saves CPU time, change it to what you need
            "-DLLVM_TARGETS_TO_BUILD=host"
            ];
        };
        });
}
