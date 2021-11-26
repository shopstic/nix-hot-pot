{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/29830319abf5a925921885974faae5509312b940";
    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flakeUtils }:
    flakeUtils.lib.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          deno = pkgs.callPackage ./pkgs/deno.nix { };
          intellij-helper = pkgs.callPackage ./lib/deno-app-build.nix
            {
              inherit deno;
              name = "intellij-helper";
              src = builtins.path
                {
                  path = ./pkgs/intellij-helper;
                  name = "intellij-helper-src";
                  filter = with pkgs.lib; (path: /* type */_:
                    hasInfix "/src" path ||
                    hasSuffix "/lock.json" path
                  );
                };
              appSrcPath = "./src/intellij-helper.ts";
            };
        in
        rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno ];
          };
          packages = {
            inherit deno intellij-helper;
            manifest-tool = pkgs.callPackage ./pkgs/manifest-tool.nix { };
            faq = pkgs.callPackage ./pkgs/faq.nix { };
          };
          defaultPackage = pkgs.buildEnv {
            name = "nix-hot-pot";
            paths = builtins.attrValues packages;
          };
        }
      ) // {
      lib = import ./lib;
    };
}
