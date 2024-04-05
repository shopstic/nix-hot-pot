{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "1.42.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-YyxnwO50w4/1pt7PxwqZlSM4leJ+wjMG2eO+7JnNmWg=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-uZH3M4WKcU2Q9rm1FAv1QmEox+7PKSq+Sd83x3fzl3I=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-kBUBpD0NnSQspynCBLqYxBW4SUv8SzcsPqGZQOm0rnk=";
    };
  };
  priority = 10;
})
