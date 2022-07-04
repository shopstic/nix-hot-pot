{ autoPatchelfHook, fetchzip, stdenv, lib }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib;
  version = "1.23.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-7tFJ8BXRNB462F0Z7brltaah/qo6XjXQU4kRtTgHx14=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-JuzrDgdOAU9dzTIQpon7gwNXM95imM6ncOyYmJqStfk=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-2eEoppOFICr+6ekiZVzOmJUJgM4WhmG3U8OsYGsfnJA=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-YydTyF/87U7uCb/RFHuk6Bw3ij1DYGvp5sFy+zDy2Eo=";
    };
  };
  priority = 10;
})
