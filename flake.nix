{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";
    fdb.url = "github:shopstic/nix-fdb/6.3.23";
    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npmlock2nixPkg = {
      url = "github:nix-community/npmlock2nix/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flakeUtils, fdb, npmlock2nixPkg }:
    flakeUtils.lib.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          npmlock2nix = import npmlock2nixPkg { inherit pkgs; };
          fdbLib = fdb.defaultPackage.${system}.lib;
          deno_1_13_x = pkgs.callPackage ./pkgs/deno-1.13.x.nix { };
          deno_1_16_x = pkgs.callPackage ./pkgs/deno-1.16.x.nix { };
          deno_1_17_x = pkgs.callPackage ./pkgs/deno-1.17.x.nix { };
          deno_1_18_x = pkgs.callPackage ./pkgs/deno-1.18.x.nix { };
          deno_1_19_x = pkgs.callPackage ./pkgs/deno-1.19.x.nix { };
          deno_1_20_x = pkgs.callPackage ./pkgs/deno-1.20.x.nix { };
          deno = deno_1_20_x.overrideAttrs (oldAttrs: {
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
              "deno.path" = deno + "/bin/deno";
              "deno.suggest.imports.hosts" = {
                "https://deno.land" = false;
              };
              "editor.tabSize" = 2;
              "shellcheck.executablePath" = pkgs.shellcheck + "/bin/shellcheck";
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
          manifest-tool = pkgs.callPackage ./pkgs/manifest-tool.nix { };
        in
        rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno manifest-tool ] ++ builtins.attrValues {
              inherit (pkgs)
                awscli2
                parallel
                skopeo
                nodejs
                ;
            };
            shellHook = ''
              echo 'will cite' | parallel --citation >/dev/null 2>&1
              mkdir -p ./.vscode
              cat ${vscodeSettings} > ./.vscode/settings.json
            '';
          };
          packages = {
            inherit deno deno_1_13_x deno_1_16_x deno_1_17_x deno_1_18_x deno_1_19_x deno_1_20_x intellij-helper manifest-tool;
            faq = pkgs.callPackage ./pkgs/faq.nix { };
            hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
            packer = pkgs.callPackage ./pkgs/packer.nix { };
            regclient = import ./pkgs/regclient.nix { inherit pkgs; };
            openapi-ts = pkgs.callPackage ./pkgs/openapi-ts {
              inherit npmlock2nix;
            };
          } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
            image-bin-dumb-init = pkgs.callPackage ./images/bin-dumb-init { };
            image-bin-docker-client = pkgs.callPackage ./images/bin-docker-client { };
            image-lib-fdb = pkgs.callPackage ./images/lib-fdb {
              inherit fdbLib;
            };
            image-lib-jmx-prometheus-javaagent = pkgs.callPackage ./images/lib-jmx-prometheus-javaagent { };
            image-lib-yourkit-agent = pkgs.callPackage ./images/lib-yourkit-agent { };
            image-netcat = pkgs.callPackage ./images/netcat { };
            image-jre-fdb = pkgs.callPackage ./images/jre-fdb {
              jre = pkgs.jdk11_headless;
              inherit fdbLib;
            };
          };
          defaultPackage = pkgs.buildEnv {
            name = "nix-hot-pot";
            paths = builtins.attrValues (pkgs.lib.filterAttrs (n: _: !(pkgs.lib.hasPrefix "image-" n)) packages);
          };
        }
      ) // {
      lib = import ./lib;
    };
}
