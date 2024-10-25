{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.wol
  ];
}
