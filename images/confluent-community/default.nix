{ lib
, stdenv
, buildEnv
, runCommand
, nix2container
, fetchzip
, dumb-init
, cacert
, bashInteractive
, coreutils
, findutils
, nonRootShadowSetup
, jre17
}:
let
  name = "confluent-community";
  minorVersion = "7.5";
  version = "7.5.1";
  user = "app";
  userUid = 1000;
  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "/dev/false"; };
  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-Le+rz5NDTeyZrxNI98Uix+RnAeUC1hem0YHO6dTr5VA=";
    postFetch = ''
      rm -Rf $out/src
    '';
  };

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      bashInteractive
      coreutils
      findutils
      jre17
    ];
  };

  image = nix2container.buildImage
    {
      inherit name;
      tag = version;
      copyToRoot = [ nix-bin shadow home-dir ];
      maxLayers = 50;
      perms = [
        {
          path = home-dir;
          regex = "/home/${user}";
          mode = "0755";
          gid = userUid;
          uid = userUid;
        }
      ];
      config = {
        volumes = {
          "/home/${user}" = { };
        };
        env = [
          "PATH=/bin:${confluent-community}/bin"
          "LOG_DIR=/home/${user}/logs"
          "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
        ];
        entrypoint = [ "dumb-init" "--" ];
        user = "${user}:${user}";
      };
    };
in
image
