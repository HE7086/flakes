{ inputs, ... }:
with inputs.nixpkgs.lib;
let
  modulesFromDirectory =
    dir:
    mapAttrs (
      module: _:
      { ... }:
      {
        imports = [ ./${module} ];
      }
    ) (attrsets.filterAttrs (_: type: type == "directory") (builtins.readDir dir));
in
modulesFromDirectory ./.
