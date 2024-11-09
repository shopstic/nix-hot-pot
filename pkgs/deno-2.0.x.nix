{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.0.5";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-iV93ub08TCE/5DD9S23qwqzCcJ9b9qezNBAWu1tzX2w=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-Fwr8bxRuht+veTmCe0D48ypvI6YqzBOcTMeWb+Qi54s=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-igyhqJ+ECdEOjDffeLdGABw2omjQxuArlA20YNAsEYM=";
    };
  };
  priority = 10;
})
