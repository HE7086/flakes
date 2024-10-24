{ pkgs, ... }: {
  imports = [
    ./flaresolverr.nix
  ];
  services.suwayomi-server = {
    enable = true;
    package = pkgs.unstable.suwayomi-server;
    settings = {
      server = {
        port = 7375;
        extensionRepos = [
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];
        flareSolverrEnabled = true;
      };
    };
    openFirewall = true;
  };
}
