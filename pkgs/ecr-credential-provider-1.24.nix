{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "ecr-credential-provider";
  version = "1.24";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "cloud-provider-aws";
    rev = "release-${version}";
    sha256 = "sha256-H3UNmZPK8/fXMgDJ3NQQdjCjTjL+i88r/c2iVACa3Pk=";
  };

  vendorHash = "sha256-cbvqDcFGZj0Zj6fX1AsCuwjBhcbXfQ/cDzhlQYDfzGg=";

  subPackages = [ "cmd/ecr-credential-provider" ];

  doCheck = false;

  meta = with lib; {
    description = "Cloud provider for AWS";
    homepage = "https://github.com/kubernetes/cloud-provider-aws";
    license = licenses.asl20;
  };
}
