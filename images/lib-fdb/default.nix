{ dockerTools
, fdbLib
}:
dockerTools.buildImage {
  name = "lib-fdb";
  tag = "7.1.11";
  contents = [
    fdbLib
  ];
}

