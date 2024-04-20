{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-YL27obfAwd83E9LtBvr+tdjhFaCsfaVkHDRxJLf5D9E=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-HBXE/TNwsJp2Mv2YuS0B1TjPraAeeZZe7o6zUW689Zg=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-UEVmwyMkeQgjeuDTkWl3GLfkzYaa4WTXFrrfTWhX3bA=";
    };
  };
  priority = 10;
})
