{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.21.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-nCZ9bm4YJXJdzsOZjy4LU30kGbC7poh/pR1fLREIXM0=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-BKs/v+R4IRn48Q5oAdRNb1ih3MnZK98EonwzAQd6yaQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-bxAUdTL1oRNVSVN71dNOgdHexhIeAWcS7y0cAKdUxd0=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-r6Zsq6AYxly520dLmu4Zw7BrK9AU9cJCzCFlezDaxDc=";
    };
  };
  priority = 10;
})
