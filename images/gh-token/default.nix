{ dockerTools
, jwt-cli
, fetchurl
, bash
, coreutils
, runCommand
, gawk
, which
, curl
, jq
, cacert
}:
let
  version = "0.2.0";
  gitCommit = "46c5e330041584609b32e7d6e122abbf8078d27b";
  script = fetchurl {
    name = "gh-token-${gitCommit}";
    url = "https://raw.githubusercontent.com/Link-/gh-token/${gitCommit}/gh-token";
    sha256 = "sha256-HK6cO6wR+UvONao1yIrazd5MwKfsvPe5GA/qSyzq6GI=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = ''
      install -D -m0755 $downloadedFile $out
    '';
  };
  patched = runCommand "patch" { } ''
    mkdir -p $out/bin
    cp ${script} $out/bin/gh-token
    patchShebangs $out/bin/gh-token
  '';

in
dockerTools.buildImage {
  name = "gh-token-${version}";
  tag = version;
  config = {
    Env = [
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
    ];
  };
  contents = [
    bash
    patched
    jwt-cli
    coreutils
    gawk
    which
    curl
    jq
    cacert
  ];
}

