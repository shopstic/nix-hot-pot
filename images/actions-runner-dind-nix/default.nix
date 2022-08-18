{ stdenv
, lib
, buildahBuild
, dockerTools
, writeTextDir
, nix
}:
let
  baseName = "actions-runner-dind";
  arcVersion = "2.295.0";
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/summerwind/actions-runner-dind";
    imageDigest = "sha256:1c4c7b8e125d51bcf6f6c5777eb515a76b12201aa36a2fe98543f71a8702913b";
    sha256 = "sha256-0dkBF9HBaottGeURDvFA2LcK7pz2wtoUoqen5t4QBiA=";
    finalImageTag = "v${arcVersion}-ubuntu-20.04-3724b46";
    finalImageName = baseName;
  };
  pathEnv = "${lib.makeBinPath [ nix ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/runner/.local/bin";
in
dockerTools.buildLayeredImage
{
  name = "${baseName}-nix";
  fromImage = baseImage;
  tag = "${arcVersion}-${nix.version}";
  contents = [
    (
      writeTextDir "etc/environment" ''
        PATH=${pathEnv}
        ImageOS=ubuntu20
      ''
    )
  ];
  config = {
    Env = [
      "PATH=${pathEnv}"
      "GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt"
      "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
    ];
    User = "runner";
    Entrypoint = [ "/usr/local/bin/dumb-init" "--" ];
    Cmd = [ "startup.sh" ];
  };
}
