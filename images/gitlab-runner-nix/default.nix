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
, amazon-ecr-credential-helper
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

  base-image = nix2container.pullImage {
    imageName = "docker.io/library/ubuntu";
    imageDigest = "sha256:27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-84QvvklWwCznsS87GjFXZCRnPV8flsO/IogG4boiO/8=" else
        "sha256-k8pwaN4RtDPOZkYFePe6ZSGAFxGABOYqDHBM2PE0g3Q=";
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

  globalPath = "/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";

  etc-dir = writeTextFiles {
    "etc/environment" = builtins.concatStringsSep "\n" env;
  };

  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
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
    ];
  };

  env = [
    "PATH=${globalPath}"
    "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
  ];

  image = nix2container.buildImage {
    inherit name;
    tag = "${gitlab-runner.version}-${nix.version}";
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
      (nix2container.buildLayer { deps = [ gitlab-runner ]; })
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
