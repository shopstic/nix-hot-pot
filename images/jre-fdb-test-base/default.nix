{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, writeShellScriptBin
, nix2container
, fdb
, jre
, dumb-init
, bash
}:
let
  name = "jre-fdb-test-base";

  base-image = nix2container.pullImage {
    imageName = "docker.io/docker"; # 20.10.24-cli
    imageDigest = "sha256:2967f0819c84dd589ed0a023b9d25dcfe7a3c123d5bf784ffbb77edf55335f0c";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-lp2BUGOJ72bJ0EEuTbr8dGcIjLn6GbnOfTBYRLISaM8=" else
        "sha256-SsnV1E8R60qF8sKF7ZIQHrpz0wA6CIQyJ5KEfpsjVDY=";
  };

  user = "app";
  userUid = 1000;

  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "${bash}/bin/bash"; };

  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';

  entrypoint = writeShellScriptBin "entrypoint.sh" ''
    set -euo pipefail
    JAVA_SECURITY_OVERRIDES=''${JAVA_SECURITY_OVERRIDES:-""}

    cat << EOF > /home/${user}/.java.security.overrides.properties
    networkaddress.cache.ttl=5
    networkaddress.cache.negative.ttl=0
    ''${JAVA_SECURITY_OVERRIDES}
    EOF

    exec "$@"
  '';

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      dumb-init
      jre
      entrypoint
      bash
    ];
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        fromImage = base-image;
        tag = "${(builtins.replaceStrings ["+"] ["_"] jre.version)}-${fdb.version}";
        copyToRoot = [ nix-bin shadow home-dir ];
        maxLayers = 100;
        perms = [
          {
            path = home-dir;
            regex = "/home/${user}";
            gid = userUid;
            uid = userUid;
            mode = "0755";
          }
        ];
        config = {
          env = [
            "PATH=/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            "FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY=${fdb.lib}"
            "JDK_JAVA_OPTIONS=-DFDB_LIBRARY_PATH_FDB_C=${fdb.lib}/libfdb_c.so -DFDB_LIBRARY_PATH_FDB_JAVA=${fdb.lib}/libfdb_java.so -Djava.security.properties=/home/${user}/.java.security.overrides.properties"
          ];
          entrypoint = [ "dumb-init" "--" "entrypoint.sh" ];
          user = "${user}:${user}";
        };
      };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
