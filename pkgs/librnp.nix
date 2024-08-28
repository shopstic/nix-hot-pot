{ runCommand, rnp }:
runCommand "librnp" { } ''
  mkdir -p $out
  find ${rnp.lib}/lib \( -name "librnp.so" -or -name "librnp.dylib" \) -exec cp {} $out/ \;
''
