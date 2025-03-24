{ stdenv
, lib
, nonRootShadowSetup
, writeTextFiles
, writeShellScriptBin
, nix2container
, runCommand
, buildEnv
, glibcLocales
, dumb-init
, cacert
, nix
, gnugrep
, rsync
, curl
, docker
, openssh
, git
, yj
, jq
, iproute2
, less
, direnv
, nix-direnv
, fzf
, amazon-ecr-credential-helper
, ubuntu-base-image
}:
let
  name = "remote-dev";
  version = "1.0.0";

  docker-slim = docker.override {
    buildxSupport = false;
    composeSupport = false;
  };

  wrapped-nix = writeShellScriptBin "nix" ''
    exec ${nix}/bin/nix "$@" 2> >(${gnugrep}/bin/grep -v "^evaluating file '.*'$" >&2)
  '';

  user = "nix";
  userUid = 1000;

  nixbldUserCount = 64;

  root-files = writeTextFiles {
    "etc/shadow" = ''
      root:!x:::::::
      sshd:!x:::::::
      ${user}:*:::::::
      ${lib.concatMapStringsSep "\n" (x: "nixbld${toString x}:!:18610:0:99999:7:::") (lib.range 0 nixbldUserCount)}
    '';
    "etc/passwd" = ''
      root:x:0:0::/root:/bin/bash
      sshd:x:999:999:::/bin/bash
      ${user}:x:${toString userUid}:${toString userUid}::/home/${user}:/bin/bash
      ${lib.concatMapStringsSep "\n" (x: "nixbld${toString x}:x:${toString (x + 30000)}:30000::/dev/null:") (lib.range 0 nixbldUserCount)}
    '';
    "etc/group" = ''
      root:x:0:0::/root:/bin/bash
      sshd:x:999:999:::/bin/bash
      ${user}:x:${toString userUid}:${toString userUid}::/home/${user}:/bin/bash
      nixbld:x:30000:${lib.concatMapStringsSep "," (x: "nixbld${toString x}") (lib.range 0 nixbldUserCount)}
    '';
    "etc/gshadow" = ''
      root:x::
      sshd:x::
      ${user}:x::
      nixbld:!::${lib.concatMapStringsSep "," (x: "nixbld${toString x}") (lib.range 0 nixbldUserCount)}
    '';
    "home/${user}/.docker/config.json" = builtins.toJSON {
      credHelpers = {
        "public.ecr.aws" = "ecr-login";
      };
    };
    "etc/environment" = builtins.concatStringsSep "\n" env;
    "etc/profile.d/02-environment.sh" = builtins.concatStringsSep "\n" (map (x: "export " + x) env);
    "etc/bash.bashrc" = ''
      source /etc/environment

      [ -z "$PS1" ] && return
      shopt -s checkwinsize

      # set variable identifying the chroot you work in (used in the prompt below)
      if [ -z "''${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
          debian_chroot=$(cat /etc/debian_chroot)
      fi

      # set a fancy prompt (non-color, overwrite the one in /etc/profile)
      # but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
      if ! [ -n "''${SUDO_USER}" -a -n "''${SUDO_PS1}" ]; then
        PS1=${"'"}''${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
      fi

      eval "$(direnv hook bash)"
      source ${nix-direnv}/share/nix-direnv/direnvrc
      source ${fzf}/share/fzf/completion.bash
      source ${fzf}/share/fzf/key-bindings.bash
    '';
    "etc/ssh/sshd_config" = ''
      Port 2222
      HostKey /etc/ssh/ssh_host_ed25519_key
      PermitRootLogin yes
      PasswordAuthentication no
      AuthorizedKeysFile %h/.ssh/authorized_keys
      LogLevel INFO
    '';
    "etc/nix/nix.conf" = ''
      max-jobs = auto
      cores = 0
      sandbox = relaxed
      substituters = https://cache.nixos.org?priority=40 https://nix.shopstic.com?priority=60
      trusted-public-keys = nix-cache:jxOpK2dQOv/7JIb5/30+W4oidtUgmFMXLc/3mC09mKM= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
      experimental-features = nix-command flakes ca-derivations
    '';
  };

  globalPath = "/nix-bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";

  root-env = buildEnv {
    name = "root-env";
    pathsToLink = [ "/bin" ];
    postBuild = ''
      mv $out/bin $out/nix-bin
      cp -R ${root-files}/. $out/
    '';
    paths = [
      wrapped-nix
      docker-slim
      rsync
      dumb-init
      curl
      openssh
      git
      yj
      jq
      iproute2
      less
      direnv
      fzf
      amazon-ecr-credential-helper
    ];
  };

  env = [
    "PATH=${globalPath}"
    "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive"
  ];

  image = nix2container.buildImage {
    inherit name;
    tag = "${version}-${nix.version}";
    fromImage = ubuntu-base-image;
    config = {
      inherit env;
      volumes = {
        "/home/${user}" = { };
        "/var/empty" = { };
      };
      entrypoint = [
        "dumb-init"
        "--"
      ];
    };
    copyToRoot = [ root-env ];
    layers = [
      (nix2container.buildLayer { deps = [ docker-slim ]; })
    ];
    maxLayers = 100;
    perms = [
      {
        path = root-env;
        regex = "/home/${user}";
        mode = "0755";
        gid = userUid;
        uid = userUid;
      }
    ];
  };
in
image
