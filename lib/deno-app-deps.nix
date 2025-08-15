{ name
, src
, deno
, stdenv
, denoInstallFlags ? "--frozen"
, preInstall ? ""
, postInstall ? ""
}:
stdenv.mkDerivation {
  inherit name src;
  nativeBuildInputs = [ deno ];
  __noChroot = true;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out"
    export DENO_DIR="$out"
    ${preInstall}
    deno install ${denoInstallFlags}
    ${postInstall}
  '';
}
