{ lib, buildGoModule, fetchFromGitHub }:
let bins = [ "regbot" "regctl" "regsync" ]; in
buildGoModule rec {
  pname = "regclient";
  version = "0.9.0";
  tag = "v${version}";

  src = fetchFromGitHub {
    owner = "regclient";
    repo = "regclient";
    rev = tag;
    sha256 = "sha256-FVXTEP1CNlKmuorNxRE2SeiA90u2rz8sXELBtfRm9z0=";
  };
  vendorHash = "sha256-MP/drjUbST5s3NKQ6omVOLSvl4rdPSfVaM0zlF/9Cq0=";

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