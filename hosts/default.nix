{
  inputs,
  rootPath,
  self,
  ...
}:
with inputs;
let
  baseSystem =
    {
      modules ? [ ],
      system ? "x86_64-linux",
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs rootPath self;
      };
      modules = [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        self.nixosModules.baseSystem
      ] ++ modules;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: _prev: {
            unstable = import nixos-unstable {
              system = final.system;
              config.allowUnfree = true;
            };
          })
        ];
      };
    };
in
{
  herd = baseSystem { modules = [ ./herd.nix ]; };
  fridge = baseSystem { modules = [ ./fridge.nix ]; };
  toaster = baseSystem {
    modules = [ ./toaster.nix ];
    system = "aarch64-linux";
  };
}
