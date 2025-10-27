local vim = vim
local opt = vim.opt
local api = vim.api
local cmd = vim.cmd
local keymap = vim.keymap.set

local keysNoRemapSilent = { noremap = true, silent = true }

---------- PlUGIN MANAGER AUTO INSTALL  ----------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
opt.rtp:prepend(lazypath)

---------- GENERAL SETTINGS ----------

vim.g.mapleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.diagnostic.config({ virtual_text = true })

vim.g.spell = true
vim.g.spelloptions = "camel"
cmd [[ set spell spelllang=en_ca ]]
opt.compatible = false

opt.termguicolors = true
opt.encoding = "utf-8"
opt.guifont = "Iosevka 14"

-- https://til.hashrocket.com/posts/f5531b6da0-backspace-options
opt.backspace= { "indent", "eol", "start" }

-- Displays line number, virtual column number & relative position
opt.ruler = true

-- Shows the last command run in the status line
opt.showcmd = true

opt.incsearch = true
opt.hlsearch = true

-- Enable mouse mode
cmd [[ set mouse=a ]]

-- Automatically read a file when externally changed
opt.autoread = true

-- Show line numbers
vim.wo.number = true
--vim.wo.numberwidth = true

-- Use relative numbers
vim.wo.relativenumber = true

-- Maintain undo history between sessions
opt.swapfile = false;
opt.backup = false;
opt.undodir = os.getenv("HOME") .. "/.nvim/undohist"
opt.undofile = true

-- File type and indent detection
cmd [[ filetype plugin indent on ]]

-- Tabs
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

cmd [[ set listchars=eol:$,tab:>•,trail:~,extends:>,precedes:< ]]

-- LSP Icons
vim.cmd [[
	sign define DiagnosticSignError text=  linehl= texthl=DiagnosticSignError numhl=
	sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl=
	sign define DiagnosticSignInfo text=  linehl= texthl=DiagnosticSignInfo numhl=
	sign define DiagnosticSignHint text=💡  linehl= texthl=DiagnosticSignHint numhl=
]]

---------- PLUGINS ----------

