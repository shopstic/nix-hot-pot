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
        fromDigest = "sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-ZRE+URaTis09Kyec4Hx6S5uAS+LrN28tisViK99OIso=" else
          "sha256-8CkiVyyISCHSIhQTifOZk3FwpeYgyXc9mggcCr8R7hU=";
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
  tag = "17-7.1.11";
  config = {
    Env = [
      "PATH=${lib.makeBinPath [ dumb-init jre ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY=${fdbLib}"
      "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdbLib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdbLib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
    ];
  };
}
