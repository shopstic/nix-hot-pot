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
    imageDigest = "sha256:b6b83d3c331794420340093eb706a6f152d9c1fa51b262d9bf34594887c2c7ac";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-puR757IYOrsuM3us+5QVvZodq19v/3Zzsu8B0YO+6Nk=" else
        "sha256-yPysq07M5xXM/WiLxxY4X4gVCtfRE/DEp/OblhH9Ngk=";
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
