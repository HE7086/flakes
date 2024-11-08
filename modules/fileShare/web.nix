{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fileShare.remote;
in
lib.mkIf cfg.enable {
  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    "${cfg.virtualHost}" = {
      forceSSL = true;
      enableACME = true;
      root = cfg.dir;
      locations."/".extraConfig = ''
        fancyindex on;
        fancyindex_exact_size off;
        fancyindex_show_dotfiles on;
        fancyindex_hide_parent_dir on;
      '';
    };
  };
  services.nginx.additionalModules = [ pkgs.nginxModules.fancyindex ];
  systemd.tmpfiles.rules = lib.mkIf cfg.createDir [
    "d ${cfg.dir} ${cfg.mode} ${cfg.user} ${cfg.group}"
  ];
}
