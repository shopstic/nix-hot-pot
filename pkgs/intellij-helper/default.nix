{ deno
, denort
, runCommand
, makeWrapper
}:
let
  src = ./.;
in
runCommand "intellij-helper"
{
  __noChroot = true;
  nativeBuildInputs = [ deno makeWrapper ];
}
  ''
    mkdir -p $out/bin
    export DENO_DIR=$(mktemp -d)
    export DENORT_BIN="${denort}/bin/denort"
    deno compile -A --check --frozen --output=$out/bin/intellij-helper ${src}/src/intellij-helper.ts
  ''
