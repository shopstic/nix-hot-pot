{ buildGoModule
, lib
}:
let
  pname = "periodic-exec";
  version = "0.1.0";
in
buildGoModule rec {
  inherit pname version;
  src = builtins.path
    {
      path = ./.;
      name = "${pname}-src";
      filter = with lib; (path: /* type */_:
        hasInfix "/src" path ||
        hasSuffix "/go.mod" path ||
        hasSuffix "/go.sum" path
      );
    };

  vendorHash = "sha256-kTgoLlnpOnsHPn0vDfHg8RNff1j63bfBxQ7XdgSdl+w=";
}
