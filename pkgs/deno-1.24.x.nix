{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.24.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-A4aoo6HRma+z083xMICoEjXCYhAyv8Rpw1Wv8mCq/qo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-wI0qALVG3vdUTlCQdDne9Ylz0mi3qD3FgFoKhYrYxSI=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-/v6olzuviJ/RVbFXCGeYLBHKmyEpC3kNIfMAUjDjY80=";
    };
  };
  priority = 10;
})
