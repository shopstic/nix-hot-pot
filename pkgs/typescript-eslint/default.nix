{ npmlock2nix
, runCommandLocal
, nodejs
}:
let
  src = ./src;
  mod = npmlock2nix.v2.node_modules {
    inherit src nodejs;
  };
in
runCommandLocal "typescript-eslint" { } ''
  mkdir -p $out/bin
  ln -s "${mod}/bin/eslint" $out/bin/eslint
  ln -s "${mod}/node_modules" $out/node_modules
''

