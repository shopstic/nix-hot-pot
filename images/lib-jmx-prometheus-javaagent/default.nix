{ dockerTools
, fetchurl
}:
let
  version = "0.16.1";
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
in
dockerTools.buildImage {
  name = "lib-jmx-prometheus-javaagent";
  tag = version;
  contents = [
    jar
  ];
}

