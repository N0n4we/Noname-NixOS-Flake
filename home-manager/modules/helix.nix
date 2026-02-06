{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    package = pkgs.evil-helix;
    settings = {
      keys.normal = {
        g = { e = "move_prev_word_end"; };
        "A-s" = ":toggle-option soft-wrap.enable";
        "A-t" = ":sh alacritty msg create-window --working-directory $(pwd)";
        "C-r" = "redo";
        "C-e" = "scroll_down";
        "C-y" = "scroll_up";
      };
      keys.select = {
        g = { e = "move_prev_word_end"; };
        "A-s" = ":toggle-option soft-wrap.enable";
        "A-t" = ":sh alacritty msg create-window --working-directory $(pwd)";
        "C-e" = "scroll_down";
        "C-y" = "scroll_up";
      };
      editor = {
        line-number = "relative";
        auto-format = false;
        auto-pairs = false;
        default-yank-register = "+";
        trim-trailing-whitespace = true;
        trim-final-newlines = true;
      };
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      editor.file-picker = {
        hidden = false;
      };
      editor.soft-wrap = {
        enable = true;
      };
      editor.indent-guides = {
        render = true;
        rainbow-option = "dim";
      };
      editor.smart-tab = {
        enable = false;
      };
      editor.statusline = {
        right = [ "diagnostics" "primary-selection-length" "selections" "position-percentage" "total-line-numbers" "file-encoding" ];
      };
    };
    languages = {
      language-server.scls = {
        command = "simple-completion-language-server";
        config = {
          feature_words = true;
          feature_snippets = true;
          snippets_first = true;
          feature_paths = true;
        };
      };
      language-server.jdtls = {
        command = "jdtls";
        timeout = 300;
        config = {
          java.maxConcurrentBuilds = 4;
        };
        args = [ "--jvm-arg=-Xms2G" "--jvm-arg=-Xmx8G" ];
      };
      language = [
        {
          name = "text";
          scope = "text.plain";
          file-types = [
            "txt"
            { glob = "README"; }
            { glob = "CHANGELOG"; }
            { glob = "LICENSE"; }
          ];
          language-servers = [ "scls" ];
        }
        {
          name = "python";
          scope = "source.python";
          language-servers = [ "ruff" "ty" "scls" ];
        }
        {
          name = "java";
          scope = "source.java";
          language-servers = [ "scls" "jdtls" ];
        }
        {
          name = "go";
          scope = "source.go";
          language-servers = [ "scls" "gopls" ];
        }
        {
          name = "rust";
          scope = "source.rust";
          language-servers = [ "scls" "rust-analyzer" ];
        }
        {
          name = "zig";
          scope = "source.zig";
          language-servers = [ "scls" "zls" ];
        }
        {
          name = "c";
          scope = "source.c";
          language-servers = [ "scls" "clangd" ];
        }
        {
          name = "javascript";
          scope = "source.js";
          language-servers = [ "typescript-language-server" "scls" ];
        }
        {
          name = "typescript";
          scope = "source.ts";
          language-servers = [ "typescript-language-server" "scls" ];
        }
        {
          name = "tsx";
          scope = "source.tsx";
          language-servers = [ "typescript-language-server" "scls" ];
        }
        {
          name = "sql";
          scope = "source.sql";
          language-servers = [ "scls" ];
        }
        {
          name = "dockerfile";
          scope = "source.dockerfile";
          language-servers = [ "scls" ];
        }
        {
          name = "yaml";
          scope = "source.yaml";
          language-servers = [ "scls" ];
        }
        {
          name = "css";
          scope = "source.css";
          language-servers = [ "vscode-css-language-server" "scls" ];
        }
        {
          name = "html";
          scope = "source.html";
          language-servers = [ "superhtml" "scls" ];
        }
        {
          name = "json";
          scope = "source.json";
          language-servers = [ "scls" ];
        }
        {
          name = "toml";
          scope = "source.toml";
          language-servers = [ "scls" ];
        }
        {
          name = "xml";
          scope = "source.xml";
          language-servers = [ "scls" ];
        }
        {
          name = "kdl";
          scope = "source.kdl";
          language-servers = [ "scls" ];
        }
        {
          name = "bash";
          scope = "source.bash";
          language-servers = [ "scls" ];
        }
        {
          name = "nix";
          scope = "source.nix";
          language-servers = [ "nil" "scls" ];
        }
        {
          name = "markdown";
          scope = "text.markdown";
          language-servers = [ "scls" ];
        }
        {
          name = "git-commit";
          scope = "text.git-commit";
          language-servers = [ "scls" ];
        }
        {
          name = "jjdescription";
          scope = "text.jjdescription";
          language-servers = [ "scls" ];
        }
      ];
    };
  };
}
