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
      extraConfig = ''
        set hidden
        set autoindent
        set smartindent
        set showmatch
        set incsearch
        set noerrorbells
        set number
        set numberwidth=4
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
                indent = {
                  enable = true
                }
              }
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
      ];
    };
  };
}
