{ stdenv
, lib
, buildahBuild
, dockerTools
, writeTextDir
, nix
}:
let
  baseName = "actions-runner-dind";
  arcVersion = "2.294.0";
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/summerwind/actions-runner-dind";
    imageDigest = "sha256:38295a73790ca6ec5c466afaf2781f9f6ba2a358ba8e80f5334ea2b4aebebc4e";
    sha256 = "sha256-vWTum/cGMXrec55/bM4xVCxnrCa1/OrmasoPVsGGSdQ=";
    finalImageTag = "v${arcVersion}-ubuntu-20.04-fc55477";
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
