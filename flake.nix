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
          deno_1_13_x = pkgs.callPackage ./pkgs/deno-1.13.x.nix { };
          deno_1_16_x = pkgs.callPackage ./pkgs/deno-1.16.x.nix { };
          deno_1_17_x = pkgs.callPackage ./pkgs/deno-1.17.x.nix { };
          deno = deno_1_17_x.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 0;
            };
          });

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
          vscodeSettings = pkgs.writeTextFile {
            name = "vscode-settings.json";
            text = builtins.toJSON {
              "deno.enable" = true;
              "deno.lint" = true;
              "deno.unstable" = true;
              "deno.path" = deno_1_16_x + "/bin/deno";
              "deno.suggest.imports.hosts" = {
                "https://deno.land" = false;
              };
              "editor.tabSize" = 2;
              "[typescript]" = {
                "editor.defaultFormatter" = "denoland.vscode-deno";
                "editor.formatOnSave" = true;
              };
              "yaml.schemaStore.enable" = true;
              "yaml.schemas" = {
                "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.yaml";
                "https://json.schemastore.org/github-action.json" = "*/action.yaml";
              };
              "nix.enableLanguageServer" = true;
              "nix.formatterPath" = pkgs.nixpkgs-fmt + "/bin/nixpkgs-fmt";
              "nix.serverPath" = pkgs.rnix-lsp + "/bin/rnix-lsp";
            };
          };
        in
        rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno ];
            shellHook = ''
              mkdir -p ./.vscode
              cat ${vscodeSettings} > ./.vscode/settings.json
            '';
          };
          packages = {
            inherit deno deno_1_13_x deno_1_16_x deno_1_17_x intellij-helper;
            manifest-tool = pkgs.callPackage ./pkgs/manifest-tool.nix { };
            faq = pkgs.callPackage ./pkgs/faq.nix { };
            hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
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
