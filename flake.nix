{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
 
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur,
    sops-nix,
    disko,
    flake-utils,
    home-manager,
    ...
  }@inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [
          coreutils
          git
          just
          rsync
          curl
          openssh
          age
          sops
        ];
      };
    }
  ) // {
    nixosConfigurations =
      let commonModules = [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        ./configuration.nix
      ]; in {
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
