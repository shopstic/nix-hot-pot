{ stdenv
, dockerTools
, fetchurl
, writeTextFile
}:
let
  version = "2021.11-b227";
  baseImage = dockerTools.pullImage {
    imageName = "public.ecr.aws/docker/library/alpine";
    imageDigest = "sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-aMRsEo/RU9OPGPsi3ygW0i4yl41dFWSnFNNPwyLUtxM=" else
        "sha256-38IIeWKReVLRUmWo/jFzuORw1apisSAUZNxL5g6ybZY=";
    finalImageTag = "3.15.0";
    finalImageName = "alpine";
  };
  agentLib =
    if stdenv.isx86_64 then
      ./libs/amd64-libyjpagent.so else
      ./libs/arm64-libyjpagent.so;
  entrypoint = writeTextFile {
    name = "entrypoint";
    executable = true;
    text = ''
      #!/usr/bin/env sh
      cp ${agentLib} /target/libyjpagent.so
    '';
  };
in
dockerTools.buildImage {
  name = "lib-yourkit-agent";
  fromImage = baseImage;
  tag = version;
  config = {
    Entrypoint = [ entrypoint ];
  };
}

