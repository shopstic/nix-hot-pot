{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.1.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-gVZJm5LVBEqa4pzN0UvoSyDh92h54y4J+XFNEvrNPCo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-HRemHnzaT5Y8acrAgzHcnrndwKP8jj9cv2n60pG4JEc=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-EVCaUoxK69TUROl5EFB4N7/CV/YQqlfluciy8lMJdsg=";
    };
  };
  priority = 10;
})
