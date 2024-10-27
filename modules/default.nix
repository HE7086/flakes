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
  avahi = { ... }: {
    imports = [
      ./avahi
    ];
  };
  ddns = { ... }: {
    imports = [
      ./ddns
    ];
  };
  hass = { ... }: {
    imports = [
      ./hass
      ./common/nginx.nix
    ];
  };
  samba = { ... }: {
    imports = [
      ./samba
    ];
  };
  suwayomi = { ... }: {
    imports = [
      ./suwayomi
    ];
  };
  test = { ... }: { imports = [ ]; };
}
