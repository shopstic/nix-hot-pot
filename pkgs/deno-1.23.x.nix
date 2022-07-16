{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.23.4";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-CmI68Mil1xQwN8zEXvOmnRcQL78eKqi2CS3ijyRHLGo=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-pHBhFLeM5eA79hyIipDSvuJjHlxYt5rSY1zJDCmJfiU=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-TZLb126rYJTuqDk4Qak9SY+M1Gq9ssMOq6AQaCMGJRQ=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-8hG6CqDQNg0cYLzzjZOgHW2UNMPV+BEfW0p7+2MzTlk=";
    };
  };
  priority = 10;
})
