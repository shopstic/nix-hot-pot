{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "manifest-tool";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "estesp";
    repo = "manifest-tool";
    rev = "v${version}";
    sha256 = "sha256-sApg6qsnpyg7D4x/SMgTdTtgpVNvMt1l6mHszmLqFtE=";
  };

  vendorSha256 = null;

  modRoot = "./v2";

  meta = with lib; {
    description = "Manifest tool";
    homepage = "https://github.com/estesp/manifest-tool";
    license = licenses.mit;
  };
}
