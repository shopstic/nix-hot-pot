{ name
, config-file
, lock-file
, deno
, preCache ? ""
, postCache ? ""
, runCommand
}:
runCommand name
{
  nativeBuildInputs = [ deno ];
  __noChroot = true;
} ''
  mkdir $out
  export DENO_DIR=$out
  TEMP_OUT="$(mktemp -d)"
  shopt -s globstar
  ${preCache}
  deno install --config="${config-file}" --lock=${lock-file} --frozen=true --root="$TEMP_OUT"
  ${postCache}
''
