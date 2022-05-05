{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, jre }:
let
  version = "0.10.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "jib-cli";

  src = fetchzip {
    name = "jib-cli-${version}";
    url = "https://github.com/GoogleContainerTools/jib/releases/download/v0.10.0-cli/jib-jre-0.10.0.zip";
    sha256 = "sha256-/U8jAvPUX3nsEMSxLoLdOp1MGAXskp0vcv/LwSSccJ0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook 
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
    wrapProgram $out/bin/jib --set JAVA_HOME ${jre}
  '';

  meta = {
    homepage = https://github.com/GoogleContainerTools/jib;
    description = "Build container images for your Java applications.";
    platforms = lib.platforms.all;
  };
}
