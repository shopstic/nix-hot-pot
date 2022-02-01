{ stdenv
, dockerTools
, fetchurl
, writeTextFile
}:
let
  version = "0.16.1";
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
  jar = fetchurl {
    name = "jmx-prometheus-javaagent-${version}";
    url = "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${version}/jmx_prometheus_javaagent-${version}.jar";
    sha256 = "sha256-KEBqmBHr7uzZvJSjnSVGWpETLnbtQKJm8OEMwebPpyw=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      mkdir $out
      mv $downloadedFile $out/jmx_prometheus_javaagent.jar
    '';
  };
  entrypoint = writeTextFile {
    name = "entrypoint";
    executable = true;
    text = ''
      #!/usr/bin/env sh
      cp ${jar}/jmx_prometheus_javaagent.jar /target/jmx_prometheus_javaagent.jar
    '';
  };
in
dockerTools.buildImage {
  name = "lib-jmx-prometheus-javaagent";
  fromImage = baseImage;
  tag = version;
  config = {
    Entrypoint = [ entrypoint ];
  };
}

