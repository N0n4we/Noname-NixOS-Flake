{ config, ... }:
{
  programs.clock-rs = {
    enable = true;

    settings = {
      general = {
        color = "#${config.lib.stylix.colors.base02}";
        interval = 250;
        blink = false;
        bold = true;
      };

      position = {
        horizontal = "center";
        vertical = "center";
      };

      date = {
        fmt = "%A, %B %d, %Y";
        use_12h = false;
        utc = false;
        hide_seconds = false;
      };
    };
  };

  programs.cava = {
    enable = true;
    settings = {
      input = {
        method = "pulse";
        source = "auto";
      };
      smoothing.monstercat = 1;
    };
  };
}
