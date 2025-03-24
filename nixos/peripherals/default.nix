{ config, lib, ... }:
with lib;
let
  cfg = config.peripherals;
in
{
  options = {
    peripherals.enable = mkEnableOption "Enable peripheral configuration" lib.mkDefault true;
    peripherals.obs.enable = mkEnableOption "Enable OBS virtual camera" lib.mkDefault false;
    peripherals.scarlettRite.enable = mkEnableOption "Enable Scarlett Rite" lib.mkDefault false;
  };
  config = mkIf cfg.enable {
    boot = {

      kernelModules = mkIf cfg.obs.enable [ "v4l2loopback" ];
      extraModulePackages = mkIf cfg.obs.enable [ config.boot.kernelPackages.v4l2loopback.out ];
      extraModprobeConfig =
        config.boot.extraModprobeConfig
        + (if cfg.obs.enable then "options v4l2loopback exclusive_caps=1 card_label='OBS Camera'" else "")
        + (
          if cfg.scarlettRite.enable then "options snd_usb_audio vid=0x1235 pid=0x8212 device_setup=1" else ""
        );
    };
  };
}
