{ stdenv
, lib
, dockerTools
, writeTextFile
, dumb-init
}:
let
  baseImage = dockerTools.pullImage {
    imageName = "docker.io/docker";
    imageDigest = "sha256:210076c7772f47831afaf7ff200cf431c6cd191f0d0cb0805b1d9a996e99fb5e";
    sha256 =
      if stdenv.isx86_64 then
        "sha256-pXtBAltHWsVWggDCP6I6ZOBBvBsHMXWO5ZmoQyr6ANc=" else
        "sha256-Y2H9RiO5dlr3W8JKndrJjCsEgagA/0Mzm5tO68pT5U8=";
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
  tag = "20.10.14-dind";
  config = {
    Entrypoint = [ entrypoint ];
  };
}
