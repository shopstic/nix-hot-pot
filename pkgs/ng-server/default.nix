{ buildGoModule
, lib
}:
let
  pname = "ng-server";
  version = "1.0.0";
in
buildGoModule rec {
  inherit pname version;
  src = builtins.path
    {
      path = ./.;
      name = "ng-server-src";
      filter = with lib; (path: /* type */_:
        hasInfix "/src" path ||
        hasSuffix "/go.mod" path ||
        hasSuffix "/go.sum" path
      );
    };
  vendorHash = null;
}
