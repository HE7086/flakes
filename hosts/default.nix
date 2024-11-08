{
  inputs,
  rootPath,
  self,
  ...
}:
let
  baseSystem =
    {
      modules ? [ ],
      system ? "x86_64-linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs rootPath self;
      };
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.baseSystem
      ] ++ modules;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: _prev: {
            unstable = import inputs.nixos-unstable {
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
