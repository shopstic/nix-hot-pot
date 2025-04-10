{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, writeTextFile
, nix2container
, coreutils
, gnugrep
, gnused
, gawk
, bash
, fdb
, jre
, dumb-init
, dnsutils
}:
let
  name = "jre-fdb-app";

  javaSecurityOverrides = writeTextFile {
    name = "java.security.overrides";
    text = ''
      networkaddress.cache.ttl=5
      networkaddress.cache.negative.ttl=1
    '';
  };

  user = "app";
  userUid = 1000;

  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "${bash}/bin/bash"; };

  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    paths = [
      coreutils
      gnugrep
      gnused
      gawk
      bash
      dumb-init
      jre
      dnsutils
    ];
    postBuild = ''
      mkdir -p $out/home/${user}
      mkdir -p $out/tmp
      cp -R ${shadow}/. $out/
      mkdir -p $out/usr/bin
      ln -s ${coreutils}/bin/env $out/usr/bin/env
    '';
  };

  image = nix2container.buildImage
    {
      inherit name;
      # fromImage = base-image;
      tag = "${(builtins.replaceStrings ["+"] ["_"] jre.version)}-${fdb.version}";
      copyToRoot = [ root-env ];
      maxLayers = 10;
      perms = [
        {
          path = root-env;
          regex = "/home/${user}";
          gid = userUid;
          uid = userUid;
          mode = "0755";
        }
        {
          path = root-env;
          regex = "/tmp";
          gid = userUid;
          uid = userUid;
          mode = "0755";
        }
      ];
      config = {
        env = [
          "PATH=/bin"
          "FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY=${fdb.lib}"
          "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdb.lib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdb.lib}/libfdb_java.so -Djava.security.properties=${javaSecurityOverrides}"
        ];
        user = "${user}:${user}";
        workingdir = "/home/${user}";
        entrypoint = [ "dumb-init" "--" ];
      };
    };
in
image
