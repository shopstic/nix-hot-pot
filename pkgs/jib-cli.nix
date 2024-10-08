{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, jre }:
let
  version = "0.13.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "jib-cli";

  src = fetchzip {
    name = "jib-cli-${version}";
    url = "https://github.com/GoogleContainerTools/jib/releases/download/v${version}-cli/jib-jre-${version}.zip";
    sha256 = "sha256-3/wKpwVHVBU86GJfR4YGM5ba8pOOfLL+fKU7zwwU+Qc=";
  };

  nativeBuildInputs = (lib.optionals (stdenv.isLinux) [ autoPatchelfHook ]) ++ [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
    wrapProgram $out/bin/jib --set JAVA_HOME ${jre} --set JIB_OPTS "-Djib.disableUpdateChecks=true"
  '';

  meta = {
    homepage = "https://github.com/GoogleContainerTools/jib";
    description = "Build container images for your Java applications.";
    platforms = lib.platforms.all;
  };
}
