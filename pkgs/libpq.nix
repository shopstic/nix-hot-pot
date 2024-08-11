{ runCommand, postgresql }:
runCommand "libpq" { } ''
  mkdir -p $out
  find ${postgresql.lib}/lib \( -name "libpq.so" -or -name "libpq.dylib" \) -exec cp {} $out/ \;
''
