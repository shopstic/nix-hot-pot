{ stdenv
, lib
, nonRootShadowSetup
, writeTextFiles
, writeShellScriptBin
, nix2container
, runCommand
, buildEnv
, github-runner
, dumb-init
, cacert
, nix
, gnugrep
, rsync
, curl
, docker
, openssh
, git
, amazon-ecr-credential-helper
, fetchFromGitHub
}:
let
  name = "github-runner-nix";

  docker-slim = docker.override {
    buildxSupport = false;
    composeSupport = false;
  };

  wrapped-nix = writeShellScriptBin "nix" ''
    exec ${nix}/bin/nix "$@" 2> >(${gnugrep}/bin/grep -v "^evaluating file '.*'$" >&2)
  '';

  patched-github-runner = github-runner.overrideAttrs (finalAttrs: previousAttrs: {
    postInstall = ''
      ${previousAttrs.postInstall}
      install -m755 src/Misc/layoutroot/safe_sleep.sh $out/lib/github-runner
    '';
    checkPhase = ''
      echo "Skipping tests"
    '';
  });

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu"; # 22.04
    imageDigest = "sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-KUA8AKl3ikfRXY7eRDE/8N66QrZUfl0315t2PvX1N+Y=" else
        "sha256-kZjCqIsObG5CFSmLpVfP1LiyVj9UwbzNmUZE+VgsUPk=";
  };

  user = "runner";
  userUid = 1000;
  nixbldUserCount = 64;

  shadow = writeTextFiles {
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
  };

  home-dir = writeTextFiles {
    "home/${user}/.docker/config.json" = builtins.toJSON {
      credHelpers = {
        "public.ecr.aws" = "ecr-login";
      };
    };
  };

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      wrapped-nix
      docker-slim
      rsync
      dumb-init
      curl
      openssh
      git
      amazon-ecr-credential-helper
    ];
  };

  globalPath = "/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";

  env = [
    "PATH=${globalPath}"
    "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    "GH_RUNNER_PATH=${patched-github-runner}/bin"
  ];

  etc-dir = writeTextFiles {
    "etc/environment" = builtins.concatStringsSep "\n" env;
  };

  image = nix2container.buildImage {
    inherit name;
    tag = "${patched-github-runner.version}-${nix.version}";
    fromImage = base-image;
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
    copyToRoot = [ nix-bin shadow home-dir etc-dir ];
    layers = [
      (nix2container.buildLayer { deps = [ docker-slim ]; })
      (nix2container.buildLayer { deps = [ patched-github-runner ]; })
    ];
    maxLayers = 100;
    perms = [
      {
        path = home-dir;
        regex = "/home/${user}";
        mode = "0755";
        uid = userUid;
        gid = userUid;
      }
    ];
  };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
