{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
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
    flakeUtils.lib.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              permittedInsecurePackages = [
                "dhcp-4.4.3"
              ];
              allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
                "zerotierone"
              ];
            };
          };
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
          deno_1_23_x = pkgs.callPackage ./pkgs/deno-1.23.x.nix { };
          deno_1_24_x = pkgs.callPackage ./pkgs/deno-1.24.x.nix { };
          deno = deno_1_24_x.overrideAttrs (oldAttrs: {
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
                kubectl
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
              awscli2 = pkgs.awscli2.overrideAttrs (_: attrs: rec {
                name = "${attrs.pname}-${version}";
                version = "2.7.19";
                src = pkgs.fetchFromGitHub {
                  owner = "aws";
                  repo = "aws-cli";
                  rev = version;
                  sha256 = "sha256-kVqs6gh4r0kBwlDll0jiE7d0aKMLlYFcPsqbtCa5uBc=";
                };
              });
            in
            {
              inherit
                deno deno_1_13_x deno_1_16_x deno_1_17_x deno_1_18_x deno_1_19_x deno_1_20_x deno_1_21_x deno_1_22_x deno_1_23_x deno_1_24_x
                intellij-helper manifest-tool jdk17 jre17 awscli2;
              faq = pkgs.callPackage ./pkgs/faq.nix { };
              hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
              packer = pkgs.callPackage ./pkgs/packer.nix { };
              regclient = pkgs.callPackage ./pkgs/regclient.nix { };
              openapi-ts = pkgs.callPackage ./pkgs/openapi-ts {
                inherit npmlock2nix;
              };
              jib-cli = pkgs.callPackage ./pkgs/jib-cli.nix { jre = jre17; };
              tfmigrate = pkgs.callPackage ./pkgs/tfmigrate.nix { };
              mimirtool = pkgs.callPackage ./pkgs/mimirtool.nix { };
            } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux rec {
              image-bin-dumb-init = pkgs.callPackage ./images/bin-dumb-init { };
              image-bin-kubectl = pkgs.callPackage ./images/bin-kubectl { };
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
              image-pod-gateway = pkgs.callPackage ./images/pod-gateway {
                inherit buildahBuild;
                dhcp = pkgs.dhcp.override {
                  withClient = true;
                };
              };
              image-tailscale-router-init = pkgs.callPackage ./images/tailscale-router-init {
                inherit buildahBuild awscli2;
              };
              image-actions-runner-dind-nix = pkgs.callPackage ./images/actions-runner-dind-nix {
                inherit buildahBuild;
              };
              image-gh-token = pkgs.callPackage ./images/gh-token { };
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
