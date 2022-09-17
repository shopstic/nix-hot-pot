{ nix2container
, stdenv
, buildEnv
, runCommand
, dumb-init
, openconnect
, netcat
, iptables
, sysctl
, iproute2
, dig
, gawk
, gnugrep
, gnused
, coreutils
, bash
, cacert
}:
let
  name = openconnect.name;
  image =
    nix2container.buildImage
      {
        inherit name;
        # fromImage = base-image;
        tag = openconnect.version;
        copyToRoot = buildEnv {
          name = "bin";
          pathsToLink = [ "/bin" ];
          paths = [
            dumb-init
            openconnect
            netcat
            iptables
            sysctl
            iproute2
            dig
            coreutils
            gawk
            gnugrep
            gnused
            bash
          ];
        };
        maxLayers = 100;
        config = {
          env = [
            "PATH=/bin"
            "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
          entrypoint = [ "dumb-init" "--" "openconnect" ];
        };
      };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
