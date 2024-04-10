{ name
, src
, cacheArgs
, stdenv
, deno
, preCache ? ""
, postCache ? ""
}:
stdenv.mkDerivation
{
  inherit src;
  name = "${name}-cache";
  nativeBuildInputs = [ deno ];
  __noChroot = true;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    ''
      mkdir $out
      export DENO_DIR=$out
      shopt -s globstar
      ${preCache}
      deno cache ${cacheArgs}
      ${postCache}
    '';
}
