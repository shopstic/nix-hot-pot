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
    imageDigest = "sha256:2b7412e6465c3c7fc5bb21d3e6f1917c167358449fecac8176c6e496e5c1f05f";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-pE5ff062S0n4uD0D4xkVhxyKg6xrwlUTltr1yvNDdXc=" else
        "sha256-2oq46ycTFxyz6VDeXaGsMLmgZtFx9DeIIJMZ00d4AhE=";
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
