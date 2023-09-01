{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, nix2container
, dumb-init
, ng-server
}:
let
  name = "ng-server";
  user = "ng-server";
  userUid = 1000;
  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "/dev/false"; };
  home-dir = runCommand "home-dir" { } ''mkdir -p $out/home/${user}'';
  nix-bin = buildEnv {
    name = "nix-bin";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      ng-server
    ];
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        tag = ng-server.version;
        copyToRoot = [ nix-bin shadow home-dir ];
        maxLayers = 50;
        perms = [
          {
            path = home-dir;
            regex = "/home/${user}";
            mode = "0755";
            gid = userUid;
            uid = userUid;
          }
        ];
        config = {
          volumes = {
            "/home/${user}" = { };
          };
          env = [
            "PATH=/bin"
          ];
          entrypoint = [ "dumb-init" "--" "ng-server" ];
          user = "${user}:${user}";
        };
      };
in
image
