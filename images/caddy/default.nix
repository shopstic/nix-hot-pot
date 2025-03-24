{ stdenv
, lib
, nonRootShadowSetup
, runCommand
, buildEnv
, nix2container
, dumb-init
, cacert
, caddy
}:
let
  name = "caddy";
  user = "caddy";
  userUid = 1000;
  shadow = nonRootShadowSetup { inherit user; uid = userUid; shellBin = "/dev/false"; };
  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    paths = [
      dumb-init
      caddy
    ];
    postBuild = ''
      mkdir -p $out/home/${user}
      cp -R ${shadow}/. $out/
    '';
  };

  image =
    nix2container.buildImage
      {
        inherit name;
        tag = caddy.version;
        copyToRoot = [ root-env ];
        maxLayers = 50;
        perms = [
          {
            path = root-env;
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
            "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
          ];
          entrypoint = [ "dumb-init" "--" "caddy" "run" ];
          cmd = [ "--config" "/home/caddy/Caddyfile" "--adapter" "caddyfile" ];
          user = "${user}:${user}";
        };
      };
in
image
