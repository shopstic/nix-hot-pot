{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, pkg-config
, btrfs-progs
, gpgme
, lvm2
}:

buildGoModule rec {
  pname = "dive";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "wagoodman";
    repo = "dive";
    rev = "v${version}";
    hash = "sha256-/pjIousIxEOjbjzHVoB4kJ4phDM=";
  };

  vendorHash = lib.fakeHash;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.isLinux [ btrfs-progs gpgme lvm2 ];

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  meta = with lib; {
    description = "A tool for exploring each layer in a docker image";
    homepage = "https://github.com/wagoodman/dive";
    changelog = "https://github.com/wagoodman/dive/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ marsam SuperSandro2000 ];
  };
}