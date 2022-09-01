{ nix2container
, dumb-init
, bash
, coreutils
, openvpn
, netcat
, iptables
, sysctl
, iproute2
, gnugrep
, dig
}:
nix2container.buildImage
{
  name = openvpn.name;
  tag = openvpn.version;
  copyToRoot = [
    dumb-init
    bash
    coreutils
    openvpn
    netcat
    iptables
    sysctl
    iproute2
    gnugrep
    dig
  ];
  config = {
    env = [
      "PATH=/bin"
    ];
    entrypoint = [ "dumb-init" "--" "openvpn" ];
  };
}

