-- init.lua – Full Neovim Config 0.12+
-- Last updated: November 26, 2025

local ok, err = pcall(function()

  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git", "clone", "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  vim.g.mapleader = " "
  vim.g.maplocalleader = ","

  -- Basic Settings
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.smartindent = true
  vim.opt.wrap = false
  vim.opt.termguicolors = true
  vim.opt.cursorline = true
  vim.opt.clipboard = "unnamedplus"
  vim.opt.mouse = "a"
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.updatetime = 1000
  vim.opt.timeoutlen = 500
  vim.opt.undofile = true
  vim.opt.signcolumn = "yes"
  vim.opt.scrolloff = 8
  vim.opt.sidescrolloff = 8
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.showmode = false
  vim.opt.swapfile = false
  vim.opt.backup = false

  -- Enhanced error logging
  local notify = vim.notify
  vim.notify = function(msg, level, opts)
    if level == vim.log.levels.ERROR then
      local f = io.open(vim.fn.stdpath("cache") .. "/nvim-error.log", "a")
      if f then f:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg .. "\n") f:close() end
    end
    notify(msg, level, opts)
  end

  require("lazy").setup({
    -- Colorscheme
    { "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function()
        require("tokyonight").setup({
          style = "storm", transparent = true, terminal_colors = true,
          styles = { sidebars = "transparent", floats = "transparent" },
        })
        vim.cmd([[colorscheme tokyonight]])
      end },

    -- Dashboard
    { "startup-nvim/startup.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }, config = function()
        require("startup").setup({
          theme = "dashboard",
          sections = {
            header = { type = "text", align = "center", margin = 5, content = {
                " Welcome to Neovim! ", " ",
                "       .         .          ",
                "   .       .   .       .    ",
                "     .   .       .   .      ",
                "  .     .     .     .   .   ",
                "    . .   . .   . .   . .   ",
                "  .   . .     .     . .   . ",
                "    .   .   .   .   .   .   ",
                "  . .     . . . . .     . . ",
                " ", " Happy Coding! ",
              }, highlight = "Statement" },
            body = { type = "mapping", align = "center", margin = 5, content = {
                { "Find File",      "Telescope find_files", "<leader>ff" },
                { "Search Text",    "Telescope live_grep",  "<leader>fg" },
                { "Open Buffers",   "Telescope buffers",    "<leader>fb" },
                { "Help",           "Telescope help_tags",  "<leader>fh" },
                { "Change Theme",   "PickColor",            "<leader>ct" },
                { "New File",       "ene | startinsert",    "<leader>n"  },
                { "Quit",           "qa",                   "<leader>q"  },
              }, highlight = "String" },
            footer = { type = "text", align = "center", margin = 5, content = { "Neovim - Built with love by xAI" }, highlight = "Constant" },
          },
        })
      end },

    -- File Explorer
    { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons", config = function()
        require("nvim-tree").setup({ view = { width = 30 }, filters = { dotfiles = false }, git = { enable = true } })
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
      end },

    -- Statusline
    { "nvim-lualine/lualine.nvim", dependencies = "nvim-tree/nvim-web-devicons", lazy = false, config = function()
        require("lualine").setup({
          options = { icons_enabled = true, theme = "auto", component_separators = { left = "", right = "" }, section_separators = { left = "", right = "" } },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { { "branch", icon = "git" }, "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
        })
      end },

    -- =========================
    -- LSP – Modern Setup (vim.lsp.config)
    -- =========================
    { "neovim/nvim-lspconfig", dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" }, config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>fd", vim.lsp.buf.format, opts)
        end

        -- Mason setup
        mason.setup()
        mason_lspconfig.setup({
          ensure_installed = { "lua_ls", "pyright", "ts_ls" },
          automatic_installation = true,
        })

        -- Per-server configuration using vim.lsp.config
        vim.lsp.config("lua_ls", {
          cmd = { "lua-language-server" },
          root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
          on_attach = on_attach,
          capabilities = capabilities,
        })

        vim.lsp.config("pyright", {
          cmd = { "pyright-langserver", "--stdio" },
          root_markers = { "pyrightconfig.json", "pyproject.toml", ".git" },
          on_attach = on_attach,
          capabilities = capabilities,
        })

        vim.lsp.config("ts_ls", {
          cmd = { "typescript-language-server", "--stdio" },
          root_markers = { "tsconfig.json", "jsconfig.json", ".git" },
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            on_attach(client, bufnr)
          end,
          capabilities = capabilities,
        })

        -- Enable all configured servers
        vim.lsp.enable({ "lua_ls", "pyright", "ts_ls" })

        vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP" })
      end },

    -- Completion
    { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp","hrsh7th/cmp-buffer","hrsh7th/cmp-path","L3MON4D3/LuaSnip","saadparwaiz1/cmp_luasnip","rafamadriz/friendly-snippets" }, config = function()
        local cmp = require("cmp")
        cmp.setup({
          snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          }),
          sources = { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } },
        })
      end },

    -- Telescope
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } }, config = function()
        local telescope = require("telescope")
        telescope.setup({ defaults = { layout_strategy = "vertical" } })
        telescope.load_extension("fzf")
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
        vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
        vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
        vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
      end },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua","python","javascript","html","css","typescript","bash","json","yaml" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end },

    -- Copilot
    { "github/copilot.vim", config = function()
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
        vim.api.nvim_set_keymap("i", "<C-K>", "copilot#Next()",     { expr = true, silent = true })
        vim.api.nvim_set_keymap("i", "<C-L>", "copilot#Previous()", { expr = true, silent = true })
      end },

    -- Other plugins
    { "ziontee113/color-picker.nvim", config = function() require("color-picker").setup() vim.keymap.set("n", "<leader>ct", "<cmd>PickColor<CR>") end },
    { "windwp/nvim-autopairs",        config = true },
    { "numToStr/Comment.nvim",        config = true },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },
    { "akinsho/bufferline.nvim",      dependencies = "nvim-tree/nvim-web-devicons", config = true },
    { "akinsho/toggleterm.nvim",      config = function() require("toggleterm").setup({ open_mapping = [[<C-\>]] }) end },
    { "folke/which-key.nvim",         config = true },
    { "rmagatti/auto-session",        config = true },
    { "kylechui/nvim-surround",       config = true },
    { "folke/trouble.nvim",           dependencies = "nvim-tree/nvim-web-devicons", config = true },
    { "folke/todo-comments.nvim",     dependencies = "nvim-lua/plenary.nvim", config = true },
    { "folke/zen-mode.nvim",          config = true },
    { "NvChad/nvim-colorizer.lua",    config = true },
  })

  -- Keybindings
  vim.keymap.set("n", "<leader>w", ":w<CR>")
  vim.keymap.set("n", "<leader>q", ":q<CR>")
  vim.keymap.set("n", "<leader>n", ":ene | startinsert<CR>", { desc = "New File" })
  vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select All" })
  vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to System" })
  vim.keymap.set("v", "<leader>y", '"+y')
  vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from System" })

  -- Auto-save
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "TextChangedI" }, {
    callback = function()
      if vim.fn.expand("%") ~= "" and vim.bo.modified and vim.bo.modifiable then
        vim.cmd("silent! write")
      end
    end,
  })

end)

if not ok then
  vim.notify("Config error: " .. tostring(err), vim.log.levels.ERROR)
  vim.cmd[[set runtimepath=$VIMRUNTIME]]
end
-- End of init.lua
