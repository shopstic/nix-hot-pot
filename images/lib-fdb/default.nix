{ dockerTools
, fdbLib
}:
dockerTools.buildImage {
  name = "lib-fdb";
  tag = "7.1.9";
  contents = [
    fdbLib
  ];
}

