{ nix2container
, buildEnv
, dumb-init
, tcpdump
, pcap-ws
}:
let
  name = pcap-ws.name;
  image =
    nix2container.buildImage
      {
        inherit name;
        # fromImage = base-image;
        tag = pcap-ws.version;
        copyToRoot = buildEnv {
          name = "bin";
          pathsToLink = [ "/bin" ];
          paths = [
            tcpdump
            pcap-ws
            dumb-init
          ];
        };
        maxLayers = 100;
        config = {
          env = [
            "PATH=/bin"
          ];
          entrypoint = [ "dumb-init" "--" "pcap-ws" "--pcap-cmd" "tcpdump" ];
        };
      };
in
image
