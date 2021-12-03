{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";
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
          deno = pkgs.callPackage ./pkgs/deno.nix { };
          deno_1_13_x = pkgs.callPackage ./pkgs/deno-1.13.x.nix { };

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
            inherit deno deno_1_13_x intellij-helper;
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
