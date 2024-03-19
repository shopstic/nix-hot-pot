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
  pname = "denort";

  src = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "denort-${version}";
      url = download.url;
      sha256 = download.hash;
      stripRoot = false;
    };

  nativeBuildInputs = [ makeWrapper ] ++ (lib.optionals (stdenv.isLinux) [ autoPatchelfHook stdenv.cc.cc.libgcc ]);

  installPhase = ''
    install -m755 -D denort $out/bin/denort
    ln -s $out/bin/denort $out/bin/denort-${version}
  '';

  meta = with stdenv.lib; {
    inherit priority;
    homepage = "https://deno.land";
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = builtins.attrNames downloadMap;
  };
}
