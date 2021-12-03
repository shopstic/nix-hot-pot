{ autoPatchelfHook, fetchzip, stdenv }:
let
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
in
stdenv.mkDerivation {
  inherit version;
  pname = "deno";

  src = let download = downloadMap.${stdenv.system}; in fetchzip {
    name = "deno-${version}";
    url = download.url;
    sha256 = download.hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    install -m755 -D deno $out/bin/deno
    ln -s $out/bin/deno $out/bin/deno-${version}
  '';

  meta = with stdenv.lib; {
    homepage = https://deno.land;
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = builtins.attrNames downloadMap;
    priority = 10;
  };
}
