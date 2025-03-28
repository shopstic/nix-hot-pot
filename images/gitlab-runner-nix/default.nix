{ stdenv
, lib
, nonRootShadowSetup
, writeTextFiles
, writeShellScriptBin
, nix2container
, runCommand
, buildEnv
, gitlab-runner
, dumb-init
, cacert
, nix
, gnugrep
, rsync
, curl
, docker
, openssh
, git
, yj
, jq
, nix-serve-ng
, amazon-ecr-credential-helper
, ubuntu-base-image
}:
let
  name = "gitlab-runner-nix";

  docker-slim = docker.override {
    buildxSupport = false;
    composeSupport = false;
  };

  wrapped-nix = writeShellScriptBin "nix" ''
    exec ${nix}/bin/nix "$@" 2> >(${gnugrep}/bin/grep -v "^evaluating file '.*'$" >&2)
  '';

  user = "runner";
  userUid = 1000;

  nixbldUserCount = 64;

  env = [
    "PATH=${globalPath}"
    "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
  ];

  root-files = writeTextFiles {
    "etc/shadow" = ''
      root:!x:::::::
      ${user}:!:::::::
      ${lib.concatMapStringsSep "\n" (x: "nixbld${toString x}:!:18610:0:99999:7:::") (lib.range 0 nixbldUserCount)}
    '';
    "etc/passwd" = ''
      root:x:0:0::/root:/bin/bash
      ${user}:x:${toString userUid}:${toString userUid}::/home/${user}:
      ${lib.concatMapStringsSep "\n" (x: "nixbld${toString x}:x:${toString (x + 30000)}:30000::/dev/null:") (lib.range 0 nixbldUserCount)}
    '';
    "etc/group" = ''
      root:x:0:0::/root:/bin/bash
      ${user}:x:${toString userUid}:${toString userUid}::/home/${user}:
      nixbld:x:30000:${lib.concatMapStringsSep "," (x: "nixbld${toString x}") (lib.range 0 nixbldUserCount)}
    '';
    "etc/gshadow" = ''
      root:x::
      ${user}:x::
      nixbld:!::${lib.concatMapStringsSep "," (x: "nixbld${toString x}") (lib.range 0 nixbldUserCount)}
    '';
     "home/${user}/.docker/config.json" = builtins.toJSON {
      credHelpers = {
        "public.ecr.aws" = "ecr-login";
      };
    };
     "etc/environment" = builtins.concatStringsSep "\n" env;
  };

  globalPath = "/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";

  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
      cp -R ${root-files}/. $out/
    '';
    paths = [
      gitlab-runner
      wrapped-nix
      docker-slim
      rsync
      dumb-init
      curl
      openssh
      git
      yj
      jq
      amazon-ecr-credential-helper
      nix-serve-ng
    ];
  };


  image = nix2container.buildImage {
    inherit name;
    tag = "${gitlab-runner.version}-${nix.version}";
    fromImage = ubuntu-base-image;
    config = {
      inherit env;
      volumes = {
        "/home/${user}" = { };
      };
      entrypoint = [
        "dumb-init"
        "--"
      ];
    };
    copyToRoot = [ root-env ];
    maxLayers = 30;
    perms = [
      {
        path = root-env;
        regex = "/home/${user}";
        mode = "0755";
        gid = userUid;
        uid = userUid;
      }
    ];
  };
in
image
