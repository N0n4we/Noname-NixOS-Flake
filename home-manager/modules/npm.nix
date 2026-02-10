{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    nodejs
    yarn
    bun
    pnpm
    electron
    nodePackages.typescript
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.sql-formatter
    nodePackages.markdownlint-cli
    nodePackages.stylelint
    nodePackages.htmlhint
  ];

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
    cache=${config.home.homeDirectory}/.npm
    init-module=${config.home.homeDirectory}/.npm-init.js
  '';
}
