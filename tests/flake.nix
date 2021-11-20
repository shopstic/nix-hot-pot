{
  description = "Tests";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flakeUtils }:
    flakeUtils.lib.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          hotPotLib = import ../lib;
          buildahBuild = pkgs.callPackage hotPotLib.buildahBuild;
        in
        rec {
          packages = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            buildah-build-test = pkgs.callPackage ./buildah-build-test/default.nix {
              inherit buildahBuild;
            };
          };
          defaultPackage = pkgs.runCommand "test-all" {} ''
            echo '${builtins.concatStringsSep "," (pkgs.lib.attrValues packages)}'
            mkdir $out
          '';
        }
      );
}
