{ dockerTools
, dumb-init
}:
dockerTools.buildImage {
  name = "bin-dumb-init";
  tag = "1.2.5";
  contents = [
    dumb-init
  ];
}

