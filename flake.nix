{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    fdbPkg.url = "github:shopstic/nix-fdb/7.1.11";
    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npmlock2nixPkg = {
      url = "github:nix-community/npmlock2nix/master";
      flake = false;
    };
    nix2containerPkg = {
      url = "github:shopstic/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flakeUtils, fdbPkg, npmlock2nixPkg, nix2containerPkg }:
    flakeUtils.lib.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              # permittedInsecurePackages = [
              #   "dhcp-4.4.3"
              # ];
              # allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
              #   "zerotierone"
              # ];
            };
          };
          npmlock2nix = import npmlock2nixPkg { inherit pkgs; };
          nix2containerPkgs = nix2containerPkg.packages.${system};
          nix2container = nix2containerPkgs.nix2container;
          skopeo-nix2container = nix2containerPkgs.skopeo-nix2container;
          nix2containerUtil = nix2containerPkgs.nix2containerUtil;
          fdb = fdbPkg.packages.${system}.fdb_7;
          fdbLib = fdb.lib;
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
          writeTextFiles = pkgs.callPackage ./lib/write-text-files.nix { };
          nonRootShadowSetup = pkgs.callPackage ./lib/non-root-shadow-setup.nix { inherit writeTextFiles; };
        in
        rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno manifest-tool ] ++ builtins.attrValues {
              inherit skopeo-nix2container;
              inherit (pkgs)
                awscli2
                parallel
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
              gh-runner-token = pkgs.callPackage ./pkgs/gh-runner-token.nix { };
              karpenter = pkgs.callPackage ./pkgs/karpenter.nix { };
            in
            {
              inherit
                deno deno_1_13_x deno_1_16_x deno_1_17_x deno_1_18_x deno_1_19_x deno_1_20_x deno_1_21_x deno_1_22_x deno_1_23_x deno_1_24_x
                intellij-helper manifest-tool jdk17 jre17 awscli2 gh-runner-token
                skopeo-nix2container nix2containerUtil
                karpenter;
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
            } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (
              let
                images = {
                  image-bin-docker-client = pkgs.callPackage ./images/bin-docker-client { inherit nix2container; };
                  image-lib-fdb = pkgs.callPackage ./images/lib-fdb {
                    inherit fdb nix2container;
                  };
                  image-lib-jmx-prometheus-javaagent = pkgs.callPackage ./images/lib-jmx-prometheus-javaagent { inherit nix2container; };
                  image-lib-yourkit-agent = pkgs.callPackage ./images/lib-yourkit-agent { inherit nix2container; };
                  image-netcat = pkgs.callPackage ./images/netcat { inherit nix2container; };
                  image-jre-fdb-test-base = pkgs.callPackage ./images/jre-fdb-test-base {
                    jre = jre17;
                    inherit fdb nix2container nonRootShadowSetup;
                  };
                  image-jre-fdb-app = pkgs.callPackage ./images/jre-fdb-app {
                    jre = jre17;
                    inherit fdb nix2container nonRootShadowSetup;
                  };
                  image-confluent-community = pkgs.callPackage ./images/confluent-community {
                    inherit nix2container;
                  };
                  image-tailscale-router-init = pkgs.callPackage ./images/tailscale-router-init {
                    inherit writeTextFiles nonRootShadowSetup nix2container awscli2;
                  };
                  image-karpenter-controller = pkgs.callPackage ./images/karpenter-controller {
                    inherit karpenter nix2container;
                  };
                  image-karpenter-webhook = pkgs.callPackage ./images/karpenter-webhook {
                    inherit karpenter nix2container;
                  };
                  image-pvc-autoresizer = pkgs.callPackage ./images/pvc-autoresizer {
                    inherit nix2container;
                  };
                  image-github-runner-nix = pkgs.callPackage ./images/github-runner-nix {
                    inherit nix2container writeTextFiles nonRootShadowSetup;
                  };
                }; in
              (images // ({
                all-images = pkgs.linkFarmFromDrvs "all-images" (pkgs.lib.attrValues images);
              }))
            );
          defaultPackage = pkgs.buildEnv {
            name = "nix-hot-pot";
            paths = builtins.attrValues (pkgs.lib.filterAttrs (n: _: (!(pkgs.lib.hasPrefix "image-" n) && n != "all-images")) packages);
          };
        }
      ) // {
      lib = (import ./lib);
    };
}
