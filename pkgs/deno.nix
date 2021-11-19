{ autoPatchelfHook, fetchzip, stdenv }:
let
  version = "1.16.1";
  downloadMap = {
    x86_64-linux = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
      hash = "sha256-S8uo+anDgJ9qR8oNU7S8+Y53oxoeUCKNdv0y8gaTAKg=";
    };
    x86_64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-apple-darwin.zip";
      hash = "sha256-N5pXxV+RFfpy2WiApHVxvryfjVf6Rp4aieUPswTTpr8=";
    };
    aarch64-darwin = {
      url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
      hash = "sha256-vodjVIHZRgIUPZLdyV9l1iB117JFFa/CUeqvxOr27IA=";
    };
    aarch64-linux = {
      url = "https://github.com/LukeChannings/deno-arm64/releases/download/v${version}/deno-linux-arm64.zip";
      hash = "sha256-OiceQJjT2Uk/FctiUqoxzlWCBMoBoMpYJJeBeeVZ4Zw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "deno";
  version = version;

  src = let download = downloadMap.${stdenv.hostPlatform.system}; in fetchzip {
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
