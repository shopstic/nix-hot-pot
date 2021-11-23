{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "manifest-tool";
  version = "ce6dc769d3a124bde302ec8fb6243955d7f3d05e";

  src = fetchFromGitHub {
    owner = "estesp";
    repo = "manifest-tool";
    rev = "${version}";
    sha256 = "sha256-Ka7o2642JMd2JcqzILRFH7PmUB2ZwkIi0j8GhFGY/pA=";
  };

  vendorSha256 = null;

  modRoot = "./v2";

  meta = with lib; {
    description = "Manifest tool";
    homepage = "https://github.com/estesp/manifest-tool";
    license = licenses.mit;
  };
}
