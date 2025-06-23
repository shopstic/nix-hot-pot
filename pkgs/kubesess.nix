{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "kubesess";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "Ramilito";
    repo = "kubesess";
    rev = "${version}";
    sha256 = "sha256-UkQ4jKfLcZ/ehGQshxuhMAhgdGpF8xiR7FRqt/tpJNY=";
  };

  cargoHash = "sha256-hrC3moHcEG7ttY+SHwkvMIe/15XixGMmEyHcj/RlFdw=";

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
