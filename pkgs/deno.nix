{  autoPatchelfHook, fetchzip, stdenv, version, downloadMap }:
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
    priority = 1;
  };
}
