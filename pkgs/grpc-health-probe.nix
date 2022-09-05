{ buildGo118Module
, fetchFromGitHub
, lib
}:
let
  grpc-health-probe = buildGo118Module rec {
    pname = "grpc-health-probe";
    version = "0.4.12";

    src = fetchFromGitHub {
      owner = "grpc-ecosystem";
      repo = "grpc-health-probe";
      rev = "v${version}";
      sha256 = "sha256-uFodMdfh1E6Tpiw2LFGrcfWqO7lMJA5yLpywQklzC3A=";
    };

    vendorSha256 = "sha256-Cx0jmChkgnGNDFrKr/vUm7a2TsSvauEmJWAa54Hjb1I=";

    meta = with lib; {
      description = "A command-line tool to perform health-checks for gRPC applications in Kubernetes etc.";
      homepage = "https://github.com/grpc-ecosystem/grpc-health-probe";
      license = licenses.apsl20;
    };
  };
in
grpc-health-probe
