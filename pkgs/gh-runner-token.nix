{ buildGoModule
, fetchFromGitHub
, lib
, jq
}:
buildGoModule rec {
  pname = "gh-runner-token";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "XenitAB";
    repo = "github-runner";
    rev = "006d1560b8d18b6b3f7766d11af3b00aedf188f3";
    sha256 = "sha256-M4Csxil9lpoS31eqaTEi1h5Q/L8EAeChnhRUp7KwLds=";
  };

  vendorSha256 = "sha256-btHGPhH+xR0hkylcBLW1gKYYjhva5EzzZh/F3b7XtX0=";

  postInstall = ''
    mv $out/bin/github-runner $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Small tool to generate GitHub Self-hosted runner token using GitHub App";
    homepage = "https://github.com/XenitAB/github-runner";
    license = licenses.mit;
  };
}
