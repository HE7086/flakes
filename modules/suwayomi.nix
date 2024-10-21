{ pkgs, ... }: 
{
  services.suwayomi-server = {
    enable = true;
    package = pkgs.unstable.suwayomi-server;
    settings = {
      server = {
        port = 7375;
        localSourcePath = "/share/Data/Manga";
        extensionRepos = [
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];
      };
    };
    openFirewall = true;
  };

}
