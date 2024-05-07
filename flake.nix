{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nur.url = "github:nix-community/NUR";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dotfiles = {
    #   url = "https://github.com/HE7086/dotfiles";
    #   flake = false;
    #   type = "git";
    #   submodules = true;
    # };
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , nixpkgs-unstable
    , sops-nix
    , disko
    , flake-utils
    , home-manager
    # , dotfiles
    , ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
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
            jq
            mkpasswd
            ssh-to-age
          ];
        };
        formatter = pkgs.nixpkgs-fmt;
      }) // rec {
      inherit (self) outputs;
      overlays = import ./nix/overlays.nix { inherit inputs; };
      nixosConfigurations =
        let
          baseSystem = { system ? "x86_64-linux", modules ? [ ] }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs outputs; };
              modules = [
                sops-nix.nixosModules.sops
                disko.nixosModules.disko
                nur.nixosModules.nur
                home-manager.nixosModules.home-manager
                ./modules/common.nix
              ] ++ modules;
            };
        in
        {
          herd = baseSystem { modules = [ ./hosts/herd.nix ]; };
          fridge = baseSystem { modules = [ ./hosts/fridge.nix ]; };
          toaster = baseSystem { system = "aarch64-linux"; modules = [ ./hosts/toaster.nix ]; };
        };
    };
}
