{ stdenv, lib, zerotierone }:
let
  version = "1.10.1";
  src = fetchFromGitHub {
    owner = "zerotier";
    repo = "ZeroTierOne";
    rev = version;
    sha256 = "";
  };
in
zerotierone.overrideAttrs (previousAttrs: {
  inherit src version;
  cargoDeps = rustPlatform.fetchCargoTarball {
    src = "${src}/zeroidc";
    name = "${pname}-${version}";
    sha256 = "";
  };
  postPatch = "cp ${src}/zeroidc/Cargo.lock Cargo.lock";
})