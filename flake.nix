{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, sops-nix, disko, home-manager, ... }@inputs:
  let commonModules = [
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    ./configuration.nix
  ]; in {
    nixosConfigurations = {
      herd = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = commonModules ++ [
          ./hosts/herd.nix
        ];
      };
    };
  };
}
