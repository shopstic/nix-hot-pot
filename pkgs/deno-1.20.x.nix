{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.20.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-nO+jbbwoHldfvU4aBWf1O6HrXdO21RZqL5gIwC/l4/8=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-Z6VcTYVXwWWNSTS8PkmquZgmcb0E0S2B+RLrdehU/34=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-H7L+XwOqUXiyAxvhuj4zCxhvmpGi8J7LMtDdlqf1DnE=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-bLKMUC+Pd5k/ab365G/evDVgqZBkX9i0OLMY+/NXUg0=";
    };
  };
  priority = 10;
})
