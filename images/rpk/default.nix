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
  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';
  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
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
        copyToRoot = [ nix-bin shadow home-dir ];
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

