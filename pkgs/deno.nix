{ autoPatchelfHook, fetchzip, stdenv, version, downloadMap, priority }:
stdenv.mkDerivation {
  inherit version;
  pname = "deno";

  src = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "deno-${version}";
      url = download.url;
      sha256 = download.hash;
    };

  nativeBuildInputs =
    if stdenv.isLinux then [
      autoPatchelfHook
    ] else [ ];

  installPhase = ''
    install -m755 -D deno $out/bin/deno
    ln -s $out/bin/deno $out/bin/deno-${version}
  '';

  meta = with stdenv.lib; {
    inherit priority;
    homepage = https://deno.land;
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = builtins.attrNames downloadMap;
  };
}
