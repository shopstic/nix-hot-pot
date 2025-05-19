{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.3.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-N/UHYtqwLHGxXuG/hO83Ug1Me0/9xgAudhJS+fq2Qek=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-jD2HZXMrrMJoCXT//4Jk6AaGWCwXpFNFEtULNnV2Ikk=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-8hBEaQcvqejTN1Bd4Ur4Ozud62ok87pyxhL1PreL1eY=";
    };
  };
  priority = 10;
})
