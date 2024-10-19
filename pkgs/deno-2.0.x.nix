{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper, setFuture ? false }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper setFuture;
  version = "2.0.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-H4lmSQeNF+ozNAGeBOXcGjtPpbaHCVsy2BYn0UvYwnQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-3lGn2C1FQq9hYw8i7oQH6FTxvkOKgaEFtrnPiQUudn4=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-7XwUNetmRcq5pRToF2iauw+B5YVmI3nkduwVbu3b2Fg=";
    };
  };
  priority = 10;
})
