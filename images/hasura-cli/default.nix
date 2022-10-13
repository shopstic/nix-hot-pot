{ nix2container
, hasura-cli
, bash
, gnutar
, gnused
, gzip
, coreutils
}:
nix2container.buildImage
{
  name = "hasura-cli";
  tag = hasura-cli.version;
  copyToRoot = [ hasura-cli bash coreutils gnutar gnused gzip ];
  maxLayers = 50;
  config = {
    env = [
      "PATH=/bin"
    ];
  };
}

