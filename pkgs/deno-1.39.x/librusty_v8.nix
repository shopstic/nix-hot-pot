{ rust, stdenv, fetchurl }:
let
  arch = rust.toRustTarget stdenv.hostPlatform;
  fetch_librusty_v8 = args: fetchurl {
    name = "librusty_v8-${args.version}";
    url = "https://github.com/denoland/rusty_v8/releases/download/v${args.version}/librusty_v8_release_${arch}.a";
    sha256 = args.shas.${stdenv.hostPlatform.system};
    meta = { inherit (args) version; };
  };
in
fetch_librusty_v8 {
  version = "0.82.0";
  shas = {
    x86_64-linux = "sha256-2nWOAUuzc7tr0KieeugIqI3zaRruvnLWBPn+ZdHTXsM=";
    aarch64-linux = "sha256-vlc60ZoFtT2Ugp0npT0dep6WWnEBAznR7dYFRaMNAKM=";
    aarch64-darwin = "sha256-ps19JZqCpO3pEAMQZOO+l/Iz7u0dIXLnpYIsnOyAxYk=";
  };
}
