{ stdenv
, lib
, buildahBuild
, dockerTools
, iptables
, tini
, zerotierone
}:
let
  name = "zerotier-router";
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
          "sha256-y4THSavsqdunrG5Fq8wo9nlQ6e+FxiuFKGnBcSjXkBw=" else
          "sha256-JKRlhBbbEtO5YzFs1F3s/h8BWQSILVh8EL9ICfO85so=";
    };

  binPath = lib.makeBinPath [
    iptables
    zerotierone
  ];

  entrypoint = ./entrypoint.sh;
in
dockerTools.buildLayeredImage
{
  inherit name;
  fromImage = baseImage;
  tag = "1.10.1";
  config = {
    Env = [
      "PATH=${binPath}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];
    Entrypoint = [ tini "--" entrypoint ];
  };
}
