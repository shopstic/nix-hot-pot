{ nix2container
, dumb-init
, bash
, coreutils
, openvpn
, netcat
, iptables
}:
nix2container.buildImage
{
  name = openvpn.name;
  tag = openvpn.version;
  copyToRoot = [ dumb-init bash coreutils openvpn netcat iptables ];
  config = {
    env = [
      "PATH=/bin"
    ];
    entrypoint = [ "dumb-init" "--" "openvpn" ];
  };
}

