{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.18.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-nQ1WQo3rtc9JGlghaExjlesdHPsFBMllF7WQDWCPZYA=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-zrNoym2Y2vC8rUegXDLUFUX2Jj8A7PBmOD9OzAfdYTQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-pS1HMylNYAC9/MaUBXET8FBqVnwt3/yfT77MPGNo7B0=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-qHmn9fvTodPzd6RfzdOZb7Bl6Z+zIdGEDNHDqCyKbNg=";
    };
  };
  priority = 10;
})
