{ stdenv, lib, zerotierone, fetchFromGitHub, rustPlatform }:
let
  version = "1.10.1";
  src = fetchFromGitHub {
    owner = "zerotier";
    repo = "ZeroTierOne";
    rev = version;
    sha256 = "sha256-Y0klfE7ANQl1uYMkRg+AaIiJYSVPT6zME7tDMg2xbOk=";
  };
in
zerotierone.overrideAttrs (previousAttrs: {
  inherit src version;
  cargoDeps = rustPlatform.fetchCargoTarball {
    src = "${src}/zeroidc";
    name = "${previousAttrs.pname}-${version}";
    sha256 = "sha256-8K4zAXo85MT4pfIsg7DZAO+snfwzdo2TozVw17KhX4Q=";
  };
  postPatch = "cp ${src}/zeroidc/Cargo.lock Cargo.lock";
})
