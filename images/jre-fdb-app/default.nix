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

  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "${bash}/bin/bash"; };

  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    paths = [
      coreutils
      gnugrep
      gnused
      gawk
      bash
      dumb-init
      jre
    ];
  };

  usr-bin = runCommand "usr-bin" { } ''
    mkdir -p $out/usr/bin
    ln -s ${coreutils}/bin/env $out/usr/bin/env
  '';

  image = nix2container.buildImage
    {
      inherit name;
      # fromImage = base-image;
      tag = "${(builtins.replaceStrings ["+"] ["_"] jre.version)}-${fdb.version}";
      copyToRoot = [ nix-bin shadow home-dir usr-bin ];
      maxLayers = 50;
      perms = [
        {
          path = home-dir;
          regex = "/home/${user}$";
          mode = "0777";
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
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
