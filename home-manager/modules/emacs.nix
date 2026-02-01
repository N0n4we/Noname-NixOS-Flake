{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages = epkgs: [
      epkgs.evil
      epkgs.evil-collection
      epkgs.multiple-cursors
      epkgs.xclip
      epkgs.nix-mode
      epkgs.markdown-mode
    ];
    extraConfig = ''
      (menu-bar-mode -1)
      (tool-bar-mode -1)

      (setq evil-want-C-u-scroll t)

      (require 'evil)
      (evil-mode 1)

      (require 'xclip)
      (xclip-mode 1)

      (ido-mode 1)
      (ido-everywhere 1)

      (setq select-enable-clipboard t)
      (setq evil-kill-on-visual-paste nil)

      (require 'multiple-cursors)
      (setq mc/always-run-for-all t)
      (define-key evil-visual-state-map (kbd "C-n") 'mc/mark-next-like-this)
      (define-key evil-visual-state-map (kbd "C-p") 'mc/mark-previous-like-this)
      (define-key evil-visual-state-map (kbd "C-m") 'mc/mark-all-like-this)
      (define-key evil-normal-state-map (kbd "<escape>") 'mc/keyboard-quit)

      (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))
      (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
    '';
  };
}
