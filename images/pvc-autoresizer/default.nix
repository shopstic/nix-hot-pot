{ buildGoModule
, fetchFromGitHub
, lib
, nix2container
, runCommand
, cacert
}:
let
  pname = "pvc-autoresizer";
  version = "0.16.0";

  pvc-autoresizer = buildGoModule rec {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "topolvm";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-o0wsOffbtXCbqtFpOsVntp9OevY+Rk0GM6jzawCXOEg=";
    };

    vendorHash = "sha256-HIH30zAbOyRb5qVsxAzsZltvr59UHot0Q43K6KA4uG0=";

    # overrideModAttrs = _: {
    #   preBuild = ''
    #     go mod tidy
    #   '';
    # };

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
      Entrypoint = [ "${pvc-autoresizer}/bin/cmd" ];
    };
    maxLayers = 50;
  };
in
image
