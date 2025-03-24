{ lib, buildGoModule, fetchFromGitHub }:
let bins = [ "regbot" "regctl" "regsync" ]; in
buildGoModule rec {
  pname = "regclient";
  version = "0.8.2";
  tag = "v${version}";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    rev = tag;
    sha256 = "sha256-Y+mO/DgJ7CqzDFTNyOMUEOZTnZmOjPu8O4xRO/qGVYY=";
  };
  vendorHash = "sha256-SWkrPpjAA32XkToh7ujSPaRNvHtf2ymvx5E7iGD5B8k=";

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
  };
}