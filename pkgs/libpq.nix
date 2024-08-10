{ runCommand, postgresql }:
runCommand "libpq" { } ''
  mkdir -p $out
  find ${postgresql.lib}/lib -name "libpq.so" -o -name "libpq.dylib" -exec cp {} $out/ \;
''
