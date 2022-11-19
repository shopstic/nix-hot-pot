{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.28.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-FYs9kVPzl+dYi7A7dGcc4jHd8XLgddTDzhDzyt5bFTk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-VmynxQHTo7TkDBz2SLHmEH6MaVMUt47xGfgVYPFgmy4=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-MRUie1SH4p12ke2adxrPUy2W0RnGV6vBwz8SrTrwo3w=";
    };
  };
  priority = 10;
})
