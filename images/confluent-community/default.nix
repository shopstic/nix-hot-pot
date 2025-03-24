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
, nonRootShadowSetup
, jre17
, curl
}:
let
  name = "confluent-community";
  minorVersion = "7.9";
  version = "7.9.0";
  user = "app";
  userUid = 1000;
  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "/dev/false"; };

  confluent-community = fetchzip {
    url = "https://packages.confluent.io/archive/${minorVersion}/confluent-community-${version}.zip";
    sha256 = "sha256-lSJfrPhDZA1mUzTmCgXVvdJcVG3dsMngyTb7rf6e+/E=";
    postFetch = ''
      rm -Rf $out/src
    '';
  };

  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      bashInteractive
      coreutils
      jre17
      curl
    ];
    postBuild = ''
      mkdir -p $out/home/${user}
      cp -R ${shadow}/. $out/
    '';
  };

  image = nix2container.buildImage
    {
      inherit name;
      tag = version;
      copyToRoot = [ root-env ];
      maxLayers = 7;
      perms = [
        {
          path = root-env;
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
