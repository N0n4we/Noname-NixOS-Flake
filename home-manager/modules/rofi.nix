{ lib, ... }:
{
  programs.rofi = {
    enable = true;
    font = lib.mkForce "Noto Sans Mono CJK SC 22";
    extraConfig = {
      show-icons = false;
      display-drun = "";
      display-dmenu = "";
      disable-history = false;
    };
    theme = {
      "window" = {
        border = 3;
        border-radius = 6;
        padding = 15;
        height = "80%";
      };
      "mainbox" = {
        border = 0;
        padding = 0;
      };
      "message" = {
        border = "0px";
        padding = "1px";
      };
      "listview" = {
        fixed-height = 0;
        border = "0px";
        spacing = "2px";
        scrollbar = false;
        padding = "2px 0px 0px";
      };
      "element" = {
        border = 0;
        padding = "3px";
      };
      "scrollbar" = {
        width = "2px";
        border = 0;
        handle-width = "8px";
        padding = 0;
      };
      "sidebar" = {
        border = "2px dash 0px 0px";
      };
      "inputbar" = {
        spacing = 0;
        padding = "1px";
        children = [ "prompt" "textbox-prompt-colon" "entry" "case-indicator" ];
      };
      "case-indicator" = {
        spacing = 0;
      };
      "entry" = {
        spacing = 0;
      };
      "prompt" = {
        spacing = 0;
      };
      "textbox-prompt-colon" = {
        expand = false;
        str = "";
        margin = "0px 0.3em 0em 0em";
      };
    };
  };
}
