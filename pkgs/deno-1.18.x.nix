{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.18.0";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-oDp4hNB9/K98z/3Pep/qKkoPIAHgnIp80so5XIhNkl8=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-OmWcOjiF3upofIpAHQO3wvyNQq0Q/iqtl8OEu2OWIZw=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-9RQeoHlPjNP0ky2JTsBw3l5ZqSGdGRsfiQu8CgqjUDY=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-tf4G3CgA+CWQL4Zzw8gyHANdxa1lysH3x6Wx7jwV6p8=";
    };
  };
  priority = 10;
})
