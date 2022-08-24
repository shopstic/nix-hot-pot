{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, writeTextFile
, nix2container
, coreutils
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
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      coreutils
      bash
      dumb-init
      jre
    ];
  };
  image = nix2container.buildImage
    {
      inherit name;
      # fromImage = base-image;
      tag = "${jre.version}-${fdb.version}";
      copyToRoot = [ nix-bin shadow home-dir ];
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
          "PATH=/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
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
