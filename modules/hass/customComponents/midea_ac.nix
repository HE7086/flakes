{ pkgs, ... }:
{
  services.home-assistant.customComponents = with pkgs; [
    (callPackage buildHomeAssistantComponent rec {
      owner = "mill1000";
      domain = "midea_ac";
      version = "2024.10.4";

      src = fetchFromGitHub {
        inherit owner;
        repo = "midea-ac-py";
        rev = "${version}";
        sha256 = "sha256-P/s8HMP9xQWI+bgy6JHe4pAx+jItpK6BCWIyKsfTjmg=";
        # nix shell 'nixpkgs#nix-prefetch-github' -c nix-prefetch-github --rev "2025.3.1" mill1000 midea-ac-py
      };

      # https://github.com/mill1000/midea-ac-py/blob/main/custom_components/midea_ac/manifest.json
      dependencies = with home-assistant.python.pkgs; [
        msmart-ng
      ];
      # ignoreVersionRequirement = [
      #   "msmart-ng"
      # ];
    })
  ];
}
