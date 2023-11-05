{ buildGoModule
, fetchFromGitHub
, lib
, nix2container
, runCommand
, cacert
}:
let
  pname = "pvc-autoresizer";
  version = "0.10.0";

  pvc-autoresizer = buildGoModule rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "topolvm";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-tsuUFTKvGfcRbsaDpxxhIw0Bd7s6pTdBmZeMIIyWgAk=";
    };

    vendorSha256 = "sha256-0lsZYERe9UpQ2ZPomc9jK2UmduG9awQdumlwPgETazg=";

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
