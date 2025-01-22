{ lib, buildGoModule, fetchFromGitHub }:
let bins = [ "regbot" "regctl" "regsync" ]; in
buildGoModule rec {
  pname = "regclient";
  version = "0.8.0";
  tag = "v${version}";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    rev = tag;
    sha256 = "sha256-vMMRzCI40d33xodOMp+i1SDl1DakuIFk341+/6blKHk=";
  };
  vendorHash = "sha256-yEAzv91EGt+//GWQZM7/w2bI6LztEcIxwKviamhMqwo=";

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