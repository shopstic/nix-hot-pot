{ stdenv
, lib
, runCommand
, patchelf
, fetchFromGitHub
, rustPlatform
, makeWrapper
, pkg-config
, curl
, Security
, CoreServices
, libiconv
, xz
, perl
, substituteAll
}:

rustPlatform.buildRustPackage rec {
  pname = "edgedb";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "edgedb";
    repo = "edgedb-cli";
    rev =  "v${version}";
    sha256 = "sha256-Vc982SAHrKtJOsTRoHNwKYyfy/4+KQ5txqgeMH/myvs=";
  };

  cargoSha256 = "sha256-pQhb7+E5iolEbm8QhJ/N2wLXEzgEyhV6VTZ3cXjCJeI=";

  nativeBuildInputs = [ makeWrapper pkg-config perl ];

  buildInputs = [
    curl
  ] ++ lib.optionals stdenv.isDarwin [ CoreServices Security libiconv xz ];

  checkFeatures = [ ];

  # patches = [
  #   (substituteAll {
  #     src = ./0001-dynamically-patchelf-binaries.patch;
  #     inherit patchelf;
  #     dynamicLinker = stdenv.cc.bintools.dynamicLinker;
  #   })
  # ];

  doCheck = false;

  meta = with lib; {
    description = "EdgeDB CLI";
    homepage = "https://www.edgedb.com/docs/cli/index";
    license = with licenses; [ asl20 /* or */ mit ];
  };
}