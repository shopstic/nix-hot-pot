{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.19.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-J8WjTdkxGbY8DDwBZjhxW9c9sF5HNfia0tcrEDWgjQ4=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-pAgxVdF2jKkJdVv2qPYl1FLBdxHJExAtkk3TLzb6TRY=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-ZWw1ZJnxB1ri9yvG0+0Gvi/qBkRBsf5a5aApRfK1pJo=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-wLi0REqLyRCjva11XS1VG0K5+MW3UzulgbgD7r+WL78=";
    };
  };
  priority = 10;
})
