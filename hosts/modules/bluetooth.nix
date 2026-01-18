{ pkgs, ... }:
{
    services.blueman.enable = true;
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
            General = {
                Enable = "Source,Sink,Media,Socket";
                FastConnectable = true;
                AutoEnable = true;
            };
        };
    };
    environment.systemPackages = with pkgs;[
        bluez
        bluez-tools
        bluetui
    ];
}
