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
, nodejs-16_x
, nix
, gnugrep
, rsync
, curl
, docker
, openssh
, git
, amazon-ecr-credential-helper
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
      install -m755 src/Misc/layoutroot/safe_sleep.sh $out/lib/
    '';
    checkPhase = ''
      echo "Skipping tests"
    '';
  });

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-js71udw5wijNGx+U7xekS3y9tUvFAdJqQMoA9lOTpr8=" else
        "sha256-jkkPmXnYVU0LB+KQv35oCe5kKs6KWDEDmTXw4/yx8nU=";
  };

  user = "runner";

  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "/bin/bash"; };

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
        regex = "/home/${user}$";
        mode = "0777";
      }
    ];
  };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
