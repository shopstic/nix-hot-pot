{ lib
, buildGoModule
, fetchFromGitHub
, stdenv
, xorg
}:
buildGoModule rec {
  pname = "otel-tui";
  version = "0.5.3";

  # Disable Go workspace mode to allow go mod vendor
  env.GOWORK = "off";

  # Add X11 development libraries for CGO dependencies (Linux only)
  buildInputs = lib.optionals stdenv.isLinux [ xorg.libX11 ];

  src = fetchFromGitHub {
    owner = "ymtdzzz";
    repo = "otel-tui";
    rev = "v${version}";
    hash = "sha256-tlUv8nI2KKhlp8jofAstwhYm0KwpSz2QGuZg52hjGyA=";
  };

  subPackages = [ "." ];
  
  ldflags = [
    "-s"
    "-w"
    "-X github.com/ymtdzzz/otel-tui/cmd.version=${version}"
    "-X github.com/ymtdzzz/otel-tui/cmd.commit=${src.rev}"
    "-X github.com/ymtdzzz/otel-tui/cmd.date=1970-01-01T00:00:00Z"
  ];
  vendorHash = "sha256-Q43ODAYYx5XfXirviRhaYdb0a20HVsA1+8cLb8hyFws=";

  meta = with lib; {
    description = "A terminal OpenTelemetry viewer inspired by otel-desktop-viewer";
    homepage = "https://github.com/ymtdzzz/otel-tui";
    changelog = "https://github.com/ymtdzzz/otel-tui/releases/tag/v${version}";
    license = licenses.asl20;
    mainProgram = "otel-tui";
    maintainers = with maintainers; [
      nktpro
    ];
  };
}
