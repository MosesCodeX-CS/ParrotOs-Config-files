
-- Minimal LSP Test for Neovim 0.12+ with Mason
local ok, err = pcall(function()
  local lspconfig = require("lspconfig")
  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")
  local cmp_nvim_lsp = require("cmp_nvim_lsp")

  mason.setup()
  mason_lspconfig.setup({
    ensure_installed = { "lua_ls", "pyright", "ts_ls" },
    automatic_installation = true,
  })

  local capabilities = cmp_nvim_lsp.default_capabilities()

  local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>fd", vim.lsp.buf.format, opts)
  end

  local servers = {
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    },
    pyright = {},
    ts_ls = {
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        on_attach(client, bufnr)
      end,
    },
  }

  for name, config in pairs(servers) do
    config = vim.tbl_extend("force", { on_attach = on_attach, capabilities = capabilities }, config)
    lspconfig[name].setup(config)
  end

  print("✅ LSP Test Setup Complete!")
end)

if not ok then
  vim.notify("LSP Test Error: " .. tostring(err), vim.log.levels.ERROR)
end
