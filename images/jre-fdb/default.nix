{ stdenv
, lib
, jre
, dockerTools
, fdbLib
, writeTextFile
, dumb-init
}:
let
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:ba394fabd516b39ccf8597ec656a9ddd7d0a2688ed8cb373ca7ac9b6fe67848f";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-jZmw6RuP1Kj92oA8hCePVM1+fYqOWPC5UnSUCnfsRtA=" else
        "sha256-6J6ANqCYTvqhkW23iNVqV2kRejbllq/nx8VBzlcu4CU=";
  };
  javaSecurityOverrides = writeTextFile {
    name = "java.security.overrides";
    text = ''
      networkaddress.cache.ttl=5
      networkaddress.cache.negative.ttl=1
    '';
  };
in
dockerTools.buildLayeredImage
{
  name = "jre-fdb";
  fromImage = baseImage;
  tag = "11-6.3.23";
  config = {
    Env = [
      "PATH=${lib.makeBinPath [ dumb-init jre ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "JAVA_OPTS=-DFDB_LIBRARY_PATH_FDB_C=${fdbLib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdbLib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
    ];
  };
}
