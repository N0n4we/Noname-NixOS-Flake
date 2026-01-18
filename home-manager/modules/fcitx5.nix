{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        kdePackages.fcitx5-chinese-addons
        fcitx5-pinyin-zhwiki
        fcitx5-pinyin-moegirl
        fcitx5-mozc
      ];
      settings = {
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Alt+space";
            "1" = "Zenkaku_Hankaku";
            "2" = "Hangul";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Shift_L";
          };
          "Behavior" = {
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            DisabledAddons = "cloudpinyin";
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "pinyin";
            Layout = "";
          };
          "Groups/0/Items/2" = {
            Name = "mozc";
            Layout = "";
          };
          "GroupOrder" = {
            "0" = "Default";
          };
        };
        addons = {
          classicui.globalSection = {
            "Vertical Candidate List" = "True";
          };
          punctuation = {
            globalSection = {
              HalfWidthPuncAfterLetterOrNumber = "False";
              TypePairedPunctuationsTogether = "False";
              Enabled = "True";
            };
            sections.Hotkey = {
              "0" = "Control+period";
            };
          };
          pinyin = {
            globalSection = {
              PageSize = 7;
              CloudPinyinEnabled = "True";
              CloudPinyinIndex = 8;
              CloudPinyinAnimation = "False";
            };
          };
          cloudpinyin = {
            globalSection = {
              MinimumPinyinLength = 4;
              Backend = "GoogleCN";
            };
          };
        };
      };
    };
  };
}
