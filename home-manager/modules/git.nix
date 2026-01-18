{ config, pkgs, lib, ... }:
{
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  home.packages = with pkgs;[
    gitFull
    jujutsu
    jjui
  ];
}
