{
  description = "Periodic exec";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flakeUtils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flakeUtils }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        vscodeSettings = pkgs.writeTextFile {
          name = "vscode-settings.json";
          text = builtins.toJSON {
            "go.goroot" = "${pkgs.go}/share/go";
            "go.alternateTools" = {
              "go" = "${pkgs.go}/bin/go";
              "gopls" = "${pkgs.gopls}/bin/gopls";
              "dlv" = "${pkgs.delve}/bin/dlv";
            };
            "go.formatTool" = "default";
            "nix.enableLanguageServer" = true;
            "nix.formatterPath" = pkgs.nixpkgs-fmt + "/bin/nixpkgs-fmt";
            "nix.serverPath" = pkgs.nil + "/bin/nil";
            "nix.serverSettings" = {
              "nil" = {
                "formatting" = {
                  "command" = [ "nixpkgs-fmt" ];
                };
              };
            };
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          shellHook = ''
            mkdir -p ./.vscode
            cat ${vscodeSettings} > ./.vscode/settings.temp.json
            cat ./.vscode/settings.temp.json | jq --arg gopath "$PWD/.go" --arg toolsgopath "$PWD/.gotools" '."go.gopath"=$gopath | ."go.toolsGopath"=$toolsgopath' > ./.vscode/settings.json
            rm -f ./.vscode/settings.temp.json
            export GOPATH=$PWD/.go
          '';
          buildInputs = builtins.attrValues {
            inherit (pkgs)
              jq
              go
              gotools
              gopkgs;
          };
        };
      });
}
