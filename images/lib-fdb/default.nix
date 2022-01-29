{ dockerTools
, fdbLib
}:
dockerTools.buildImage {
  name = "lib-fdb";
  tag = "6.3.23";
  contents = [
    fdbLib
  ];
}

