{ nix2container
, runCommand
, kubernetes
}:
let
  kube-scheduler = runCommand "kube-scheduler" { } ''
    mkdir -p $out/bin
    cp ${kubernetes}/bin/kube-scheduler $out/bin/
  '';
in
nix2container.buildImage {
  name = "kube-scheduler";
  tag = kubernetes.version;
  config = {
    entrypoint = [ "${kube-scheduler}/bin/kube-scheduler" ];
  };
}
