{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.20.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-CoNCu8ybUUsnICXK2Q6ZbUmg1lrLP7PrknHopsDydRA=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-hjnNncKA/qjVMJ5CJEOIMg9KwTxSlMx0ruqOXdU6GiU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-bYPnkXFp5zxfILAcYqMggksgeDVgKlgmW8nCIKa1rzU=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-4gCXMIQePn+I+5M3KAft+Lpv6T5xZZqsgQC50iypHVU=";
    };
  };
  priority = 10;
})
