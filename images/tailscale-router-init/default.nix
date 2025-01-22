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
    imageName = "docker.io/library/ubuntu"; # 24.04
    imageDigest = "sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-KKVXvKN0ul3yQXPMaRznwqVMpoQ2w5NbAGlIQf63moA=" else
        "sha256-0EIgRSVcMP8tZqww+nZWkoPHFb3J2lMqbvYxhXmZmvk=";
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
