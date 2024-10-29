{
  default = { ... }: {
    imports = [
      ./baseSystem
    ];
  };
  archRepo = { ... }: {
    imports = [
      ./archRepo
      ./common/nginx.nix
    ];
  };
  ddns = { ... }: {
    imports = [
      ./ddns
    ];
  };
  fileShare.local = { ... }: {
    imports = [
      ./fileShare/avahi.nix
      ./fileShare/samba.nix
    ];
  };
  fileShare.remote = { ... }: {
    imports = [
      ./fileShare/rsyncd.nix
      ./fileShare/web.nix
      ./common/nginx.nix
    ];
  };
  hass = { ... }: {
    imports = [
      ./hass
      ./common/nginx.nix
    ];
  };
  suwayomi = { ... }: {
    imports = [
      ./suwayomi
    ];
  };
  download = { ... }: {
    imports = [
      ./download
    ];
  };
  test = { ... }: { imports = [ ]; };
}
