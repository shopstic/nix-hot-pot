{ pkgs }:
let
  version = "0.4.2";
in
pkgs.callPackage "${pkgs.path}/pkgs/development/tools/regclient" {
  buildGoModule = args: pkgs.buildGoModule (args // {
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "regclient";
      repo = "regclient";
      rev = "v${version}";
      sha256 = "sha256-lx2IQ3NpFuVr4Vb7vFcp/QVZBlLzi4VXFE7Sw3LKIXE=";
    };
    vendorSha256 = "sha256-9DcmUYwG+CoT8hmoI7FHl7td1bBukpN/FJT3iiCAkHU=";
    checkPhase = "";
  });
}
