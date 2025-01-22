{
  description = "Misc Nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    fdbPkg.url = "github:shopstic/nix-fdb/7.1.61";
    flakeUtils.url = "github:numtide/flake-utils";
    npmlock2nixPkg = {
      url = "github:nix-community/npmlock2nix/9197bbf397d76059a76310523d45df10d2e4ca81";
      flake = false;
    };
    nix2containerPkg = {
      url = "github:nlewo/nix2container/5fb215a1564baa74ce04ad7f903d94ad6617e17a";
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
              allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
                "redpanda"
                "terraform"
              ];
            };
            overlays = [
              (self: super: {
                nodejs-16_x = super.nodejs-18_x;
              })
            ];
          };
          npmlock2nix = import npmlock2nixPkg {
            inherit pkgs;
            lib = pkgs.lib // {
              warn = _: v: v;
            };
          };
          nix2containerPkgs = nix2containerPkg.packages.${system};
          skopeo-nix2container = nix2containerPkgs.skopeo-nix2container.overrideAttrs (oldAttrs: rec {
            version = "1.16.1";
            src = pkgs.fetchFromGitHub {
              rev = "v${version}";
              owner = "containers";
              repo = "skopeo";
              hash = "sha256-RsFfShru4ujB+x0hju8Xju43JJk/+PAevIPjjDC5YbQ=";
            };
          });
          nix2container = nix2containerPkgs.nix2container;
          fdb = fdbPkg.packages.${system}.fdb_7;
          deno_1_46_x = pkgs.callPackage ./pkgs/deno-1.46.x.nix
            {
              setFuture = true;
            };
          deno_2_0_x = pkgs.callPackage ./pkgs/deno-2.0.x.nix { };
          deno_2_1_x = pkgs.callPackage ./pkgs/deno-2.1.x.nix { };
          denort_1_46_x = pkgs.callPackage ./pkgs/denort-1.46.x.nix { };
          denort_2_0_x = pkgs.callPackage ./pkgs/denort-2.0.x.nix { };
          denort_2_1_x = pkgs.callPackage ./pkgs/denort-2.1.x.nix { };
          deno = deno_2_1_x.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 0;
            };
          });
          denort = denort_2_1_x.overrideAttrs (oldAttrs: {
            meta = oldAttrs.meta // {
              priority = 0;
            };
          });
          jdk17Pkg = pkgs.callPackage ./pkgs/jdk17 { };
          aws-batch-routes = pkgs.callPackage ./pkgs/aws-batch-routes { };
          pcap-ws = pkgs.callPackage ./pkgs/pcap-ws { };
          ng-server = pkgs.callPackage ./pkgs/ng-server { };
          symlink-mirror = pkgs.callPackage ./pkgs/symlink-mirror { };
          deno-app-transpile = pkgs.callPackage ./pkgs/deno-app/transpile {
            deno-vendor = deno_1_46_x;
            inherit deno denort;
          };
          deno-gen-cache-entry = pkgs.callPackage ./pkgs/deno-app/gen_cache_entry {
            inherit deno denort;
          };
          intellij-helper = pkgs.callPackage ./pkgs/intellij-helper {
            inherit deno denort;
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
              "nix.serverPath" = pkgs.nil + "/bin/nil";
              "nix.serverSettings" = {
                "nil" = {
                  "formatting" = {
                    "command" = [ "nixpkgs-fmt" ];
                  };
                };
              };
            };
          };
          manifest-tool = pkgs.callPackage ./pkgs/manifest-tool.nix { };
          writeTextFiles = pkgs.callPackage ./lib/write-text-files.nix { };
          nonRootShadowSetup = pkgs.callPackage ./lib/non-root-shadow-setup.nix { inherit writeTextFiles; };
          redpanda = pkgs.callPackage ./pkgs/redpanda.nix { };
          kubesess = pkgs.callPackage ./pkgs/kubesess.nix { };
          kubernetes-helm = pkgs.callPackage ./pkgs/kubernetes-helm { };
          kubeshark = pkgs.callPackage ./pkgs/kubeshark.nix { };
          dive = pkgs.callPackage ./pkgs/dive.nix { };
          gitlab-copy = pkgs.callPackage ./pkgs/gitlab-copy.nix { };
          docker-credential-helpers = pkgs.callPackage ./pkgs/docker-credential-helpers.nix { };
          typescript-eslint = pkgs.callPackage ./pkgs/typescript-eslint {
            inherit npmlock2nix;
            nodejs = pkgs.nodejs_22;
          };
        in
        (rec {
          devShell = pkgs.mkShellNoCC {
            buildInputs = [ deno deno_1_46_x manifest-tool ] ++ builtins.attrValues {
              inherit
                skopeo-nix2container redpanda kubeshark gitlab-copy;
              inherit (pkgs)
                awscli2
                parallel
                kubectl
                yq-go
                fzf
                nodejs_22
                ;
            };
            shellHook = ''
              echo 'will cite' | parallel --citation >/dev/null 2>&1
              mkdir -p ./.vscode
              # vscode settings
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
              regclient = pkgs.callPackage ./pkgs/regclient.nix { };
              hasura-cli = pkgs.callPackage ./pkgs/hasura-cli.nix { };
              k9s = pkgs.callPackage ./pkgs/k9s.nix { };
            in
            {
              inherit
                deno denort
                denort_1_46_x deno_1_46_x
                denort_2_0_x deno_2_0_x
                denort_2_1_x deno_2_1_x
                intellij-helper manifest-tool jdk17 jre17 regclient
                skopeo-nix2container redpanda hasura-cli
                kubesess kubeshark
                k9s kubernetes-helm
                dive gitlab-copy docker-credential-helpers
                aws-batch-routes symlink-mirror pcap-ws ng-server
                deno-app-transpile
                deno-gen-cache-entry
                typescript-eslint
                ;
              inherit (pkgs) kubectx terraform;
              openapi-ts-gen = pkgs.callPackage ./pkgs/openapi-ts-gen {
                inherit npmlock2nix;
              };
              jib-cli = pkgs.callPackage ./pkgs/jib-cli.nix { jre = jre17; };
              grpc-health-probe = pkgs.callPackage ./pkgs/grpc-health-probe.nix { };
              pg-schema-diff = pkgs.callPackage ./pkgs/pg-schema-diff.nix { };
              libpq = pkgs.callPackage ./pkgs/libpq.nix { };
              libsqlite = pkgs.callPackage ./pkgs/libsqlite.nix {
                # Temporary until nixpkgs catches up to sqlite 3.46.1
                sqlite = pkgs.sqlite.overrideAttrs (oldAttrs: {
                  version = "3.46.1";
                  src = pkgs.fetchurl {
                    url = "https://www.sqlite.org/2024/sqlite-autoconf-3460100.tar.gz";
                    hash = "sha256-Z9P+bSaObq3crjcn/OWPzI6cU4ab3Qegxh443fKWUHE=";
                  };
                });
              };
              libpq_17 = pkgs.callPackage ./pkgs/libpq.nix { postgresql = pkgs.postgresql_17; };
              libpq_16 = pkgs.callPackage ./pkgs/libpq.nix { postgresql = pkgs.postgresql_16; };
              libgpgme = pkgs.callPackage ./pkgs/libgpgme.nix { };
              librnp = pkgs.callPackage ./pkgs/librnp.nix { };
              libevent-core = pkgs.callPackage ./pkgs/libevent-core.nix { };
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
                    jre = pkgs.temurin-jre-bin-21;
                    inherit fdb nix2container nonRootShadowSetup;
                  };
                  image-jre-fdb-app = pkgs.callPackage ./images/jre-fdb-app {
                    jre = pkgs.temurin-jre-bin-21;
                    inherit fdb nix2container nonRootShadowSetup;
                  };
                  image-confluent-community = pkgs.callPackage ./images/confluent-community {
                    inherit nix2container nonRootShadowSetup jre17;
                  };
                  image-tailscale-router-init = pkgs.callPackage ./images/tailscale-router-init {
                    inherit writeTextFiles nonRootShadowSetup nix2container aws-batch-routes;
                  };
                  image-pvc-autoresizer = pkgs.callPackage ./images/pvc-autoresizer {
                    inherit nix2container;
                  };
                  image-github-runner-nix = pkgs.callPackage ./images/github-runner-nix {
                    inherit nix2container writeTextFiles nonRootShadowSetup;
                  };
                  image-gitlab-runner-nix = pkgs.callPackage ./images/gitlab-runner-nix {
                    inherit nix2container writeTextFiles nonRootShadowSetup;
                  };
                  image-remote-dev = pkgs.callPackage ./images/remote-dev {
                    inherit nix2container writeTextFiles nonRootShadowSetup;
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
                  image-pcap-ws = pkgs.callPackage ./images/pcap-ws {
                    inherit nix2container pcap-ws;
                  };
                  image-ng-server = pkgs.callPackage ./images/ng-server {
                    inherit nix2container ng-server nonRootShadowSetup;
                  };
                };
              in
              (images // ({
                all-images = pkgs.linkFarmFromDrvs "all-images" (pkgs.lib.attrValues images);
              }))
            );
          defaultPackage = pkgs.linkFarmFromDrvs "nix-hot-pot"
            (pkgs.lib.unique (builtins.attrValues (pkgs.lib.filterAttrs (n: _: (!(pkgs.lib.hasPrefix "image-" n) && n != "all-images")) packages)));
        }) // {
          lib =
            let
              inherit (pkgs.lib)
                callPackageWith
                ;
            in
            rec {
              denoAppTranspile = callPackageWith
                (pkgs // {
                  deno-vendor = deno_1_46_x;
                  inherit deno deno-app-transpile;
                })
                ./lib/deno-app-transpile.nix;
              denoAppCache = callPackageWith
                (pkgs // {
                  inherit deno;
                })
                ./lib/deno-app-cache.nix;
              denoAppCacheEntry = callPackageWith
                (pkgs // {
                  inherit deno deno-gen-cache-entry;
                })
                ./lib/deno-app-cache-entry.nix;
              denoAppCache2 = callPackageWith
                (pkgs // {
                  inherit deno deno-gen-cache-entry;
                })
                ./lib/deno-app-cache2.nix;
              denoAppCompile = callPackageWith
                (pkgs // {
                  inherit deno-app-transpile deno denort;
                })
                ./lib/deno-app-compile.nix;
              denoAppVendor = callPackageWith
                (pkgs // {
                  inherit deno;
                  nodejs = pkgs.nodejs_22;
                })
                ./lib/deno-app-vendor.nix;
              wrapJdk = import ./lib/wrap-jdk.nix;
              writeTextFiles = pkgs.callPackage ./lib/write-text-files.nix { };
              nonRootShadowSetup = pkgs.callPackage ./lib/non-root-shadow-setup.nix {
                inherit writeTextFiles;
              };
            };
        }
      );
}
