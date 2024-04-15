{ lib, buildGoModule, fetchFromGitHub }:
let bins = [ "regbot" "regctl" "regsync" ]; in
buildGoModule rec {
  pname = "regclient";
  version = "0.6.0";
  tag = "v${version}";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    rev = tag;
    sha256 = "sha256-4lQjjfw/JS/HviDQUGkXGnz9a0lXgecpVQuLFFiEufU=";
  };
  vendorHash = "sha256-t34xd6HHdtN6Eg9ouxgcfU3HYK96wfdMY6Pium9aYBE=";

  outputs = [ "out" ] ++ bins;

  ldflags = [
    "-s"
    "-w"
    "-X main.VCSTag=${tag}"
  ];
  checkPhase = "";

  postInstall =
    lib.concatStringsSep "\n" (
      map
        (bin: ''
          mkdir -p ''$${bin}/bin &&
          mv $out/bin/${bin} ''$${bin}/bin/ &&
          ln -s ''$${bin}/bin/${bin} $out/bin/
        '')
        bins
    );

  meta = with lib; {
    description = "Docker and OCI Registry Client in Go and tooling using those libraries";
    homepage = "https://github.com/regclient/regclient";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}