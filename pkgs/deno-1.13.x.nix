{ autoPatchelfHook, fetchzip, stdenv }:
(import ./deno.nix rec {
  inherit autoPatchelfHook fetchzip stdenv;
  version = "1.13.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-xZubHgVMbT8gtlrsn/3zQAf8nnStxlrOistC/GfeZ3E=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-aqCGqjE/qtDH3IzGyoKPBDr2kV+GAA04krEqbfSsf+k=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-oxyUt26ikYd0KRAe1Ovq5bjwFsrZoSPnjiF1xx6/0vU=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-mOuqlSrPleQaC5sf1mlZtuL+isWXM6zZ/1PyoAqxdTo=";
    };
  };
  priority = 20;
})
