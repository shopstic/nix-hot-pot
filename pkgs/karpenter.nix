{ buildGo118Module
, fetchFromGitHub
, lib
}:
let
  karpenter = buildGo118Module rec {
    pname = "karpenter";
    version = "0.16.0";

    src = fetchFromGitHub {
      owner = "aws";
      repo = "karpenter";
      rev = "v${version}";
      sha256 = "sha256-2GiEj3hPRYkFZroVrk61nQ6odqiPz5e57BrWdygwwTk=";
    };

    postPatch = ''
      substituteInPlace ./pkg/cloudprovider/aws/instance.go --replace 'SpotAllocationStrategyCapacityOptimizedPrioritized' 'SpotAllocationStrategyLowestPrice'
    '';

    vendorSha256 = "sha256-/zA3hioNkmZp1rHWutpadqh2/k9DFrrgYtK0/8ZDBuA=";

    subPackages = [ "cmd/controller" "cmd/webhook" ];

    outputs = [ "out" "controller" "webhook" ];

    postInstall = ''
      mkdir -p $controller/bin
      mkdir -p $webhook/bin

      mv $out/bin/controller $controller/bin/controller
      mv $out/bin/webhook $webhook/bin/webhook
    '';

    meta = with lib; {
      description = "Kubernetes Node Autoscaling: built for flexibility, performance, and simplicity";
      homepage = "https://github.com/aws/karpenter";
      license = licenses.apsl20;
    };
  };
in
karpenter
