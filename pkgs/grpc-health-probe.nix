{ buildGo123Module
, fetchFromGitHub
, lib
}:
let
  grpc-health-probe = buildGo123Module rec {
    pname = "grpc-health-probe";
    version = "0.4.40";

    src = fetchFromGitHub {
      owner = "grpc-ecosystem";
      repo = "grpc-health-probe";
      rev = "v${version}";
      sha256 = "sha256-aWQyB7oZASNzqSrooA7AFdAbE1I=";
    };

    vendorHash = lib.fakeHash;

    meta = with lib; {
      description = "A command-line tool to perform health-checks for gRPC applications in Kubernetes etc.";
      homepage = "https://github.com/grpc-ecosystem/grpc-health-probe";
      license = licenses.apsl20;
    };
  };
in
grpc-health-probe
