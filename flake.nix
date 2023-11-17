{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.c_formatter_42_src.url = "github:dawnbeen/c_formatter_42";
  inputs.c_formatter_42_src.flake = false;

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    c_formatter_42_src,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        src_patched = pkgs.stdenv.mkDerivation {
          name = "c_formatter_42-patched";
          src = c_formatter_42_src;
          #patch = ./rename-binary.patch;
          installPhase = ''
            mkdir -p $out/c_formatter_42/{data,formatters}
            cp $src/setup.{py,cfg} $src/LICENSE $src/README.md $out
            cp $src/c_formatter_42/*.py $out/c_formatter_42
            cp $src/c_formatter_42/data/*.py $out/c_formatter_42/data
            cp $src/c_formatter_42/data/.clang-format $out/c_formatter_42/data
            cp $src/c_formatter_42/formatters/*.py $out/c_formatter_42/formatters
            ln -s ${pkgs.writeShellScript "clang-format-linux" 
            '' ${pkgs.clang-tools}/bin/clang-format "$@" ''
            } $out/c_formatter_42/data/clang-format-linux
            ${pkgs.tree}/bin/tree $out
          '';
        };
        c_formatter_42_drv = pkgs.python311Packages.buildPythonApplication {
          pname = "c_formatter_42";
          version = "1.0";
          src = src_patched;
          buildInputs = [pkgs.clang-tools];
        };
      in {
        packages = rec {
          c_formatter_42 = default;
          default = c_formatter_42_drv;
        };
        apps = rec {
          c_formatter_42 = flake-utils.lib.mkApp {drv = self.packages.${system}.c_formatter_42;};
          default = c_formatter_42;
        };
      }
    );
}
