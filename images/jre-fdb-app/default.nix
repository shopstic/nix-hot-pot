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
        fromTag = "21.04";
        fromDigest = "sha256:ba394fabd516b39ccf8597ec656a9ddd7d0a2688ed8cb373ca7ac9b6fe67848f";
      };
      outputHash =
        if stdenv.isx86_64 then
          "sha256-GgfPaN6si6+wrRVH3Fa03U8MBkJz5ziaw52Suo2rrgc=" else
          "sha256-3u3m5tLWwcTQzlqyRYTIcaS+BGklpUOapNlg/c0sPfs=";
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
  tag = "17-6.3.23";
  config = {
    Env = [
      "PATH=${lib.makeBinPath [ dumb-init jre ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdbLib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdbLib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
    ];
  };
}
