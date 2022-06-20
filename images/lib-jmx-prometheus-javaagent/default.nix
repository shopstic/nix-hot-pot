{ stdenv
, dockerTools
, fetchurl
, writeTextFile
}:
let
  version = "0.17.0";
  baseImage = dockerTools.pullImage {
    imageName = "public.ecr.aws/docker/library/alpine";
    imageDigest = "sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-Cu5TDJS2tYQ3gilZWWjjpS12ZJ652UzR6Lza3SdSptI=" else
        "sha256-yJ1cLaQSzMU7s6vWFQJWTMFy72nT4DXFCA5cSTh94YU=";
    finalImageTag = "3.16.0";
    finalImageName = "alpine";
  };
  jar = fetchurl {
    name = "jmx-prometheus-javaagent-${version}";
    url = "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${version}/jmx_prometheus_javaagent-${version}.jar";
    sha256 = "sha256-eQNkblHzQMAo5YSuhYv6jzLA5IWmSri9ZtR+yJEOJIM=";
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

