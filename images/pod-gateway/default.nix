{ stdenv
, lib
, buildahBuild
, dockerTools
, dumb-init
, coreutils
, dnsmasq
, iproute2
, bind
, dig
, inetutils
, iptables
, dhcp
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
          "sha256-UFuXnF8UNX5I1kkcg2E94zwy8Vc7lQxVzn/+EymrIGg=" else
          "sha256-rQjcp/rGOfCDB6CoMWfoWNrf5ysQCn4XjVr8h8kWazQ=";
    };

  binPath = lib.makeBinPath [
    dumb-init
    coreutils
    dnsmasq
    iproute2
    bind
    dig
    inetutils
    iptables
    dhcp
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
