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
        c_formatter_42_drv = pkgs.python311Packages.buildPythonApplication {
          pname = "c_formatter_42";
          version = "1.0";
          src = c_formatter_42_src;
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
