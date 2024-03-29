{ npmlock2nix, nodejs }:
npmlock2nix.v2.build {
  src = ./src;
  inherit nodejs;  
  buildCommands = [ "npm --no-update-notifier run test" ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out/lib
    chmod +x $out/lib/openapi-ts-gen.mjs
    ln -s $out/lib/openapi-ts-gen.mjs $out/bin/openapi-ts-gen
  '';
}
