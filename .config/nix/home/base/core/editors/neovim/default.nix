{pkgs, ...}: 
let
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs (oldAttrs: {
    buildInputs = [ pkgs.python312Packages.six ];
  });
in
{
  programs = {
    neovim = {
      enable = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [nodejs gopls codelldb ]; # For CoC
      extraLuaConfig = ''
        -- Set the leader key
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        vim.opt.backup = false
        vim.opt.clipboard = "unnamed,unnamedplus"
        vim.opt.colorcolumn = "80"
        vim.opt.cursorline = true
        vim.opt.laststatus = 3
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.scrolloff = 8
        vim.opt.showmode = false
        vim.opt.swapfile = false
        vim.opt.termguicolors = true
        vim.opt.diffopt = "vertical,iwhite,hiddenoff,foldcolumn:0,context:4,algorithm:histogram,indent-heuristic"
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true
        vim.opt.smartindent = true

        vim.diagnostic.config({
          virtual_text = {
            severity = vim.diagnostic.severity.ERROR,
          },
          update_in_insert = true,
          severity_sort = true,
        })

        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("UserLspConfig", {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set("n", "<leader>wl", function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>f", function()
              vim.lsp.buf.format { async = true }
            end, opts)
          end,
        })
      '';
      plugins = with pkgs.vimPlugins; [
        vim-nix
        rustaceanvim
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            vim.opt.foldmethod = 'expr'
            vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
            vim.opt.foldenable = false

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
              },
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
            }
          '';
        }
        {
          plugin = nvim-cmp;
          type = "lua";
          config = # lua
            ''
              local cmp = require('cmp')
              cmp.setup({
                -- Enable LSP snippets
                snippet = {
                  expand = function(args)
                      vim.fn["vsnip#anonymous"](args.body)
                  end,
                },
                mapping = {
                  ['<C-p>'] = cmp.mapping.select_prev_item(),
                  ['<C-n>'] = cmp.mapping.select_next_item(),
                  -- Add tab support
                  ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                  ['<Tab>'] = cmp.mapping.select_next_item(),
                  ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-f>'] = cmp.mapping.scroll_docs(4),
                  ['<C-Space>'] = cmp.mapping.complete(),
                  ['<C-e>'] = cmp.mapping.close(),
                  ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                  })
                },
                -- Installed sources:
                sources = {
                  { name = 'path' },                              -- file paths
                  { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
                  { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
                  { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
                  { name = 'buffer', keyword_length = 2 },        -- source current buffer
                  { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
                  { name = 'calc'},                               -- source for math calculation
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    fields = {'menu', 'abbr', 'kind'},
                    format = function(entry, item)
                        local menu_icon ={
                            nvim_lsp = 'λ',
                            vsnip = '⋗',
                            buffer = 'Ω',
                            path = '🖫',
                        }
                        item.menu = menu_icon[entry.source.name]
                        return item
                    end,
                },
              })
            '';
        }
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            lspconfig.gopls.setup({
              capabilities = capabilities,
            })
            lspconfig.ts_ls.setup({
              capabilities = capabilities,
            })
          '';
        }
        cmp-buffer
        cmp-nvim-lsp-signature-help
        cmp-nvim-lua
        cmp-path
        vim-vsnip
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = ''
            require("nvim-tree").setup {
              update_focused_file = {
                enable = true
              }
            }

            vim.api.nvim_create_autocmd({"QuitPre"}, {
              callback = function()
                vim.cmd("NvimTreeClose")
              end
            })

            local function open_nvim_tree(data)
              local real_file = vim.fn.filereadable(data.file) == 1
              local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

              if not real_file and not no_name then
                return
              end

              require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
            end

            vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
          '';
        }
        {
          plugin = catppuccin-nvim;
          type = "lua";
          config = ''
            require('catppuccin').setup {
              flavour = "frappe"
            }
            vim.cmd.colorscheme "catppuccin"
          '';
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('gitsigns').setup()
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup {
              options = {
                icons_enabled = false,
                section_separators = ' ',
                component_separators = ' ',
              }
            }
          '';
        }
        {
          plugin = barbecue-nvim;
          type = "lua";
          config = ''
            require("barbecue").setup()
          '';
        }
        {
          plugin = trouble-nvim;
          type = "lua";
          config = ''
            require("trouble").setup()
          '';
        }
        {
          plugin = hop-nvim;
          type = "lua";
          config = ''
            require("hop").setup()

            local map = require("keys").map
            map("n", "HH", ":HopWord<cr>")
            map("n", "HF", ":HopPattern<cr>")
            map("n", "HL", ":HopLineStart<cr>")
          '';
        }
        telescope-fzf-native-nvim
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            local telescope = require("telescope")
            telescope.setup({
              defaults = {
                file_ignore_patterns = {
                  "node_modules",
                  "dist",
                  "build",
                  "target",
                  "vendor",
                  ".git"
                },
                vimgrep_arguments = {
                  "rg",
                  "--color=never",
                  "--no-heading",
                  "--with-filename",
                  "--line-number",
                  "--column",
                  "--smart-case",
                  "--hidden",
                },
              },
              pickers = {
                find_files = {
                  hidden = true,
                },
                live_grep = {
                },
              },
              extensions = {
                fzf = {
                  fuzzy = true,                    -- false will only do exact matching
                  override_generic_sorter = true,  -- override the generic sorter
                  override_file_sorter = true,     -- override the file sorter
                  case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                },
              },
            })
            telescope.load_extension("fzf")


            local map = require("keys").map
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
            vim.keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, { desc = "Telescope current buffer" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
          '';
        }
        {
          plugin = nvim-web-devicons;
          type = "lua";
          config = ''
            require("nvim-web-devicons").setup()
          '';
        }
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
        plenary-nvim
        FixCursorHold-nvim
        nvim-nio
        neotest-go
        neotest-rust
        {
          plugin = neotest;
          type = "lua";
          config = ''
            require("neotest").setup({
              adapters = {
                require("neotest-go"),
                require("neotest-rust"),
              },
              status = { virtual_text = true },
              output = { open_on_run = true },
              quickfix = {
                open = function()
                  require("trouble").open({mode="quickfix", focus=false})
                end
              },
            })
            
            -- Test keymaps
            vim.keymap.set("n", "<leader>tc", function()
              require("neotest").run.run()
            end, { desc = "Test current method" })
            vim.keymap.set("n", "<leader>tf", function()
              require("neotest").run.run(vim.fn.expand("%"))
            end, { desc = "Test current file" })
            vim.keymap.set("n", "<leader>tp", function()
              require("neotest").run.run({ suite = true })
            end, { desc = "Test current package" })
            
            -- Debug test keymaps
            vim.keymap.set("n", "<leader>tdc", function()
              require("neotest").run.run({ strategy = "dap" })
            end, { desc = "Debug test current method" })
            vim.keymap.set("n", "<leader>tdf", function()
              require("neotest").run.run(vim.fn.expand("%"), { strategy = "dap" })
            end, { desc = "Debug test current file" })
            vim.keymap.set("n", "<leader>tdp", function()
              require("neotest").run.run({ suite = true, strategy = "dap" })
            end, { desc = "Debug test current package" })
            
            -- Test summary and results keymaps
            vim.keymap.set("n", "<leader>ts", function()
              require("neotest").summary.open()
            end, { desc = "Open test summary" })
            vim.keymap.set("n", "<leader>tr", function()
              require("neotest").output.open({ enter = true })
            end, { desc = "Open test results under cursor" })
          '';
        }
      ];
    };
  };

    xdg.configFile."nvim/lua".source = ./lua;
}
