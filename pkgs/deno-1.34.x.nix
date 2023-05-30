{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.34.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-f5zJ/hU7PcVcLt2Jzr2I2/jqrXfT0HIdE9hbMeguhbk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-hu/K+dAlo/GJS41U/3Xwk15f7Nyd6tnrhnGP6Ma/n8A=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-urlqcZv/+As6D1ZwAhIw0DPunbTFbZnYhh/mgUMv3dA=";
    };
  };
  priority = 10;
})
