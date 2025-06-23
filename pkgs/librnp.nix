{ runCommand, rnp, fetchFromGitHub }:
let
  overriddenRnp = rnp.overrideAttrs (oldAttrs: rec {
    version = "0.18.0";
    src = fetchFromGitHub {
      owner = "rnpgp";
      repo = "rnp";
      rev = "v${version}";
      hash = "sha256-DixJhN4/iSgMkcJ0run4gwFZoUeMMiNSwWDGjT94cNM=";
    };
  });
in
runCommand "librnp" { } ''
  mkdir -p $out
  find ${overriddenRnp.lib}/lib \( -name "librnp.so" -or -name "librnp.dylib" \) -exec cp {} $out/ \;
''
