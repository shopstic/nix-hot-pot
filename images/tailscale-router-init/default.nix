{ stdenv
, lib
, buildahBuild
, dockerTools
, awscli2
, jq
, coreutils
, iproute2
, bind
, dig
, inetutils
, iptables
}:
let
  name = "tailscale-router-init";
  baseImage = buildahBuild
    {
      name = "${name}-base";
      context = ./context;
      buildArgs = {
        fromTag = "22.04";
        fromDigest = "sha256:b6b83d3c331794420340093eb706a6f152d9c1fa51b262d9bf34594887c2c7ac";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-5qFhYEW0lGioxDLtKGsKbNyURLMBWMXvlxEzzIhY1qo=" else
          "sha256-4SExIPoF1wqU+kr6GINEGFnYyoCuH1nDvvaQkyRMWEE=";
    };

  binPath = lib.makeBinPath [
    awscli2
    jq
    coreutils
    iproute2
    bind
    dig
    inetutils
    iptables
  ];
in
dockerTools.buildLayeredImage
{
  inherit name;
  fromImage = baseImage;
  tag = awscli2.version;
  config = {
    Env = [
      "PATH=${binPath}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];
  };
}
