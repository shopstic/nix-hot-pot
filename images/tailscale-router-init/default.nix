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
}:
let
  name = "tailscale-router-init";

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-84QvvklWwCznsS87GjFXZCRnPV8flsO/IogG4boiO/8=" else
        "sha256-k8pwaN4RtDPOZkYFePe6ZSGAFxGABOYqDHBM2PE0g3Q=";
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
