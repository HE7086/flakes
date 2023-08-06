{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, sops-nix, home-manager, ... }@inputs: {
    nixosConfigurations = {
      herd = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
