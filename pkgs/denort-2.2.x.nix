{ autoPatchelfHook, fetchzip, stdenv, lib, makeWrapper }:
(import ./denort.nix rec {
  inherit autoPatchelfHook fetchzip stdenv lib makeWrapper;
  version = "2.2.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-gnbgswrMe6VI3ELqPkHDgBbesJD5szLBF9NWjP+FQFI=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-apple-darwin.zip";
      hash = "sha256-SCDqwopPmeFwQwZWpcOPFLCcHX4G4NEIBXqMTHBUwOk=";
    };
    aarch64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/denort-aarch64-unknown-linux-gnu.zip";
      hash = "sha256-PtPXVutU0EhknPvklurmOmWCsA0PT6eOpErqMIHuYD0=";
    };
  };
  priority = 10;
})
