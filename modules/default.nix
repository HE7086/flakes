{
  default = { ... }: {
    imports = [
      ./baseSystem
    ];
  };
  archRepo = { ... }: {
    imports = [
      ./archRepo
    ];
  };
  ddns = { ... }: {
    imports = [
      ./ddns
    ];
  };
  fileShare = { ... }: {
    imports = [
      ./fileShare
    ];
  };
  hass = { ... }: {
    imports = [
      ./hass
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
