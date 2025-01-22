{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "manifest-tool";
  version = "2.1.9";

  src = fetchFromGitHub {
    owner = "estesp";
    repo = "manifest-tool";
    rev = "v${version}";
    sha256 = "sha256-8i39G1J3YLTX48lxIZ2IlHUR4huDSsVdPMl0CknbF0I=";
  };

  vendorHash = null;

  modRoot = "./v2";

  meta = with lib; {
    description = "Manifest tool";
    homepage = "https://github.com/estesp/manifest-tool";
    license = licenses.mit;
  };
}
