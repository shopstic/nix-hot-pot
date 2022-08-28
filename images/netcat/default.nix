{ nix2container
, netcat
, dumb-init
, bash
}:
nix2container.buildImage
{
  name = "netcat";
  tag = netcat.version;
  copyToRoot = [ dumb-init netcat bash ];
  config = {
    env = [
      "PATH=/bin"
    ];
    entrypoint = [ "dumb-init" "--" "nc" ];
  };
}

