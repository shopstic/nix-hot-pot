{ buildGoModule
, fetchFromGitHub
, lib
, jq
, oniguruma
}:
buildGoModule rec {
  pname = "faq";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "jzelinskie";
    repo = "faq";
    rev = version;
    sha256 = "sha256-8LEa2dXLwTzm9zn7Vqnh7zMivNHjwhiDxAHLxvplxpw=";
  };

  CGO_CFLAGS="-I${jq.dev}/include";
  CGO_LDFLAGS="-L${jq.lib}/lib -L${oniguruma}/lib";

  vendorSha256 = "sha256-F6CwZuqDObo5zeeJsMdRChi5Mnzz8IbNpNc6aRFZKQo=";

  meta = with lib; {
    description = "faq";
    homepage = "https://github.com/jzelinskie/faq";
    license = licenses.mit;
  };
}
