{ pkgs }:
let 
  version = "0.3.10";
in
pkgs.callPackage "${pkgs.path}/pkgs/development/tools/regclient" {
  buildGoModule = args: pkgs.buildGoModule (args // {
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "regclient";
      repo = "regclient";
      rev = "v${version}";
      sha256 = "sha256-3nYVhKHNz0V0j6JlZ5Dm5TFWA2kmUhshNVUym/QWSyM=";
    };
    vendorSha256 = "sha256-rj4sQ8Ci2KMayJNXn+KVihOiZehk233l48Ps0yjOOE4=";
  });
}
