{ config, pkgs, lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      # ======================================================================= #
      # General
      # ======================================================================= #
      general = {
        hide_cursor = true;
      };

      # ======================================================================= #
      # Background
      # ======================================================================= #
      background = lib.mkForce [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      # ======================================================================= #
      # Animations
      # ======================================================================= #
      animations = {
        bezier = "slowAcc, 0.25, 0.1, 0.35, 0.9";
        animation = "inputFieldDots, 1, 10, slowAcc";
      };

      # ======================================================================= #
      # Input Field
      # ======================================================================= #
      input-field = lib.mkForce {
        outline_thickness = 0;
        inner_color = "rgba(0, 0, 0, 0.0)";
        size = "1000, 1200";
        placeholder_text = "";
        dots_size = 1;
        dots_spacing = 1;
        dots_center = true;
        dots_text_format = "|";
        font_color = "rgba(255, 255, 255, 1.0)";
        fail_color = "rgba(0, 0, 0, 0.0)";
        fail_text = "X";
        check_color = "rgba(0, 0, 0, 0.0)";
        position = "0, 0";
        halign = "center";
        valign = "center";
      };

      # ======================================================================= #
      # Labels
      # ======================================================================= #
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgba(255, 255, 255, 0.1)";
          font_size = 500;
          font_family = "Noto Sans Mono Bold";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "<span font_family='Noto Sans Mono Bold'>Hello $USER</span>";
          color = "rgba(255, 255, 255, 0.5)";
          font_size = 120;
          position = "0, 400";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] echo "<b> "$(uptime -p || ~/.config/scripts/UptimeNixOS.sh)" </b>"'';
          color = "rgba(255, 255, 255, 0.2)";
          font_size = 80;
          font_family = "Noto Sans Mono Bold";
          position = "0, -420";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
