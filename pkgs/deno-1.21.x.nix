{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.21.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-X0gbtjxvZ/q0C9Ovrfa593F4JSgPJtn1NQhfzHEmhCs=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-LrTWiZQon29fH99sdwTOUksb6x8Tcy+T8zy6rx1pV30=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-9PXvRomRfGDIXDG8EyUOsx8HZYoZe/79FnYwd0BfqfM=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-O9uXRunOAhFts8ebAjAdbiduOY2v3G9asqx+laKMhVg=";
    };
  };
  priority = 10;
})
