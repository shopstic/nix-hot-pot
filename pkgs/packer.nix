{ fetchzip, stdenv }:
let
  version = "1.7.9";
  downloadMap = {
    x86_64-linux = {
      url = "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip";
      hash = "sha256-ltV1Dr8qxOju7FHZaN48L2MHIH9uraU4FY3oIYxqFYE=";
    };
    x86_64-darwin = {
      url = "https://releases.hashicorp.com/packer/${version}/packer_${version}_darwin_amd64.zip";
      hash = "sha256-A4OpftYgfEFSNOPSzcNSdxJWJFBOftousd+HkLbwWNo=";
    };
    aarch64-darwin = {
      url = "https://releases.hashicorp.com/packer/${version}/packer_${version}_darwin_arm64.zip";
      hash = "sha256-zctzyhackh+PVvT5tOXrkIXW1Qa+n7h+jUkiybZmBpM=";
    };
    aarch64-linux = {
      url = "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_arm64.zip";
      hash = "sha256-X7Ca2gii5SNy3db4jWMRwZSk8o+eZ67cPdY6pgHx3UU=";
    };
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "packer";

  downloaded = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "packer-${version}";
      url = download.url;
      sha256 = download.hash;
    };

  dontUnpack = true;
  dontPatch = true;
  dontStrip = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m+x ${downloaded}/packer $out/bin/
  '';

  meta = with stdenv.lib; {
    homepage = https://www.packer.io/;
    description = "Packer";
    platforms = builtins.attrNames downloadMap;
  };
}
