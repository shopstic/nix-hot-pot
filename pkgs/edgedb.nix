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
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "edgedb";
    repo = "edgedb-cli";
    rev =  "v${version}";
    sha256 = "sha256-fR2wEylJXngiSF0iEGPrB1mrlMskWfUwogamFxOs9oE=";
  };

  cargoSha256 = "sha256-sJu+C3c/cfaMhM1gtlX5w6L9/ds8yjVqz9VuHzHCxkA=";

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