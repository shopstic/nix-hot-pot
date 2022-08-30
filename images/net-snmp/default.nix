{ nix2container
, runCommand
, dumb-init
, net-snmp
, bash
, coreutils
}:
let
  name = net-snmp.name;
  image = nix2container.buildImage {
    inherit name;
    tag = net-snmp.version;
    copyToRoot = [ dumb-init net-snmp bash coreutils ];
    config = {
      env = [
        "PATH=/bin"
      ];
      entrypoint = [ "dumb-init" "--" "snmptrapd" ];
    };
  };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}
