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
, fetchurl
, oath-toolkit
}:
let
  openconnect-8 = openconnect.overrideAttrs (final: prev: rec {
    version = "8.20";
    src = fetchurl {
      url = "ftp://ftp.infradead.org/pub/openconnect/openconnect-${version}.tar.gz";
      sha256 = "sha256-wUUjhMb3lrruRdTpGa4b/CgdbIiGLh9kaizFE/xE5Ys=";
    };
  });
  name = openconnect-8.name;
  image =
    nix2container.buildImage
      {
        inherit name;
        # fromImage = base-image;
        tag = openconnect-8.version;
        copyToRoot = buildEnv {
          name = "bin";
          pathsToLink = [ "/bin" ];
          paths = [
            dumb-init
            openconnect-8
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
            oath-toolkit
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
