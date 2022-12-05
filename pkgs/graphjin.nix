{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "graphjin";
  version = "0.21.9";

  src = fetchFromGitHub {
    owner = "dosco";
    repo = "graphjin";
    rev = "v${version}";
    sha256 = "sha256-Eikg41qeY1TgZ8esuwIMn38MZkwJw7SBykHib6n+mDI=";
  };

  vendorSha256 = "sha256-CzTQWVw0JE4SME7i8dOe6kCPg1S8Lmx5GYfO05GSR+Q=";

  doCheck = false;

  meta = with lib; {
    description = "GraphJin";
    homepage = "https://github.com/dosco/graphjin";
    license = licenses.asl20;
  };
}
