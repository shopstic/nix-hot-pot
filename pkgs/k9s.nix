{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles, testers, k9s }:
buildGoModule rec {
  pname = "k9s";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "derailed";
    repo = "k9s";
    rev = "v${version}";
    sha256 = "sha256-agGayZ20RMAcGOx+owwDbUUDsjF3FZajhwDZ5wtE93k=";
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/derailed/k9s/cmd.version=${version}"
    "-X github.com/derailed/k9s/cmd.commit=${src.rev}"
    "-X github.com/derailed/k9s/cmd.date=1970-01-01T00:00:00Z"
  ];

  # https://github.com/derailed/k9s/issues/780
  tags = [ "netcgo" ];

  vendorHash =
    if stdenv.isDarwin
    then "sha256-1BgWQsS28pxc3bgKrCc1GPgo7U3Tp8Qi3gAqinAvUiQ=" else
      "sha256-Wn/9vIyw99BudhhTnoN81Np70VInV6uo7Sru64nhPgk=";

  # TODO investigate why some config tests are failing
  doCheck = !(stdenv.isDarwin && stdenv.isAarch64);
  # Required to workaround test check error:
  preCheck = "export HOME=$(mktemp -d)";
  # For arch != x86
  # {"level":"fatal","error":"could not create any of the following paths: /homeless-shelter/.config, /etc/xdg","time":"2022-06-28T15:52:36Z","message":"Unable to create configuration directory for k9s"}
  passthru.tests.version = testers.testVersion {
    package = k9s;
    command = "HOME=$(mktemp -d) k9s version -s";
    inherit version;
  };

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    installShellCompletion --cmd k9s \
      --bash <($out/bin/k9s completion bash) \
      --fish <($out/bin/k9s completion fish) \
      --zsh <($out/bin/k9s completion zsh)
  '';

  meta = with lib; {
    description = "Kubernetes CLI To Manage Your Clusters In Style";
    homepage = "https://github.com/derailed/k9s";
    license = licenses.asl20;
    maintainers = with maintainers; [ Gonzih markus1189 bryanasdev000 ];
  };
}
