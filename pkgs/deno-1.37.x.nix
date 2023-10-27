{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.37.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-317we83ka5dxp+mnn64XQHOEEiwVLzT75/rU/i5OVos=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-a0/eou2ZRoFtBmiCIblMOd+C2jEbJOjTNJ/PP9UsW4A=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-YqNixf5Z/8YEmPt3ZGfaOJFGfcAlktMo1KXZQra/q3s=";
    };
  };
  priority = 10;
})
