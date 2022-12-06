{ lib
, buildGoModule
, fetchFromGitHub
, git
}:

buildGoModule rec {
  pname = "atlas";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "ariga";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-sC0RkRUtOkmQ07A7WVU9Tg29Ffk6H26z7FdtnMgatc8=";
  };

  vendorSha256 = "sha256-XjmXMj9EaRuqSqAgZdvi51gy2gMbwYk6/J40qbQH8CQ=";

  proxyVendor = true;

  modRoot = "cmd/atlas";

  ldflags = [ "-s" "-w" ];

  checkInputs = [ git ];

  doCheck = false;

  meta = with lib; {
    description = "An open source tool that helps developers manage their database schemas by applying modern DevOps principles";
    homepage = "https://atlasgo.io";
    license = licenses.asl20;
  };
}