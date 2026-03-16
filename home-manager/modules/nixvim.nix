{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    opts = {
      number = false;
      relativenumber = false;
      clipboard = "unnamedplus";
      wrap = true;
      linebreak = true;
      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      breakindent = true;
      showbreak = "↪ ";
      ambiwidth = "single";
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
        action = "<cmd>Bdelete<CR>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>X";
        action = "<cmd>Bdelete!<CR>";
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
        action = "<cmd>!alacritty msg create-window --working-directory $(pwd)<CR>";
        options.desc = "Open new Alacritty window";
      }
      {
        mode = [ "n" "v" ];
        key = "<A-y>";
        action = "<cmd>!alacritty msg create-window --working-directory $(pwd) -e nu -i -e y<CR>";
        options.desc = "Open new Yazi(Alacritty) window";
      }
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show diagnostic";
      }
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
        options.desc = "Previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
        options.desc = "Next diagnostic";
      }

      # Yazi
      {
        mode = "n";
        key = "<leader>y";
        action = "<cmd>Yazi<CR>";
        options.desc = "Open Yazi";
      }

      # Telescope
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Find buffers";
      }

      # Flash
      {
        mode = [ "n" "x" ];
        key = "s";
        action = "<cmd>lua require('flash').jump()<CR>";
        options.desc = "Flash jump";
      }

      # Comment
      {
        mode = "n";
        key = "<C-c>";
        action = "<Plug>(comment_toggle_linewise_current)";
        options.desc = "Toggle comment";
      }
      {
        mode = "v";
        key = "<C-c>";
        action = "<Plug>(comment_toggle_linewise_visual)";
        options.desc = "Toggle comment";
      }

      # nvim-tree
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<CR>";
        options.desc = "Toggle tree";
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
            "Switch Mode" = "v";
            "Goto Prev" = "<C-k>";
            "Goto Next" = "<C-j>";
          };
          show_warnings = 1;
          silent_exit = 0;
        };
      };
      flash.enable = true;
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

      telescope.enable = true;

      lualine = {
        enable = true;
        settings.sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "diff" ];
          lualine_c = [ "filename" ];
          lualine_x = [ "encoding" ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
      lsp = {
        enable = true;
        servers = {
          ruff.enable = true;
          ty.enable = true;
          gopls.enable = true;
          zls.enable = true;
        };
      };
      lspsaga = {
        enable = true;
        settings = {
          lightbulb.enable = false;
        };
      };
      nvim-surround.enable = true;
      comment.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
      nvim-tree = {
        enable = true;
        settings.renderer.group_empty = true;
        settings.git.enable = false;
      };

      bufdelete.enable = true;

      oil.enable = true;

      smear-cursor = {
        enable = true;
        settings = {
          cursor_color = "#ff5a1f";
          particles_enabled = true;
          stiffness = 0.35;
          trailing_stiffness = 0.12;
          trailing_exponent = 6;
          damping = 0.72;
          gradient_exponent = 1.5;
          gamma = 1;
          never_draw_over_target = true;
          hide_target_hack = true;
          particle_spread = 1.5;
          particles_per_second = 800;
          particles_per_length = 50;
          particle_max_lifetime = 800;
          particle_max_initial_velocity = 25;
          particle_velocity_from_cursor = 0.6;
          particle_damping = 0.08;
          particle_gravity = -40;
          min_distance_emit_particles = 0;
        };
      };
    };
  };
  programs.neovide.enable = true;
}
