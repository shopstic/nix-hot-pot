{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "kwok";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kwok";
    rev = "v${version}";
    sha256 = "sha256-u+CGMGBSrQOlUBLt4ZSakts1ZBPbNxuyz4GxoVxoBFI=";
  };

  vendorHash = "sha256-5ssgS7K4tX25aS2tfApKNUi510aUdQ6PGFKuHVoxL/c=";

  excludedPackages = [ "gen_cmd_docs" "verify_boilerplate" ];

  meta = with lib; {
    description = "Kubernetes WithOut Kubelet";
    homepage = "https://github.com/kubernetes-sigs/kwok";
    license = licenses.asl20;
  };
}
