{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "manifest-tool";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "estesp";
    repo = "manifest-tool";
    rev = "v${version}";
    sha256 = "sha256-vngPjWzlWOOR+L1yaQXnlZTofz97JpPmdtsqj5G7Us8=";
  };

  vendorHash = null;

  modRoot = "./v2";

  meta = with lib; {
    description = "Manifest tool";
    homepage = "https://github.com/estesp/manifest-tool";
    license = licenses.mit;
  };
}