-- glepnir/lspsaga.nvim
local function lspsagaKeyMappings()
	-- LSP finder - Find the symbol's definition
	-- If there is no definition, it will instead be hidden
	-- When you use an action in finder like "open vsplit",
	-- you can use <C-t> to jump back
	keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { desc = 'LSP Finder'})

	-- Code action
	keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = 'LSP Code Action' })

	-- Rename all occurrences of the hovered word for the entire file
	keymap("n", "<leader>rf", "<cmd>Lspsaga rename<CR>", { desc = 'LSP Rename in File' })

	-- Rename all occurrences of the hovered word for the selected files
	keymap("n", "<leader>rg", "<cmd>Lspsaga rename ++project<CR>", { desc = 'LSP Rename in Project' })

	-- Peek definition
	-- You can edit the file containing the definition in the floating window
	-- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
	-- It also supports tagstack
	-- Use <C-t> to jump back
	keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = 'LSP Peek Definition' })

	-- Go to definition
	keymap("n","gD", "<cmd>Lspsaga goto_definition<CR>", { desc = 'LSP Go to Definition' })

	-- Show line diagnostics
	-- You can pass argument ++unfocus to
	-- unfocus the show_line_diagnostics floating window
	keymap("n", "<leader>dl", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = 'LSP Show Line Diagnostics' })

	-- Show cursor diagnostics
	-- Like show_line_diagnostics, it supports passing the ++unfocus argument
	keymap("n", "<leader>dc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = 'LSP Show Cusor' })

	-- Show buffer diagnostics
	keymap("n", "<leader>db", "<cmd>Lspsaga show_buf_diagnostics<CR>", { desc = 'LSP Show Diagnostics for Current Buffer'})

	-- Diagnostic jump
	-- You can use <C-o> to jump back to your previous location
	keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = 'Diagnostic Jump Prev' })
	keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = 'Diagnostic Jump Next' })

	-- Diagnostic jump with filters such as only jumping to an error
	keymap("n", "[E", function()
	  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
	end,
	{ desc = 'Diagnostic Jump Prev (Error Filter)'})
	keymap("n", "]E", function()
	  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
	end,
	{ desc = 'Diagnostic Jump Next (Error Filter)' })

	-- Toggle outline
	keymap("n","<leader>o", "<cmd>Lspsaga outline<CR>", { desc = 'LSP Toggle Outline' })

	-- Hover Doc
	-- If there is no hover doc,
	-- there will be a notification stating that
	-- there is no information available.
	-- To disable it just use ":Lspsaga hover_doc ++quiet"
	-- Pressing the key twice will enter the hover window
	keymap("n", "<leader>gD", "<cmd>Lspsaga hover_doc<CR>", { desc = 'LSP Hover Doc' })

	-- If you want to keep the hover window in the top right hand corner,
	-- you can pass the ++keep argument
	-- Note that if you use hover with ++keep, pressing this key again will
	-- close the hover window. If you want to jump to the hover window
	-- you should use the wincmd command "<C-w>w"
	keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>", { desc = 'LSP Hover Doc Keep' })

	-- Call hierarchy
	keymap("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { desc = 'LSP Incoming Calls' })
	keymap("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { desc = 'LSP Outgoing Calls'})

	-- Floating terminal
	keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>", { desc = 'LSP Floating Terminal' })
end

require("lazy").setup({
	-- Looks
	{
		"catppuccin/nvim",
		name = "Catppuccin",
		lazy = false,
		depends = {
			'nvim-treesitter/nvim-treesitter'
		},
		config =  function()
			local catppuccin = require("catppuccin")
			catppuccin.setup({
				compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
					transparency = false,
					term_colors = false,
					dim_inactive = {
						enabled = false,
						shade = "dark",
						percentage = 0.15,
					},
					styles = {
						comments = { "italic" },
						functions = { "bold" },
						keywords = { "italic" },
						strings = {},
						variables = {},
					},
					integrations = {
						treesitter = true,
						native_lsp = {
							enabled = true,
							virtual_text = {
								errors = { "italic" },
								hints = { "italic" },
								warnings = { "italic" },
								information = { "italic" },
							},
							underlines = {
								errors = { "underline" },
								hints = { "underline" },
								warnings = { "underline" },
								information = { "underline" },
							}
						},
						lsp_trouble = true,
						lsp_saga = true,
						gitgutter = true,
						gitsigns = false,
						telescope = true,
						nvimtree = {
							enabled = false,
							show_root = true,
						},
						which_key = true,
						indent_blankline = {
							enabled = true,
							colored_indent_levels = true,
						},
						dashboard = true,
						neogit = false,
						vim_sneak = false,
						fern = false,
						barbar = false,
						bufferline = true,
						markdown = true,
						lightspeed = false,
						ts_rainbow = false,
						hop = false,
					}
				}
			)
			cmd [[ colorscheme catppuccin ]]
		end

	},
	{ 'nvim-tree/nvim-web-devicons' },
	{ "lukas-reineke/indent-blankline.nvim", configure = true},
  {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      ---@module "ibl"
      ---@type ibl.config
      opts = {},
  },

	-- Navigation
	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		opts = {
			theme = 'doom',
			config = {
				header = {
					"                                                       ",
					"                                                       ",
					"                                                       ",
					" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
					" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
					" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
					" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
					" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
					" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
					"                                                       ",
					"                                                       ",
					"                                                       ",
					"                                                       ",
				},
				center = {
					{
						icon = "  ",
						desc = "Find  File                              ",
						action = 'Telescope find_files',
						shortcut = "<Leader>ff",
					},
					{
						icon = "  ",
						desc = "Project grep                            ",
						action = "Telescope live_grep",
						shortcut = "<Leader> fg",
					},
					{
						icon = "  ",
						desc = "Open Nvim config                        ",
						action = "tabnew $MYVIMRC | tcd %:p:h",
						shortcut = "<Leader> e v",
					},
					{
						icon = "  ",
						desc = "New file                                ",
						action = "enew",
					},
					{
						icon = "  ",
						desc = "Quit Nvim                               ",
						action = "qa"
					}
				}
			}
		},
		dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-telescope/telescope.nvim' }
	},
	{
	  'nvim-tree/nvim-tree.lua',
	  config = true,
	  dependencies = {
	    'nvim-tree/nvim-web-devicons', -- optional, for file icons
	  },
	  lazy = false,
	  keys = { { '<leader>tt', '<cmd>:NvimTreeToggle<CR>' } }
	},
	{ 'airblade/vim-gitgutter' },
	{
		'francoiscabrol/ranger.vim',
		keys = {
			{ "<leader>vrf", "<cmd>:RangerCurrentFile<CR>", { silent = true, desc = "Ranger current file" } },
			{ "<leader>vrd", "<cmd>:RangerWorkingDirectory<CR>", { silent = true, desc = "Ranger current directory" } }
		}
	},
	{
		'sindrets/diffview.nvim',
		keys= {
			{ "<leader>ddf", "<cmd>:DiffviewOpen --staged<CR>" },
			{ "<leader>ddh", "<cmd>:DiffviewFileHistory<CR>" },
			{ "<leader>ddc", "<cmd>:DiffviewClose<CR>" }
		}
	},
	{
		'mbbill/undotree',
		keys = { {"<leader>vu", "<cmd>:UndotreeToggle<CR>", { desc = "Undo tree" }} }
	},
	{
		'szw/vim-maximizer',
		keys  = {
			{ "<leader>vm", "<cmd>:MaximizerToggle<CR>", { silent = true, desc = "Maximize toggle" }},
		}
	},
	{
		'akinsho/bufferline.nvim',
		lazy = false,
		dependecies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('bufferline').setup({
				options = {
					mode = 'tabs',
					numbers = "ordinal",
					enforce_regular_tabs = true
				}
			})
		end
	},
	{
		'rcarriga/nvim-notify',
		lazy = false,
		config = function()
			vim.notify = require("notify")
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons' },
		config = true
	},

	-- Syntax
	{ 'HerringtonDarkholme/yats.vim' },
	{ 'neovimhaskell/haskell-vim' },
	{ 'hashivim/vim-terraform' },
	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup({
			  ensure_installed = { "c_sharp", "comment", "bash", "vimdoc", "sql", "rust", "markdown", "markdown_inline", "html", "python", "lua", "fsharp", "typescript", "kotlin" },
			  sync_install = false,
			  auto_install = true,
			  highlight = {
				enable = true
			  }
			})
		end
	},

	-- Movement
	{
		"kylechui/nvim-surround",
		event = "InsertEnter",
		config = true
	},
	{ 'Raimondi/delimitMate', event = "InsertEnter" },
	{
		'bkad/CamelCaseMotion',
		event = "BufEnter",
		config = function()
			vim.g.camelcasemotion_key = '-'
			cmd [[
				noremap -w <Plug>CamelCaseMotion_w
				noremap -b <Plug>CamelCaseMotion_b
				noremap -e <Plug>CamelCaseMotion_e
			]]
		end
	},
	{ 'machakann/vim-swap', event = "InsertEnter" },
	-- Completion,
	{ 'SirVer/ultisnips' },
	{ 'quangnguyen30192/cmp-nvim-ultisnips', dependencies = { 'SirVer/ultisnips' } },
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		dependencies = {
		  "hrsh7th/cmp-nvim-lsp",
		  "hrsh7th/cmp-buffer",
		  'hrsh7th/cmp-path',
		  'hrsh7th/cmp-cmdline',
		 'quangnguyen30192/cmp-nvim-ultisnips'
		},
		config = function()
			-- Set up nvim-cmp.
			local cmp = require'cmp'

			cmp.setup({
				snippet = {
				  expand = function(args)
					  vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				  end,
				},
				window = {
				  completion = cmp.config.window.bordered(),
				  documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
				  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
				  ['<C-f>'] = cmp.mapping.scroll_docs(4),
				  ['<C-Space>'] = cmp.mapping.complete(),
				  ['<C-e>'] = cmp.mapping.abort(),
				  ['<CR>'] = cmp.mapping.confirm({
					select = true,
					behavior = cmp.ConfirmBehavior.Insert
				  }) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
				  { name = 'nvim_lsp' },
				  { name = 'ultisnips' }, -- For ultisnips users.
				}, {
				  { name = 'buffer' },
				})
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype('gitcommit', {
			sources = cmp.config.sources({
			  { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
			}, {
			  { name = 'buffer' },
			})
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ '/', '?' }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
			  { name = 'buffer' }
			}
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(':', {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
			  { name = 'path' }
			}, {
			  { name = 'cmdline' }
			})
			})
		end
	},

	-- Linting
	{
        'neovim/nvim-lspconfig',
        event = {"BufReadPre", "BufNewFile"}
    },
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim"
		},
		event = 'BufEnter',
		config = function()
			require('mason').setup({
				ui = {
					icons = {
						package_installed = "✓"
					}
				}
			})
		end
	},
	{
		'lvimuser/lsp-inlayhints.nvim',
		config = true
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup {
        ensure_installed = {
          "lua_ls",
          "omnisharp",
          "terraformls",
          "rust_analyzer",
          "html",
          "fsautocomplete",
          "harper_ls",
          "vtsls"
        }
			}

			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			vim.lsp.config('omnisharp', {
				capabilities = capabilities
			})

			vim.lsp.config('rust_analyzer', {
				capabilities = capabilities
			})

			vim.lsp.config('lua_ls', {
				capabilities = capabilities
			})

			vim.lsp.config('terraformls', {
				capabilities = capabilities
			})

			vim.lsp.config('html', {
				capabilities = capabilities
			})

			vim.lsp.config('fsautocomplete', {
				capabilities = capabilities
			})

			vim.lsp.config('harper_ls', {
				capabilities = capabilities
			})

			vim.lsp.config('vtsls', {
				capabilities = capabilities
			})
		end,
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"lvimuser/lsp-inlayhints.nvim"
		}
	},
	{
		'folke/trouble.nvim',
		config = true,
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle focus=false<cr>" },
			{ "<leader>xw", "<cmd>Trouble diagnostics lsp_workspace_diagnostics<cr>" },
			{ "<leader>xd", "<cmd>Trouble diagnostics lsp_document_diagnostics<cr>" },
			{ "<leader>xq", "<cmd>Trouble diagnostics quickfix<cr>" },
			{ "<leader>xl", "<cmd>Trouble diagnostics loclist<cr>" },
		}
	},
	{
		"glepnir/lspsaga.nvim",
		config = function()
			require("lspsaga").setup({})
			lspsagaKeyMappings()
		end,
		requires = { "nvim-tree/nvim-web-devicons", 'williamboman/mason-lspconfig.nvim' }
	},

	-- Finders
	{
		'windwp/nvim-spectre',
		dependencies = 'nvim-lua/plenary.nvim',
		event = 'InsertEnter',
		keys = {
			{ '<leader>S', "<cmd>lua require('spectre').open()<CR>", { noremap = true, desc = 'Spectre Open' } },
			{ '<leader>sw', "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", { noremap = true } },
			{ '<leader>s', "<esc>:lua require('spectre').open_visual()<CR>", { vnoremap = true } },
			{ '<leader>s', "<esc>:lua require('spectre').open_visual()<CR>", { vnoremap = true } },
			{ '<leader>sp', "viw:lua require('spectre').open_file_search()<cr>", { noremap = true } }
		},
	},
	{
		'wincent/scalpel',
		event = 'InsertEnter'
	},
	{ 'nvim-lua/plenary.nvim' },
	{
		'nvim-telescope/telescope.nvim',
		config = function()
			local telescope = require('telescope')
			telescope.load_extension("notify")
			telescope.setup {
				defaults = {
					file_ignore_patterns = {"node_modules", "bin", "Migrations"}
				}
			}
		end,
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzf-native.nvim'
		},
		keys = {
		  { "<leader>ff", "<cmd>Telescope find_files<cr>" },
		  { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
		  { "<leader>fs", "<cmd>Telescope git_status<cr>" },
		  { "<leader>fb", "<cmd>Telescope buffers<cr>" },
		  { "<leader>fc", "<cmd>Telescope commands<cr>" },
		  { "<leader>fo", "<cmd>Telescope oldfiles<cr>" }
		}
	},
	-- Util	
	{
		"folke/which-key.nvim",
		config = function()
		  vim.o.timeout = true
		  vim.o.timeoutlen = 300
		  require("which-key").setup({})
		end
	},
	{ 'guns/xterm-color-table.vim' },
	{ 'gpanders/editorconfig.nvim' },
	{ 'vim-scripts/AnsiEsc.vim' },
	{
		"folke/todo-comments.nvim",
		dependecies = { "nvim-lua/plenary.nvim" },
		config = true,
		keys = { { '<leader>ft', ":TodoTelescope<CR>", { noremap = true } } }
	},
	{
		'numToStr/Comment.nvim',
		config = true,
		event = 'InsertEnter'
	},

	-- Debugging 
	{
		"nvim-neotest/nvim-nio"
	},
	{
		"rcarriga/nvim-dap-ui",
		dependecies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
		config = function()
			local dap = require('dap')
			local dapui = require('dapui')

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end
	},
	{
		'mfussenegger/nvim-dap',
		config = function()
			local dap = require('dap')

			dap.adapters.coreclr = {
 				type = 'executable',
				command = '/usr/bin/netcoredbg',
				args = {'--interpreter=vscode'}
			}

			require('dap.ext.vscode').load_launchjs(nil, { coreclr = { 'cs' } })

		end,
		keys = {
			{ '<F5>', "<cmd>lua require'dap'.continue()<CR>", keysNoRemapSilent },
			{ '<F10>', "<cmd>lua require'dap'.step_over()<CR>", keysNoRemapSilent },
			{ '<F11>', "<cmd>lua require'dap'.step_into()<CR>", keysNoRemapSilent },
			{ '<F12>', "<cmd>lua require'dap'.step_out()<CR>", keysNoRemapSilent },
			{ '<F4>', "<cmd>lua require'dap'.terminate()<CR>", keysNoRemapSilent },
			{ '<leader>b', "<cmd>lua require'dap'.toggle_breakpoint()<CR>", keysNoRemapSilent },
			{ '<leader>B', "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", keysNoRemapSilent },
			{ '<Leader>lp', "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", keysNoRemapSilent },
			{ '<Leader>dr', "<Cmd>lua require'dap'.repl.open()<CR>", keysNoRemapSilent },
			{ '<Leader>dl', "<Cmd>lua require'dap'.run_last()<CR>", keysNoRemapSilent }
		}
	},
	{
		'kamykn/spelunker.vim',
		config = function()
			cmd [[
				let g:spelunker_target_min_char_len = 3
				let g:spelunker_check_type = 2

				augroup spelunker
					autocmd!
					" Setting for g:spelunker_check_type = 2:
					autocmd CursorHold *.cs,*.json,*.md call spelunker#check_displayed_words()
				augroup END
			]]
		end
	},
	{
		'chentoast/marks.nvim',
		config = function()
			require('marks').setup {
				default_mappings = true,
				signs = true,
				mappings = {}
			  }
		end
	},
	{
	  "iamcco/markdown-preview.nvim",
	  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	  build = "cd app && yarn install",
	  init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	  end,
	  ft = { "markdown" }
	},
  { "lbrayner/vim-rzip" }
})

