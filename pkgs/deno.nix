{ autoPatchelfHook
, fetchzip
, stdenv
, lib
, version
, downloadMap
, priority
, makeWrapper
}:
stdenv.mkDerivation {
  inherit version;
  pname = "deno";

  src = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "deno-${version}";
      url = download.url;
      sha256 = download.hash;
      stripRoot = false;
    };

  nativeBuildInputs = [ makeWrapper ] ++ (lib.optionals (stdenv.isLinux) [ autoPatchelfHook stdenv.cc.cc.libgcc ]);

  installPhase = ''
    install -m755 -D deno $out/bin/deno
    wrapProgram "$out/bin/deno" --set DENO_NO_UPDATE_CHECK 1
    ln -s $out/bin/deno $out/bin/deno-${version}
  '';

  meta = with stdenv.lib; {
    inherit priority;
    homepage = https://deno.land;
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = builtins.attrNames downloadMap;
  };
}
