{ nix2container
, netcat
, dumb-init
}:
nix2container.buildImage
{
  name = "netcat";
  tag = netcat.version;
  copyToRoot = [ netcat ];
  config = {
    Entrypoint = [ "${dumb-init}/bin/dumb-init" "--" "${netcat}/bin/nc" ];
  };
}

