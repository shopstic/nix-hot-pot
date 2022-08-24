{ nix2container
, docker-client
}:
nix2container.buildImage
{
  name = "bin-docker-client";
  tag = docker-client.version;
  copyToRoot = [ docker-client ];
}

