{ ... }:
{
  services.displayManager = {
    defaultSession = "Scroll";
    ly = {
      enable = true;
      settings = {
        clock = "%H:%M:%S";
        bigclock = "en";
        animation = "colormix";
      };
    };
  };
}
