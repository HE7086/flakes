{
  inputs,
  rootPath,
  self,
  ...
}:
with inputs;
let
  baseSystem =
    { module, system }:
    nixpkgs.lib.nixosSystem rec {
      inherit system;
      specialArgs = {
        inherit inputs rootPath self;
        inherit (pkgs) lib;
      };
      modules = [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        self.nixosModules.baseSystem
      ] ++ module;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = nixpkgs.lib.mapAttrsToList (n: v: v) self.overlays;
      };
    };
in
{
  herd = baseSystem {
    module = [ ./herd.nix ];
    system = "x86_64-linux";
  };
  fridge = baseSystem {
    module = [ ./fridge.nix ];
    system = "x86_64-linux";
  };
  toaster = baseSystem {
    module = [ ./toaster.nix ];
    system = "aarch64-linux";
  };
}
