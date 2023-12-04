{ buildGoModule
, fetchFromGitHub
, lib
}:
buildGoModule rec {
  pname = "gitlab-copy";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "gotsunami";
    repo = "gitlab-copy";
    rev = "v${version}";
    sha256 = "sha256-fzWmJM5oR0AfFgLhHw9+1VHUu1kr2mY081E7kPZq3/c=";
  };

  vendorHash = "sha256-6GnkVKu7QKCYYWDrhVQeEPlZis0g/VEej/dka7n3Dfs=";

  doCheck = false;

  meta = with lib; {
    description = "GitLab Copy";
    homepage = "https://github.com/gotsunami/gitlab-copy";
    license = licenses.mit;
  };
}
