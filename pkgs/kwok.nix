{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "kwok";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kwok";
    rev = "v${version}";
    sha256 = "sha256-ClKQTxcib8bXI+fFoFSOX/0rw3h4+Cb6M96ZDt6xWp4=";
  };

  vendorSha256 = "sha256-r6v6LnmVeeRX2rESu4a4SppTcUWwL8Orwr+Q6I8YzgU=";

  excludedPackages = [ "gen_cmd_docs" "verify_boilerplate" ];

  meta = with lib; {
    description = "Kubernetes WithOut Kubelet";
    homepage = "https://github.com/kubernetes-sigs/kwok";
    license = licenses.asl20;
  };
}
