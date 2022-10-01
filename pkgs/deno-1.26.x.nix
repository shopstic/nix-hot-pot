{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.26.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-acSNg5nyWCp/PmXe1ZgQ7F+CuySMJGusfqukTBQS+Qo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-UvHVp3HRjLUjnbCvEAtYAE7SZaQ66TBEF6RWdjz4A0k=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-sO7Q5YDKe3cSFwjFbcwkZOkH+m/vRu3QNp5LHmEvGs8=";
    };
  };
  priority = 10;
})
