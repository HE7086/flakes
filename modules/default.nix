{
  baseSystem = { ... }: {
    imports = [
      ./baseSystem
    ];
  };
  ddns = { ... }: {
    imports = [
      ./ddns
    ];
  };
  download = { ... }: {
    imports = [
      ./download
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
  test = { ... }: { imports = [ ]; };
}
