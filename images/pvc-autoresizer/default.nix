{ buildGoModule
, fetchFromGitHub
, lib
, nix2container
, runCommand
, cacert
}:
let
  pname = "pvc-autoresizer";
  version = "0.12.0";

  pvc-autoresizer = buildGoModule rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "topolvm";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-v5H207jGi3ZHYUPeE+R3f8STLGT7q3QFO/aVVn1mnvw=";
    };

    vendorHash = "sha256-di+h4smc1AinLZaARJHfZUH5XgmudrdoVVzQiwiixv8=";

    overrideModAttrs = _: {
      preBuild = ''
        go mod tidy
      '';
    };

    doCheck = false;
    meta = with lib; {
      description = pname;
      homepage = "https://github.com/topolvm/pvc-autoresizer";
      license = licenses.apsl20;
    };
  };
  image = nix2container.buildImage {
    name = pname;
    tag = version;
    config = {
      Env = [
        "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      Entrypoint = [ "${pvc-autoresizer}/bin/${pname}" ];
    };
    maxLayers = 50;
  };
in
image
