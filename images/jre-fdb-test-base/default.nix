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
    imageName = "docker.io/docker"; # 20.10.17-cli
    imageDigest = "sha256:6c5c8b70d0de524ff092921c05ebe9c1b0d05c29962d6717666b29049e52aefe";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-cpuJL4DL9Ebv+Uf5GBlWZL5olpgWoOZnDKvxfqvao/U=" else
        "sha256-6DCXLBYvQP9g1WSroGskPcK0KNDYol37jck/9XRH4So=";
  };

  user = "app";

  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "${bash}/bin/bash"; };

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
