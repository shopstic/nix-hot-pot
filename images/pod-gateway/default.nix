{ stdenv
, lib
, buildahBuild
, dockerTools
, dumb-init
, coreutils
, dnsmasq
, iproute2
, bind
, iptables
}:
let
  name = "pod-gateway";
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
          "sha256-Cmg03aKEKrna2Y84il3/tRBu5WBobHObny6EZ0gGYMc=" else
          "sha256-CoHsTdCcsyUXNUct7LJCHk5maDb7U+lVGBt5r1JAEVg=";
    };

  binPath = lib.makeBinPath [
    dumb-init
    coreutils
    dnsmasq
    iproute2
    bind
    iptables
  ];
in
dockerTools.buildLayeredImage
{
  inherit name;
  fromImage = baseImage;
  tag = "1.6.0";
  config = {
    Env = [
      "PATH=${binPath}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "DNSMASQ_SHARE=${dnsmasq}/share/dnsmasq"
    ];
    Entrypoint = [ "${dumb-init}/bin/dumb-init" "--" ];
  };
}
