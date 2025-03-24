{ nix2container
, redpanda
, runCommand
, buildEnv
, nonRootShadowSetup
, bash
, cacert
, coreutils
}:
let
  name = "rpk";
  user = "rpk";
  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "/dev/false"; };
  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
      mkdir -p $out/home/${user}
      cp -R ${shadow}/. $out/
    '';
    paths = [
      bash
      redpanda
      coreutils
    ];
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        tag = redpanda.version;
        copyToRoot = [ root-env ];
        maxLayers = 50;
        config = {
          env = [
            "PATH=/bin"
            "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
          user = "${user}:${user}";
        };
      };
in
image

