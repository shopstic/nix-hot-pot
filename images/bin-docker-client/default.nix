{ dockerTools
, docker-client
}:
dockerTools.buildImage {
  name = "bin-docker-client";
  tag = "20.10.9";
  contents = [
    docker-client
  ];
}

