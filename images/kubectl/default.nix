{ nix2container
, kubectl
, bash
, coreutils
}:
nix2container.buildImage
{
  name = "kubectl";
  tag = kubectl.version;
  copyToRoot = [ kubectl bash coreutils ];
  maxLayers = 50;
  config = {
    env = [
      "PATH=/bin"
    ];
  };
}

