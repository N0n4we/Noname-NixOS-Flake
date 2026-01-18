{ pkgs, ... }:
{
  stylix = {
    enable = true;
    targets = {
      qt.enable = true;
      gtk.enable = true;
      nixos-icons.enable = true;
      firefox.profileNames = [ "noname" ];
      cava = {
        enable = true;
        rainbow.enable = true;
      };
      alacritty.enable = true;
      yazi.enable = true;
      btop.enable = true;
      vesktop.enable = true;
      zathura.enable = true;
      mako.enable = true;
      fcitx5.enable = true;
      nushell.enable = true;
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/terracotta-dark.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 24;
    };
    icons = {
      enable = true;
      package = pkgs.dracula-icon-theme;
      dark = "Dracula";
      light = "Dracula";
    };
    fonts = {
      sizes = {
        terminal = 14;
        applications = 13;
        popups = 13;
      };
      serif = {
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        name = "CaskaydiaCove Nerd Font";
      };
      monospace = {
        name = "CaskaydiaCove Nerd Font";
      };
      emoji = {
        name = "Noto Color Emoji";
      };
    };
  };
}
