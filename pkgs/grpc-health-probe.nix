{ buildGo119Module
, fetchFromGitHub
, lib
}:
let
  grpc-health-probe = buildGo119Module rec {
    pname = "grpc-health-probe";
    version = "0.4.22";

    src = fetchFromGitHub {
      owner = "grpc-ecosystem";
      repo = "grpc-health-probe";
      rev = "v${version}";
      sha256 = "sha256-BTLesBDRbkYW6e6fCKAuLlHOba1zMlX+gonj3tJzCXk=";
    };

    vendorHash = "sha256-qmG3ejJERHLvrhSHCmAui7/n0cV5L6UNjD5oHDDfmHE=";

    meta = with lib; {
      description = "A command-line tool to perform health-checks for gRPC applications in Kubernetes etc.";
      homepage = "https://github.com/grpc-ecosystem/grpc-health-probe";
      license = licenses.apsl20;
    };
  };
in
grpc-health-probe
