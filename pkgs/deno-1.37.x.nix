{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.37.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-Auys5N2rxqv/xrjz57oewSc8fxnEpjMbW9YnhTa88dw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-i6hy/sEHfbqGebIfc929OXzp4FFXqAaNdOBkksAoID4=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-WLTSLEd1ggpzDLkzAyTH40BBeMfR2ENxVIg2aw6K/mY=";
    };
  };
  priority = 10;
})
