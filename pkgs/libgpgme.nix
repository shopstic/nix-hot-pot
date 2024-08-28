{ runCommand, gpgme }:
runCommand "gpgme" { } ''
  mkdir -p $out
  find ${gpgme}/lib \( -name "libgpgme.so" -or -name "libgpgme.dylib" \) -exec cp {} $out/ \;
''
