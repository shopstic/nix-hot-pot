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
    imageDigest = "sha256:ec050c32e4a6085b423d36ecd025c0d3ff00c38ab93a3d71a460ff1c44fa6d77";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-NMY1kmECmRCrxjPkcXwWAjVjwQsV1rUamtUhoAmYabc=" else
        "sha256-e3Mko4Y03OX8cxSjDu/PynPViawUem3BBNLUJst6g78=";
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
