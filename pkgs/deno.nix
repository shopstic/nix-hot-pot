{ autoPatchelfHook, fetchzip, stdenv }:
let
  version = "1.16.2";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-YOPFvQ1cv3UE8z3TNqAn9UteJUFGz8zn1Z+e9wkF+TQ=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-o5GryK4m9iXW3QPKXO5PQ/Ka9XFgfdahtccSOvEeh1o=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-SxAXNC5K2TxTI3tVvxPRB10/UCE/16RihtASzGqfhWo=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-qD8ntmPeNQEfEsRZQAR0tlEKh8KBYo57wsiP9nmsgzw=";
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
  '';

  meta = with stdenv.lib; {
    homepage = https://deno.land;
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = builtins.attrNames downloadMap;
  };
}
