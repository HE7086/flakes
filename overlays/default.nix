{ inputs, ... }:
{

  # https://github.com/oddlama/nixos-extra-modules
  net =
    final: prev:
    prev.lib.composeManyExtensions (map (x: import x inputs) [
      ./net/misc.nix
      ./net/net.nix
    ]) final prev;

  unstable = final: _: {
    unstable = import inputs.nixos-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  local =
    final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (prev) callPackage;
      directory = ./pkgs;
    };

}
