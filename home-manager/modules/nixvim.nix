{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    opts = {
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
      wrap = true;
      linebreak = true;
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      breakindent = true;
      showbreak = "↪ ";
    };

    autoCmd = [
      {
        event = [ "BufWritePre" ];
        pattern = [ "*" ];
        command = "%s/\\s\\+$//e";
      }
      {
        event = [ "BufWritePre" ];
        pattern = [ "*" ];
        command = "%s/\\n\\+\\%$//e";
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>bn<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>bp<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>bd<CR>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>X";
        action = "<cmd>bd!<CR>";
        options.desc = "Force close buffer";
      }
      {
        mode = [ "n" "v" ];
        key = "<A-s>";
        action = "<cmd>set wrap!<CR>";
        options.desc = "Toggle soft wrap";
      }
      {
        mode = [ "n" "v" ];
        key = "<A-t>";
        action = "<cmd>!alacritty msg create-window --working-directory \"$(pwd)\"<CR>";
        options.desc = "Open new Alacritty window";
      }

      # Yazi
      {
        mode = "n";
        key = "<leader>y";
        action = "<cmd>Yazi<CR>";
        options.desc = "Open Yazi";
      }

      # fzf-lua
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>FzfLua files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>FzfLua live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>FzfLua buffers<CR>";
        options.desc = "Find buffers";
      }

      # Flash
      {
        mode = [ "n" "x" "o" ];
        key = "s";
        action = "<cmd>lua require('flash').jump()<CR>";
        options.desc = "Flash jump";
      }
    ];

    plugins = {
      cmp = {
        enable = true;
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-y>" = "cmp.mapping.confirm({ select = true })";
        };
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        cmp-nvim-lsp.enable = true;
        cmp-path.enable = true;
        cmp-buffer.enable = true;
      };
      visual-multi = {
        enable = true;
        settings = {
          maps = {
            "Find Under" = "<C-n>";
            "Add Cursor Down" = "<M-j>";
            "Add Cursor Up" = "<M-k>";
            "Select All" = "<C-m>";
            "Visual All" = "<C-m>";
            "Start Regex Search" = "<C-/>";
            "Switch Mode" = "v";
            "Goto Prev" = "";
            "Goto Next" = "";
          };
          show_warnings = 1;
          silent_exit = 0;
        };
      };
      flash.enable = true;
      bufferline.enable = true;
      yazi.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add = { text = "▌"; };
            change = { text = "▌"; };
            changedelete = { text = "▌"; };
          };
          current_line_blame = false;
        };
      };
      guess-indent.enable = true;

      fzf-lua = {
        enable = true;
        settings = {
          winopts = {
            height = 0.85;
            width = 0.80;
            preview = {
              layout = "flex";
              flip_columns = 120;
            };
          };
          keymap = {
            builtin = {
              "<C-d>" = "preview-page-down";
              "<C-u>" = "preview-page-up";
            };
          };
          files.hidden = true;
          grep.hidden = true;
        };
      };

      indent-blankline = {
        enable = true;
        settings.indent.highlight = [ "IblIndent" ];
      };

      lualine = {
        enable = true;
        settings.sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "diff" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" "selectioncount" ];
        };
      };
      lsp = {
        enable = true;
        servers.ruff.enable = true;
        servers.ty.enable = true;
      };
    };
  };
  programs.neovide.enable = true;
}
