{ nix2container
, kwok
}:
nix2container.buildImage {
  name = "kwok";
  tag = kwok.version;
  config = {
    entrypoint = [ "${kwok}/bin/kwok" ];
  };
}
