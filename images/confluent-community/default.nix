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
        fromDigest = "sha256:888cfa78edbdfa87860ef9785174b5db5aa7ef8ba5a88aff35ebd47fb05a8bf2";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-0mPv3pyCwGjUUNB6OeoQLCU7GS8MJS/MX8g0LOc4lvw=" else
          "sha256-qt5IGG0IJI2HMRN6XykfVgK17x19ASZRiedEz8382LY=";
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

