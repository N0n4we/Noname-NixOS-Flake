{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    nodejs_24
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

  home.sessionVariables.PATH =
    lib.mkAfter ":${config.home.homeDirectory}/.npm-global/bin";

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
    cache=${config.home.homeDirectory}/.npm
    init-module=${config.home.homeDirectory}/.npm-init.js
  '';
}
