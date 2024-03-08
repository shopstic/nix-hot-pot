{ nix2container
, stdenv
, coreutils
, writeShellScript
}:
let
  name = "lib-yourkit-agent";
  version = "2023.9-b109";
  agentLib =
    if stdenv.isx86_64 then
      ./libs/amd64-libyjpagent.so else
      ./libs/arm64-libyjpagent.so;
  entrypoint = writeShellScript "entrypoint.sh" ''
    ${coreutils}/bin/cp ${agentLib} /target/libyjpagent.so
  '';
in
nix2container.buildImage
{
  inherit name;
  tag = version;
  config = {
    Entrypoint = [ entrypoint ];
  };
}

