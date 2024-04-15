{ stdenv
, lib
, buildEnv
, writeTextFiles
, nonRootShadowSetup
, runCommand
, nix2container
, awscli2
, jq
, coreutils
, iproute2
, bind
, dig
, inetutils
, iptables
, curl
, kubectl
, cacert
, aws-batch-routes
}:
let
  name = "tailscale-router-init";

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu"; # 22.04
    imageDigest = "sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-KUA8AKl3ikfRXY7eRDE/8N66QrZUfl0315t2PvX1N+Y=" else
        "sha256-kZjCqIsObG5CFSmLpVfP1LiyVj9UwbzNmUZE+VgsUPk=";
  };

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      awscli2
      jq
      coreutils
      iproute2
      bind
      dig
      inetutils
      iptables
      curl
      kubectl
      aws-batch-routes
    ];
  };

  files = writeTextFiles {
    "etc/protocols" = ''
      ip           0          #dummy for IP
      icmp         1          #control message protocol
      tcp          6          #tcp
      udp         17          #user datagram protocol
    '';
  };

  image = nix2container.buildImage
    {
      inherit name;
      fromImage = base-image;
      tag = awscli2.version;
      maxLayers = 50;
      copyToRoot = [ nix-bin files ];
      config = {
        Env = [
          "PATH=/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
          "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
        ];
      };
    };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
