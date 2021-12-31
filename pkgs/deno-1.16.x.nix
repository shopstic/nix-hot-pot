{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.16.3";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-cAd8z7s8OhXJsXYXxm7ai3EpILOD/wQl322UA9L2dic=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-mHjex6YvgNnc7V1no2NZ9EBWh1U9ZkDw6juqgDdq+WA=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-SluL20yYjkl2AARUEMVI4WW+QEGQPsnNLwlMTJdk8e8=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-tHUQ3+2l5z+VkF9+uQiPBC6EiSBcjlO3xYS4jsBCPpk=";
    };
  };
})
