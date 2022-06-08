{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.22.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-ES58d0UdVb9GqxH7lrbHAkc/glDpClLA7ipcwLh3m2w=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-UpBoqeHKyHyYBJCffWym48PDgYrSe7aPWXkRq6Ahclo=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-cYYt8cvf44y1ZB9qxFqV/n1smiiclhLBsFaesvbZHnE=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-Oftjk5UI6joanlxy37sFssUgXoWNSqda2N/udcpuh30=";
    };
  };
  priority = 10;
})
