{ stdenv
, lib
, nonRootShadowSetup
, writeTextFiles
, nix2container
, runCommand
, github-runner
, dumb-init
, cacert
, nodejs-16_x
, nix
, rsync
, curl
, docker
, openssh
, git
, buildEnv
}:
let
  name = "github-runner-nix";

  docker-slim = docker.override {
    buildxSupport = false;
    composeSupport = false;
  };

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-js71udw5wijNGx+U7xekS3y9tUvFAdJqQMoA9lOTpr8=" else
        "sha256-jkkPmXnYVU0LB+KQv35oCe5kKs6KWDEDmTXw4/yx8nU=";
  };

  user = "runner";

  # Remove this once this PR is merged https://github.com/NixOS/nixpkgs/pull/187909
  patched-github-runner = github-runner.overrideAttrs (oldAttrs: {
    installPhase = ''
      runHook preInstall

      # Copy the built binaries to lib/ instead of bin/ as they
      # have to be wrapped in the fixup phase to work
      mkdir -p $out/lib
      cp -r _layout/bin/. $out/lib/

      # Delete debugging files
      find "$out/lib" -type f -name '*.pdb' -delete

      # Install the helper scripts to bin/ to resemble the upstream package
      mkdir -p $out/bin
      install -m755 src/Misc/layoutbin/runsvc.sh                 $out/bin/
      install -m755 src/Misc/layoutbin/RunnerService.js          $out/lib/
      install -m755 src/Misc/layoutroot/run.sh                   $out/lib/
      install -m755 src/Misc/layoutroot/run-helper.sh.template   $out/lib/run-helper.sh
      install -m755 src/Misc/layoutroot/config.sh                $out/lib/
      install -m755 src/Misc/layoutroot/env.sh                   $out/lib/

      # Rewrite reference in helper scripts from bin/ to lib/
      substituteInPlace $out/lib/run.sh    --replace '"$DIR"/bin' '"$DIR"/lib'
      substituteInPlace $out/lib/config.sh --replace './bin' $out'/lib' \
        --replace 'source ./env.sh' $out/bin/env.sh

      # Remove uneeded copy for run-helper template
      substituteInPlace $out/lib/run.sh --replace 'cp -f "$DIR"/run-helper.sh.template "$DIR"/run-helper.sh' ' '
      substituteInPlace $out/lib/run-helper.sh --replace '"$DIR"/bin/' '"$DIR"/'

      # Make paths absolute
      substituteInPlace $out/bin/runsvc.sh \
        --replace './externals' "$out/externals" \
        --replace './bin' "$out/lib"

      # The upstream package includes Node {12,16} and expects it at the path
      # externals/node{12,16}. As opposed to the official releases, we don't
      # link the Alpine Node flavors.
      mkdir -p $out/externals

      ln -s ${nodejs-16_x} $out/externals/node16

      # Install Nodejs scripts called from workflows
      install -D src/Misc/layoutbin/hashFiles/index.js $out/lib/hashFiles/index.js
      mkdir -p $out/lib/checkScripts
      install src/Misc/layoutbin/checkScripts/* $out/lib/checkScripts/

      runHook postInstall
    '';
  });

  shadow = nonRootShadowSetup { inherit user; uid = 1000; shellBin = "/bin/bash"; };

  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
    '';
    paths = [
      nix
      docker-slim
      rsync
      dumb-init
      curl
      openssh
      git
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
    tag = "${github-runner.version}-${nix.version}";
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
