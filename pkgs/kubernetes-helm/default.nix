# Forked from https://github.com/NixOS/nixpkgs/blob/3fabe187426a3c69899b09347a11a6ec2c01e3a0/pkgs/applications/networking/cluster/helm/default.nix
{ lib, buildGoModule, fetchFromGitHub, installShellFiles, testers, kubernetes-helm }:

buildGoModule rec {
  pname = "kubernetes-helm";
  version = "3.13.3";

  src = fetchFromGitHub {
    owner = "helm";
    repo = "helm";
    rev = "v${version}";
    sha256 = "sha256-tU6RdVdcOvNYgnVmeDVKVuKY5GLeqVzpleq6qNwD2yI=";
  };
  vendorHash = "sha256-ve2T2O9cISshAe5uAyXYZ6Mbb1TPhOqhV8vkF5uMrhY=";

  subPackages = [ "cmd/helm" ];
  ldflags = [
    "-w"
    "-s"
    "-X helm.sh/helm/v3/internal/version.version=v${version}"
    "-X helm.sh/helm/v3/internal/version.gitCommit=${src.rev}"
  ];

  __darwinAllowLocalNetworking = true;

  preCheck = ''
    # skipping version tests because they require dot git directory
    substituteInPlace cmd/helm/version_test.go \
      --replace "TestVersion" "SkipVersion"
    # skipping plugin tests
    substituteInPlace cmd/helm/plugin_test.go \
      --replace "TestPluginDynamicCompletion" "SkipPluginDynamicCompletion" \
      --replace "TestLoadPlugins" "SkipLoadPlugins"
    substituteInPlace cmd/helm/helm_test.go \
      --replace "TestPluginExitCode" "SkipPluginExitCode"
  '';

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    $out/bin/helm completion bash > helm.bash
    $out/bin/helm completion zsh > helm.zsh
    $out/bin/helm completion fish > helm.fish
    installShellCompletion helm.{bash,zsh,fish}
  '';

  patches = [
    ./patch-pvc-is-ready.patch
  ];

  passthru.tests.version = testers.testVersion {
    package = kubernetes-helm;
    command = "helm version";
    version = "v${version}";
  };

  meta = with lib; {
    homepage = "https://github.com/kubernetes/helm";
    description = "A package manager for kubernetes";
    mainProgram = "helm";
    license = licenses.asl20;
    maintainers = with maintainers; [ rlupton20 edude03 saschagrunert Frostman Chili-Man techknowlogick ];
  };
}
