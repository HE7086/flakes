{ config, lib, ... }:
with lib;
let
  cfg = config.services.awakening.client;
in
{
  config = mkIf cfg.enable {
  };
}
