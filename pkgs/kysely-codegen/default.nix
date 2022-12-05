{ npmlock2nix }:
npmlock2nix.build {
  src = ./src;
  buildCommands = [ "npm --no-update-notifier run test" ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out/lib
    ln -s $out/lib/node_modules/.bin/kysely-codegen $out/bin/kysely-codegen
  '';
}