---------- FILE TYPE CONFIGURATIONS ----------

local function getAutoCmdParams(filePatterns, callbackFunc)
	return {
		pattern = filePatterns,
		callback = callbackFunc,
		once = true
	}
end

local function setFileTypeConfigurationTriggers()
	-- Python
	local function configurePython()
		vim.o.expandtab = true
		vim.o.tabstop = 4
		vim.o.softtabstop = 4
		vim.o.shiftwidth = 4
	end

	-- C#
	local function configureCSharp()
		vim.o.expandtab = true
		vim.o.tabstop = 4
		vim.o.softtabstop = 4
		vim.o.shiftwidth = 4
	end

	-- F#
	local function configureFSharp()
		vim.o.expandtab = true
		vim.o.tabstop = 4
		vim.o.softtabstop = 4
		vim.o.shiftwidth = 4
	end

	-- Typescript
	local function configureTypescript()
		vim.o.expandtab = true
		vim.o.tabstop = 2
		vim.o.softtabstop = 2
		vim.o.shiftwidth = 2
	end

	api.nvim_create_autocmd("BufWinEnter", getAutoCmdParams({"*.py"}, configurePython))
	api.nvim_create_autocmd("BufWinEnter", getAutoCmdParams({"*.cs"}, configureCSharp))
	api.nvim_create_autocmd("BufWinEnter", getAutoCmdParams({"*.fs"}, configureFSharp))
	api.nvim_create_autocmd("BufWinEnter", getAutoCmdParams({"*.ts","*.tsx"}, configureTypescript))
