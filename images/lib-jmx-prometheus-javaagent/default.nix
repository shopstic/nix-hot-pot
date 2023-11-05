{ nix2container
, coreutils
, fetchurl
, writeShellScript
}:
let
  version = "0.20.0";
  jar = fetchurl {
    name = "jmx-prometheus-javaagent-${version}";
    url = "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${version}/jmx_prometheus_javaagent-${version}.jar";
    sha256 = "sha256-vkqzg/guqweRExLO1GRckaVlUm4WI9fP+RhZP0yElkI=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      mkdir $out
      mv $downloadedFile $out/jmx_prometheus_javaagent.jar
    '';
  };
  entrypoint = writeShellScript "entrypoint.sh" ''
    ${coreutils}/bin/cp ${jar}/jmx_prometheus_javaagent.jar /target/jmx_prometheus_javaagent.jar
  '';
in
nix2container.buildImage
{
  name = "lib-jmx-prometheus-javaagent";
  tag = version;
  config = {
    Entrypoint = [ entrypoint ];
  };
}

