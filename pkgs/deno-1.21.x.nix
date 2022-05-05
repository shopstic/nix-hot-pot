{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.21.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-FxuRAHRp6TcaWedPAPAbcc0+ooH79yR3rmLriEWZZm8=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-WTHCLbrYVtrKHu8upUHCj9GrE6M3Y67M9T7wPA5pBGI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-HzKchkW7M5ErjdohR3+9wXms7CA2hWstuHtjjwPaAsw=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-prqdzTXrbzhHP/wUvIsiTwG1vzXULevTcUJcZZD31lA=";
    };
  };
  priority = 10;
})
