{ lib, runCommand }:
files:
let
  transformed = lib.mapAttrsToList
    (name: value: {
      inherit value;
      dest = name;
      envName = "file_" + (builtins.replaceStrings [ "/" ] [ "_" ] name);
    })
    files;
  commands = builtins.concatStringsSep "\n" (map
    (x: ''
      mkdir -p "$out/$(dirname ${x.dest})"
      mv "''$${x.envName}Path" "$out/${x.dest}"
    '')
    transformed);
  toPass = builtins.listToAttrs (map (x: { name = x.envName; value = x.value; }) transformed);
in
runCommand "files"
  (
    toPass // {
      runLocal = true;
      passAsFile = (map (x: x.envName) transformed);
    }

  )
  commands
