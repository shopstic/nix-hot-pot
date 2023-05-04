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
    src = fetchFromGitHub {
      owner = "actions";
      repo = "runner";
      rev = "v${previousAttrs.version}";
      hash = "sha256-a/qh25mhI8wQE6PSsLhVFeTsfWL7iTFUhny+qvwy4fo=";
      leaveDotGit = true;
    };
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
    imageDigest = "sha256:67211c14fa74f070d27cc59d69a7fa9aeff8e28ea118ef3babc295a0428a6d21";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-5wTf3mcLVje0+pM4Q2aNd64BfsG4Xb1X3Vd6COyX01k=" else
        "sha256-tM8tB6aJQFUGos1PnsWmVRb80k3IkWd8+HRS3AK83Ds=";
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
        regex = "/home/${user}";
        mode = "0777";
      }
    ];
  };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
