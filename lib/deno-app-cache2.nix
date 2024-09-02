{ name
, lock-file
, deno
, preCache ? ""
, postCache ? ""
, runCommand
, jq
}:
runCommand name
{
  nativeBuildInputs = [ deno jq ];
  __noChroot = true;
} ''
  mkdir $out
  export DENO_DIR=$out
  TEMP_OUT="$(mktemp -d)"
  shopt -s globstar
  ${preCache}
  cp "${lock-file}" ./deno.lock
  jq -er '{ imports: .specifiers }' < deno.lock > deno.json
  deno install --config=deno.json --lock=./deno.lock --check --root="$TEMP_OUT"
  ${postCache}
''
