{ runCommand, libevent }:
runCommand "libevent-core" { } ''
  mkdir -p $out
  find ${libevent}/lib \( -name "libevent_core.so" -or -name "libevent_core.dylib" \) -exec cp {} $out/ \;
''
