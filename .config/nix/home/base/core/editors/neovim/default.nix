{pkgs, ...}: {
  programs = {
    neovim = {
      enable = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      coc = {
        enable = true;
        settings = {
          languageserver = {
            go = {
              command = "gopls";
              rootPatterns = ["go.mod"];
              filetypes = ["go"];
            };
          };
        };
      };
      extraPackages = [pkgs.nodejs pkgs.gopls]; # For CoC
      extraLuaConfig = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        require("keys")
      '';
      extraConfig = ''
        set hidden
        set autoindent
        set smartindent
        set showmatch
        set incsearch
        set noerrorbells
        set number
        set numberwidth=4
        set rnu
        set nowrap
        set showcmd
        set scrolloff=3
        set backspace=2
        set completeopt=menuone,noselect
        set mouse-=a
        set tw=80
        set signcolumn=yes:2
      '';
      plugins = with pkgs.vimPlugins; [
        vim-nix
        {
          plugin = nvim-treesitter.withAllGrammars;
          config = ''
            set foldmethod=expr
            set foldexpr=nvim_treesitter#foldexpr()
            set nofoldenable

            lua << END
              require('nvim-treesitter.configs').setup {
                incremental_selection = {
                  enable = true,
                  keymaps = {
                    init_selection = "gnn", -- set to `false` to disable one of the mappings
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                  },
                },
                indent = {
                  enable = true
                }
              }

              vim.wo.foldmethod = 'expr'
              vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
            END
          '';
        }
        {
          plugin = catppuccin-nvim;
          config = ''
            lua << END
              require('catppuccin').setup {
                flavour = "frappe"
              }
              vim.cmd.colorscheme "catppuccin"
            END
          '';
        }
        {
          plugin = gitsigns-nvim;
          config = ''
            lua << END
              require('gitsigns').setup()
            END
          '';
        }
        {
          plugin = lualine-nvim;
          config = ''
            lua << END
              require('lualine').setup {
                options = {
                  icons_enabled = false,
                  section_separators = ' ',
                  component_separators = ' ',
                }
              }
            END
          '';
        }
        {
          plugin = barbecue-nvim;
          config = ''
            lua << END
              require("barbecue").setup()
            END
          '';
        }
        {
          plugin = trouble-nvim;
          config = ''
            lua << END
              require("trouble").setup()
            END
          '';
        }
        {
          plugin = hop-nvim;
          config = ''
            lua << END
              require("hop").setup()

              local map = require("keys").map
              map("n", "HH", ":HopWord<cr>")
              map("n", "HF", ":HopPattern<cr>")
              map("n", "HL", ":HopLineStart<cr>")
            END
          '';
        }
        (pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-web-devicons";
          version = "0422a19d9aa3aad2c7e5cca167e5407b13407a9d";
          src = pkgs.fetchFromGitHub {
            owner = "nvim-tree";
            repo = "nvim-web-devicons";
            rev = "0422a19d9aa3aad2c7e5cca167e5407b13407a9d";
            sha256 = "0qnigbhyxwc5mwyb6az3f9bh8609rvllkg34x6qp5vffaslfbhwd";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-be-good";
          version = "0ae3de14eb8efc6effe7704b5e46495e91931cc5";
          src = pkgs.fetchFromGitHub {
            owner = "ThePrimeagen";
            repo = "vim-be-good";
            rev = "0ae3de14eb8efc6effe7704b5e46495e91931cc5";
            sha256 = "1kqb4ljlwypilq23y5d83njh08z5w8mlk323qcqp521jvmbmkcya";
          };
        })
      ];
    };
  };

    xdg.configFile."nvim/lua".source = ./lua;
}
