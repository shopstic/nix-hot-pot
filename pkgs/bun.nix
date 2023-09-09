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
  pname = "bun";

  src = let download = downloadMap.${stdenv.system}; in
    fetchzip {
      name = "bun-${version}";
      url = download.url;
      sha256 = download.hash;
    };

  nativeBuildInputs = [ makeWrapper ] ++ (lib.optionals (stdenv.isLinux) [ autoPatchelfHook stdenv.cc.cc.libgcc ]);

  installPhase = ''
    if [ -f ./bun ]; then
      install -m755 -D ./bun $out/bin/bun
    else
      install -m755 -D ./bun-*/bun $out/bin/bun
    fi
    ln -s $out/bin/bun $out/bin/bun-${version}
  '';

  meta = with stdenv.lib; {
    inherit priority;
    homepage = https://github.com/oven-sh/bun;
    description = "Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one";
    platforms = builtins.attrNames downloadMap;
  };
}
