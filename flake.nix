{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/f06d24a512ca4a470877938a746cd9af410c5c3f";
    fdbPkg.url = "github:shopstic/nix-fdb/21ac866940d56f3016c0978f6ddc61f45d0088d6";
    flakeUtils.url = "github:numtide/flake-utils";
    npmlock2nixPkg = {
      url = "github:nix-community/npmlock2nix/9197bbf397d76059a76310523d45df10d2e4ca81";
      flake = false;
    };
    nix2containerPkg = {
      url = "github:nlewo/nix2container/v1.0.0";
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
              allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
                "redpanda"
              ];
            };
          };
          npmlock2nix = import npmlock2nixPkg {
            inherit pkgs;
            lib = pkgs.lib // {
              warn = _: v: v;
            };
          };
          nix2containerPkgs = nix2containerPkg.packages.${system};
          skopeo-nix2container = nix2containerPkgs.skopeo-nix2container;
          nix2container = nix2containerPkgs.nix2container;
          fdb = fdbPkg.packages.${system}.fdb_7;
          fdbLib = fdb.lib;
          deno_1_30_x = pkgs.callPackage ./pkgs/deno-1.30.x.nix { };
          deno_1_31_x = pkgs.callPackage ./pkgs/deno-1.31.x.nix { };
          deno_1_32_x = pkgs.callPackage ./pkgs/deno-1.32.x.nix { };
          deno_1_33_x = pkgs.callPackage ./pkgs/deno-1.33.x.nix { };
          deno = deno_1_33_x.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 0;
            };
          });

          jdk17Pkg = pkgs.callPackage ./pkgs/jdk17 { };
          aws-batch-routes = pkgs.callPackage ./pkgs/aws-batch-routes { };
          symlink-mirror = pkgs.callPackage ./pkgs/symlink-mirror { };

          intellij-helper = pkgs.callPackage ./lib/deno-app-compile.nix
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
          redpanda = pkgs.callPackage ./pkgs/redpanda.nix { };
          kubesess = pkgs.callPackage ./pkgs/kubesess.nix { };
          graphjin = pkgs.callPackage ./pkgs/graphjin.nix { };
          atlas = pkgs.callPackage ./pkgs/atlas.nix { };
          kwok = pkgs.callPackage ./pkgs/kwok.nix { };
          gitlab-runner = pkgs.callPackage ./pkgs/gitlab-runner { };
          kubernetes-helm = pkgs.callPackage ./pkgs/kubernetes-helm { };
        in
        rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno manifest-tool ] ++ builtins.attrValues {
              inherit skopeo-nix2container redpanda;
              inherit (pkgs)
                awscli2
                parallel
                nodejs
                kubectl
                caddy
                yq-go
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
              oras = pkgs.callPackage ./pkgs/oras.nix { };
              regclient = pkgs.callPackage ./pkgs/regclient.nix { };
              hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
              k9s = pkgs.callPackage ./pkgs/k9s.nix { };
            in
            {
              inherit
                deno deno_1_30_x deno_1_31_x deno_1_32_x deno_1_33_x
                intellij-helper manifest-tool jdk17 jre17 regclient
                skopeo-nix2container oras redpanda hasura-cli 
                kubesess graphjin atlas kwok
                k9s gitlab-runner kubernetes-helm aws-batch-routes symlink-mirror;
              inherit (pkgs) kubectx;
              openapi-ts-gen = pkgs.callPackage ./pkgs/openapi-ts-gen {
                inherit npmlock2nix;
              };
              kysely-codegen = pkgs.callPackage ./pkgs/kysely-codegen {
                nodejs = pkgs.nodejs-18_x;
                inherit npmlock2nix;
              };
              jib-cli = pkgs.callPackage ./pkgs/jib-cli.nix { jre = jre17; };
              mimirtool = pkgs.callPackage ./pkgs/mimirtool.nix { };
              kubeshark = pkgs.callPackage ./pkgs/kubeshark.nix { };
              grpc-health-probe = pkgs.callPackage ./pkgs/grpc-health-probe.nix { };
              gitlab-copy = pkgs.callPackage ./pkgs/gitlab-copy.nix { };
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
                    inherit writeTextFiles nonRootShadowSetup nix2container aws-batch-routes;
                  };
                  image-pvc-autoresizer = pkgs.callPackage ./images/pvc-autoresizer {
                    inherit nix2container;
                  };
                  image-github-runner-nix = pkgs.callPackage ./images/github-runner-nix {
                    inherit nix2container writeTextFiles nonRootShadowSetup;
                    nix = pkgs.nixVersions.nix_2_15;
                  };
                  image-gitlab-runner-nix = pkgs.callPackage ./images/gitlab-runner-nix {
                    inherit nix2container writeTextFiles nonRootShadowSetup gitlab-runner;
                    nix = pkgs.nixVersions.nix_2_15;
                  };
                  image-kubectl = pkgs.callPackage ./images/kubectl {
                    inherit nix2container;
                  };
                  image-net-snmp = pkgs.callPackage ./images/net-snmp {
                    inherit nix2container;
                  };
                  image-snmp-notifier = pkgs.callPackage ./images/snmp-notifier {
                    inherit nix2container;
                  };
                  image-openvpn = pkgs.callPackage ./images/openvpn {
                    inherit nix2container;
                  };
                  image-openconnect = pkgs.callPackage ./images/openconnect {
                    inherit nix2container;
                  };
                  image-caddy = pkgs.callPackage ./images/caddy {
                    inherit nix2container nonRootShadowSetup;
                  };
                  image-kube-scheduler = pkgs.callPackage ./images/kube-scheduler {
                    inherit nix2container;
                  };
                  image-hasura-cli = pkgs.callPackage ./images/hasura-cli {
                    inherit nix2container hasura-cli;
                  };
                  image-rpk = pkgs.callPackage ./images/rpk {
                    inherit nix2container nonRootShadowSetup redpanda;
                  };
                  image-kwok = pkgs.callPackage ./images/kwok {
                    inherit nix2container kwok;
                  };
                }; in
              (images // ({
                all-images = pkgs.linkFarmFromDrvs "all-images" (pkgs.lib.attrValues images);
              }))
            );
          defaultPackage = pkgs.linkFarmFromDrvs "nix-hot-pot"
            (pkgs.lib.unique (builtins.attrValues (pkgs.lib.filterAttrs (n: _: (!(pkgs.lib.hasPrefix "image-" n) && n != "all-images")) packages)));
        }
      ) // {
      lib = (import ./lib);
    };
}
