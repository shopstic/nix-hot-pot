{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, writeTextFile
, nix2container
, fdb
, jre
, dumb-init
}:
let
  name = "jre-fdb-test-base";

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-js71udw5wijNGx+U7xekS3y9tUvFAdJqQMoA9lOTpr8=" else
        "sha256-jkkPmXnYVU0LB+KQv35oCe5kKs6KWDEDmTXw4/yx8nU=";
  };

  javaSecurityOverrides = writeTextFile {
    name = "java.security.overrides";
    text = ''
      networkaddress.cache.ttl=5
      networkaddress.cache.negative.ttl=1
    '';
  };

  user = "app";

  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "/bin/bash"; };

  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      dumb-init
      jre
    ];
  };
  image =
    nix2container.buildImage
      {
        inherit name;
        fromImage = base-image;
        tag = "${(replaceStrings ["+"] ["_"] jre.version)}-${fdb.version}";
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
          entrypoint = [ "dumb-init" "--" ];
        };
      };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
