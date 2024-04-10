{ name
, src
, cacheArgs
, stdenv
, deno
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
      deno cache ${cacheArgs}
    '';
}
