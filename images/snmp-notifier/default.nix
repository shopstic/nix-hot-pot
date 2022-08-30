{ nix2container
, runCommand
, dumb-init
, fetchzip
, stdenv
, bash
}:
let
  name = "snmp-notifier";
  version = "1.2.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/maxwo/snmp_notifier/releases/download/v${version}/snmp_notifier-${version}.linux-amd64.tar.gz";
      hash = "sha256-Hd1vghT97er4rgEDNdDJNZOU+aO17hEpKeZgukx8k6o=";
    };
    aarch64-linux = {
      url = "https://github.com/maxwo/snmp_notifier/releases/download/v${version}/snmp_notifier-${version}.linux-arm64.tar.gz";
      hash = "sha256-6vebovA+sz1beB+BZn/6M/3BMeAFTxEFgaw3spotcS0=";
    };
  };

  snmp-notifier = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "${name}-${version}";
      url = download.url;
      sha256 = download.hash;
      postFetch = ''
        mkdir $out/bin
        mv $out/snmp_notifier $out/bin/snmp_notifier
        chmod +x $out/bin/snmp_notifier
      '';
    };

  image = nix2container.buildImage
    {
      inherit name;
      tag = version;
      copyToRoot = [ dumb-init snmp-notifier bash ];
      config = {
        env = [
          "PATH=/bin"
        ];
        entrypoint = [ "dumb-init" "--" "snmp_notifier" ];
      };
    };
in
image // {
  dir = runCommand "${name}-dir" { } "${image.copyTo}/bin/copy-to dir:$out";
}

