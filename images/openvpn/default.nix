{ nix2container
, stdenv
, buildEnv
, runCommand
, dumb-init
, openvpn
, netcat
, iptables
, sysctl
, iproute2
, dig
, coreutils
, bash
}:
let
  name = openvpn.name;
  image =
    nix2container.buildImage
      {
        inherit name;
        # fromImage = base-image;
        tag = openvpn.version;
        copyToRoot = buildEnv {
          name = "bin";
          pathsToLink = [ "/bin" ];
          paths = [
            dumb-init
            openvpn
            netcat
            iptables
            sysctl
            iproute2
            dig
            coreutils
            bash
          ];
        };
        maxLayers = 80;
        config = {
          env = [
            "PATH=/bin"
          ];
          entrypoint = [ "dumb-init" "--" "openvpn" ];
        };
      };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
