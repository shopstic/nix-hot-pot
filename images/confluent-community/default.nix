{ lib
, stdenv
, dumb-init
, writeTextFile
, buildahBuild
, dockerTools
, fetchzip
}:
let
  name = "confluent-community";
  baseImage = buildahBuild
    {
      name = "${name}-base";
      context = ./context;
      buildArgs = {
        fromTag = "11-jdk-focal";
        fromDigest = "sha256:5da9a1c62c20666ea0c3c61825e3ac62a0cca2148d40e080f2194fa09ccf34b1";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-+ftOGITuu4/WXuF3NNea8iATNhT0e2Owfw4ElwlToIU=" else
          "sha256-qdIgKvrU5dpPOKYSthiZH3C0/7dXxSedpP944F2dywE=";
    };

  package = fetchzip {
    url = "https://packages.confluent.io/archive/7.1/confluent-community-7.1.1.zip";
    sha256 = "sha256-WsbSzFKX1rxhCKaGPeGbwhlP95PtujC3GuCzx2OMDi4=";
  };

  entrypoint = writeTextFile {
    name = "entrypoint";
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      exec dumb-init -- "$@"
    '';
  };
  baseImageWithDeps = dockerTools.buildImage {
    inherit name;
    fromImage = baseImage;
    config = {
      Env = [
        "PATH=${lib.makeBinPath [ dumb-init package ]}:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
    };
  };
in
dockerTools.buildLayeredImage {
  inherit name;
  fromImage = baseImageWithDeps;
  tag = "7.1.1";
  config = {
    Entrypoint = [ entrypoint ];
  };
}