end
setFileTypeConfigurationTriggers()

---------- KEY BINDINGS ----------

-- Toggles relative line numbers
keymap("n", "<leader>vr", "<cmd>:set invrelativenumber<CR>")

-- Save buffer
keymap("n", "<C-s>", "<cmd>:w<CR>")

-- Close buffer
keymap("n", "<A-q>", "<cmd>:q<CR>")

-- Save and close buffer
keymap("n", "<A-s>", "<cmd>:wq<CR>")

-- Navigation

keymap("n", "<A-l>", "<cmd>:tabnext<CR>")
keymap("n", "<A-h>", "<cmd>:tabprev<CR>")
keymap("n", "<leader>tn", "<cmd>:tabnew<CR>", { desc = "Open new tab" })

keymap("n", "<C-h>", "<C-w>h<CR>")
keymap("n", "<C-j>", "<C-w>j<CR>")
keymap("n", "<C-k>", "<C-w>k<CR>")
keymap("n", "<C-l>", "<C-w>l<CR>")

keymap("n", "<leader>|", "<C-w>v<CR>")
keymap("n", "<leader>_", "<C-w>s<CR>")


-- Up and Down
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "<C-d>", "<C-d>zz")

-- Clear search 
keymap("n", "<leader>vl", "<cmd>:let @/=\"\"<CR>")

-- Copy to system register
keymap("v", "<leader>cc", '"+y')

-- Deal with annoying cut functionality

keymap("v", "<leader>p", "\"cp");
keymap("n", "<leader>p", "\"cp");

keymap("v", "<leader>P", "\"cP");
keymap("n", "<leader>P", "\"cP");

keymap("v", "x", "\"cx");
keymap("n", "x", "\"cx");

keymap("v", "<leader>y", '"cy')

---------- SCRIPTS ----------
cmd [[
	xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

	function! ExecuteMacroOverVisualRange()
	  echo "@".getcmdline()
	  execute ":'<,'>normal @".nr2char(getchar())
	endfunction
]]
