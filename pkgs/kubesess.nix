{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "kubesess";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "Ramilito";
    repo = "kubesess";
    rev = "${version}";
    sha256 = "sha256-zwgj9BmrrfRcRg8ZLbqLkoCSVWvQ/HwR+gbsIoOvcWM=";
  };

  cargoSha256 = "sha256-TeN+De8RJAA4vytQ0YAwU7yQjpOTAn9W9QvdGa4yMXU=";

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
