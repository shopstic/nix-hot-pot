{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "kubesess";
  version = "1.2.9";

  src = fetchFromGitHub {
    owner = "Ramilito";
    repo = "kubesess";
    rev = "${version}";
    sha256 = "sha256-xA1WHLeNz7dh235wBM8TNwaB1CgdIh5BphOFIL0jR3w=";
  };

  cargoSha256 = "sha256-SutK45Mqd5LPIsBaienEGO8rTqwD6gTiAT/sU9R38LU=";

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    mkdir $out/shell-init
    cp scripts/sh/* $out/shell-init/
  '';

  meta = with lib; {
    description = "kubesess";
    homepage = "https://github.com/Ramilito/kubesess";
    license = with licenses; [ mit ];
  };
}
