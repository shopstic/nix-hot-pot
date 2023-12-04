{ buildGoModule
, lib
}:
let
  pname = "aws-batch-routes";
  version = "0.1.0";
in
buildGoModule rec {
  inherit pname version;
  src = builtins.path
    {
      path = ./.;
      name = "aws-batch-routes-src";
      filter = with lib; (path: /* type */_:
        hasInfix "/src" path ||
        hasSuffix "/go.mod" path ||
        hasSuffix "/go.sum" path
      );
    };
  vendorHash = "sha256-rxXhbdOMOPDZ1Bq7UQDfeohMc+udco9q+yAuMLuJ/cg=";
}
