
{
  description = "A build environment for C programs";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/master"; };

  outputs = { self, nixpkgs }: 
    let 
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
    in {
      devShell.x86_64-linux = pkgs.llvmPackages_16.libcxxStdenv.mkDerivation {
        name = "A build environment for C programs";
        buildInputs = [
          pkgs.clang_16
          pkgs.clang-tools
          pkgs.clang-analyzer
          pkgs.lldb_16
          pkgs.llvmPackages_16.stdenv
          pkgs.llvmPackages_16.libcxxStdenv
          pkgs.llvmPackages_16.libcxxClang
          pkgs.llvmPackages_16.compiler-rt
          pkgs.llvmPackages_16.compiler-rt-libc
          pkgs.llvmPackages_16.bintools
          pkgs.llvmPackages_16.clangUseLLVM
          pkgs.llvmPackages_16.libcxxabi
          pkgs.llvmPackages_16.libcxx
          pkgs.llvmPackages_16.libllvm
          pkgs.llvmPackages_16.lld
          pkgs.llvmPackages_16.bintools
        ];
        shellHook = ''
          echo "Usage: cc -o bin source.c"
          export C_SANITIZE_FLAGS='-fsanitize=address -fsanitize=leak -fsanitize=undefined -fsanitize=bounds -fsanitize=float-divide-by-zero -fsanitize=integer-divide-by-zero -fsanitize=nonnull-attribute -fsanitize=null -fsanitize=pointer-overflow -fsanitize=integer -fno-omit-frame-pointer'
          export C_WARNING_FLAGS='-Weverything -Wno-c++98-compat'
          alias cc='clang -O1 -std=c17 -stdlib=libc++ $(echo $C_SANITIZE_FLAGS $C_WARNING_FLAGS) -g'
        '';
      };
    };
}

