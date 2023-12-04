{ buildGoModule
, lib
}:
let
  pname = "pcap-ws";
  version = "0.1.0";
in
buildGoModule rec {
  inherit pname version;
  src = builtins.path
    {
      path = ./.;
      name = "pcap-ws-src";
      filter = with lib; (path: /* type */_:
        hasInfix "/src" path ||
        hasSuffix "/go.mod" path ||
        hasSuffix "/go.sum" path
      );
    };
  vendorHash = "sha256-FBMdZ+M6zLEpQ/4C92GTFESjiSA0UoP2gA+YucQ+scQ=";
}
