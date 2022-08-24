{ nix2container
, fdb
}:
nix2container.buildImage {
  name = "lib-fdb";
  tag = fdb.version;
  copyToRoot = [
    fdb.lib
  ];
}

