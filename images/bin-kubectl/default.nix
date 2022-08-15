{ dockerTools
, kubectl
}:
dockerTools.buildImage {
  name = "kubectl";
  tag = kubectl.version;
  contents = [
    kubectl
  ];
}

