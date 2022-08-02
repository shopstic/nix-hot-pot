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
    imageDigest = "sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-BvCwhmD6YXiQBAugQyqlbrvonHO4L8gjieYfNiTvNpc=" else
        "sha256-6ywrDWx9bsVrlDKBZwIhXl0Ar35YVg9rjFBHsdCb2eM=";
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
  tag = "17-7.1.11";
  config = {
    Env = [
      "PATH=${lib.makeBinPath [ dumb-init jre ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY=${fdbLib}"
      "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdbLib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdbLib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
    ];
  };
}
