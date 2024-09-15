{ runCommand, sqlite }:
runCommand "libsqlite" { } ''
  mkdir -p $out
  find ${sqlite.out}/lib \( -name "libsqlite3.so" -or -name "libsqlite3.dylib" \) -exec cp {} $out/ \;
''
