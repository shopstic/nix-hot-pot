{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "kubesess";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "Ramilito";
    repo = "kubesess";
    rev = "${version}";
    sha256 = "sha256-5+Pc8HVApi0aiDI1Y1zZXFNHjiNcOpfIrCBwgOgGVSs=";
  };

  cargoSha256 = "sha256-fvnMGwXH7UaqNK4vyfK7+zIftQkbyRrIvRG/ovPSqIk=";

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
