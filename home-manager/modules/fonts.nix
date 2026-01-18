{ config, pkgs, lib, ... }:
let
  fontDir = ./fonts;
  fontFiles = if builtins.pathExists fontDir then builtins.readDir fontDir else {};
  ttfFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".ttf" name) fontFiles;
  ttcFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".ttc" name) fontFiles;
  allFontFiles = ttfFiles // ttcFiles;
  fontPackage = if allFontFiles != {} then
    pkgs.stdenvNoCC.mkDerivation {
      name = "local-fonts";
      src = fontDir;
      installPhase = ''
        runHook preInstall

        local out_font=$out/share/fonts/truetype
        mkdir -p $out_font

        for file in *.ttf *.ttc; do
          if [[ -f "$file" ]]; then
            install -m444 -Dt $out_font "$file"
          fi
        done

        runHook postInstall
      '';
    }
  else null;
in
{
  home.packages = with pkgs; [
    corefonts
    vista-fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    sarasa-gothic
    source-han-sans
    source-han-mono
    source-han-serif
    nerd-fonts.caskaydia-cove
  ] ++ lib.optional (fontPackage != null) fontPackage;
}
