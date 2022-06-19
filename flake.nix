{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/11e805f9935f6ab4b049351ac14f2d1aa93cf1d3";
    fdb.url = "github:shopstic/nix-fdb/7.1.11";
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
          fdbLib = fdb.packages.${system}.fdb_7.lib;
          deno_1_13_x = pkgs.callPackage ./pkgs/deno-1.13.x.nix { };
          deno_1_16_x = pkgs.callPackage ./pkgs/deno-1.16.x.nix { };
          deno_1_17_x = pkgs.callPackage ./pkgs/deno-1.17.x.nix { };
          deno_1_18_x = pkgs.callPackage ./pkgs/deno-1.18.x.nix { };
          deno_1_19_x = pkgs.callPackage ./pkgs/deno-1.19.x.nix { };
          deno_1_20_x = pkgs.callPackage ./pkgs/deno-1.20.x.nix { };
          deno_1_21_x = pkgs.callPackage ./pkgs/deno-1.21.x.nix { };
          deno_1_22_x = pkgs.callPackage ./pkgs/deno-1.22.x.nix { };
          deno = deno_1_22_x.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 0;
            };
          });

          jdk17Pkg = pkgs.callPackage ./pkgs/jdk17 { };

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
          buildahBuild = pkgs.callPackage ./lib/buildah-build.nix;
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
          packages =
            let
              jdk17 = jdk17Pkg.jdk.overrideAttrs (oldAttrs: {
                meta = oldAttrs.meta // {
                  priority = 0;
                };
              });
              jre17 = jdk17Pkg.jre;
            in
            {
              inherit
                deno deno_1_13_x deno_1_16_x deno_1_17_x deno_1_18_x deno_1_19_x deno_1_20_x deno_1_21_x deno_1_22_x
                intellij-helper manifest-tool jdk17 jre17;
              faq = pkgs.callPackage ./pkgs/faq.nix { };
              hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
              packer = pkgs.callPackage ./pkgs/packer.nix { };
              regclient = pkgs.callPackage ./pkgs/regclient.nix { };
              openapi-ts = pkgs.callPackage ./pkgs/openapi-ts {
                inherit npmlock2nix;
              };
              jib-cli = pkgs.callPackage ./pkgs/jib-cli.nix { jre = jre17; };
              awscli2 = pkgs.awscli2.overrideAttrs (_: attrs: rec {
                name = "${attrs.pname}-${version}";
                version = "2.7.6";
                src = pkgs.fetchFromGitHub {
                  owner = "aws";
                  repo = "aws-cli";
                  rev = version;
                  sha256 = "sha256-TBA0PJzahANmg2It3tNxdkpcNG5SlyuqDBvE1/Afr/0=";
                };
              });
              tfmigrate = pkgs.callPackage ./pkgs/tfmigrate.nix { };
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
                jre = jre17;
                inherit fdbLib;
              };
              image-jre-fdb-app = pkgs.callPackage ./images/jre-fdb-app {
                jre = jre17;
                inherit fdbLib buildahBuild;
              };
              image-dind = pkgs.callPackage ./images/dind { };
              image-strimzi-debezium-postgresql = pkgs.callPackage ./images/strimzi-debezium-postgresql {
                inherit buildahBuild;
              };
              image-confluent-community = pkgs.callPackage ./images/confluent-community {
                inherit buildahBuild;
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
