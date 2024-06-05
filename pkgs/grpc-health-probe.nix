{ buildGo122Module
, fetchFromGitHub
, lib
}:
let
  grpc-health-probe = buildGo122Module rec {
    pname = "grpc-health-probe";
    version = "0.4.26";

    src = fetchFromGitHub {
      owner = "grpc-ecosystem";
      repo = "grpc-health-probe";
      rev = "v${version}";
      sha256 = "sha256-4/Yauqc0ZUhIVoLkDcEhvjX/5ZQxqmfQJTMdLqx48nc=";
    };

    vendorHash = "sha256-Pb1IxZMK0R1IdZouw4XI79gL+ABs/VBejXcRlMa6FC8=";

    meta = with lib; {
      description = "A command-line tool to perform health-checks for gRPC applications in Kubernetes etc.";
      homepage = "https://github.com/grpc-ecosystem/grpc-health-probe";
      license = licenses.apsl20;
    };
  };
in
grpc-health-probe
