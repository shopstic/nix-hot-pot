{ stdenv
, lib
, buildahBuild
, dockerTools
, jre
, fdbLib
, writeTextFile
, dumb-init
}:
let
  baseImage = buildahBuild
    {
      name = "jre-fdb-app-base";
      context = ./context;
      buildArgs = {
        fromTag = "22.04";
        fromDigest = "sha256:b6b83d3c331794420340093eb706a6f152d9c1fa51b262d9bf34594887c2c7ac";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-ImMQfu7JqVkTUL+ToVlUqY23AmnIUZdSvAFE359Qbto=" else
          "sha256-snHeEM8efkRPy8/GBkcm9wPmECmm0IpoeX8o+ifur+0=";
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
  name = "jre-fdb-app";
  fromImage = baseImage;
  tag = "17-7.1.9";
  config = {
    Env = [
      "PATH=${lib.makeBinPath [ dumb-init jre ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdbLib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdbLib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
    ];
  };
}
