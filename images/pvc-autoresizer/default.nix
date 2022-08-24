{ buildGoModule
, fetchFromGitHub
, lib
, nix2container
, runCommand
, cacert
}:
let
  pname = "pvc-autoresizer";
  version = "0.5.0";

  pvc-autoresizer = buildGoModule rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "topolvm";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-+1tRTx24yFWjN4ZcxvpB04WedMkghdaUVDel8RH1xUM=";
    };

    vendorSha256 = "sha256-KcDu4S4fqSiz75IG3d3sRK6NFM2AGKOUHotD9J+pw2E=";

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
