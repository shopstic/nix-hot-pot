{ stdenv
, lib
, dockerTools
, writeTextFile
, dumb-init
}:
let
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/docker";
    imageDigest = "sha256:a7a9383d0631b5f6b59f0a8138912d20b63c9320127e3fb065cb9ca0257a58b2";
    finalImageTag = "20.10.17-dind";
    finalImageName = "docker-dind";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-VaJc5cDDC4YvcqosnLEXjO2+GQ2VoSZnuJXh6w/vh20=" else
        "sha256-bHmOA6KyVNj2sIsdBOLO0jji681oBw79eXm+QNqv5r4=";
  };
  entrypoint = writeTextFile {
    name = "entrypoint.sh";
    executable = true;
    text = ''
      #!${dumb-init}/bin/dumb-init /bin/sh

      MTU=$(cat /sys/class/net/eth0/mtu)
      dockerd-entrypoint.sh --mtu "$MTU" --network-control-plane-mtu "$MTU" &

      until test -e /var/run/docker.sock; do
        sleep 0.2
      done

      chmod 0666 /var/run/docker.sock
      "$@"
      wait
    '';
  };
in
dockerTools.buildLayeredImage
{
  name = "dind";
  fromImage = baseImage;
  tag = "20.10.17-dind";
  config = {
    Entrypoint = [ entrypoint ];
  };
}
