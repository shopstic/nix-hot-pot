{ stdenv, lib, buildGoModule, fetchFromGitHub }:
let bins = [ "regbot" "regctl" "regsync" ]; in
buildGoModule rec {
  pname = "regclient";
  version = "0.4.3";
  tag = "v${version}";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    rev = tag;
    sha256 = "sha256-CB/a66xNVzmPCoh0yLnOAB/htdp8QkE3MnwH7G2jqSU=";
  };
  vendorSha256 = "sha256-QTeVgvjRw2wBd8QGoVpRVTTh+Wwu2NEZYR1Z9R52/p0=";

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
