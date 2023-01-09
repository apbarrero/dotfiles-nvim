--
-- configuration
--

-- decorations
local border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

-- config
vim.api.nvim_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

-- mason
require("mason").setup()
require("mason-lspconfig").setup(
  {
    ensure_installed = {
      "arduino_language_server",
      "astro",
      "bashls",
      "clangd",
      "cssls",
      "eslint",
      "graphql",
      "html",
      "jsonls",
      "pyright",
      "rust_analyzer",
      "sqlls",
      "sumneko_lua",
      "texlab",
      "tsserver",
      "vimls",
      "yamlls"
    }
  }
)

--
-- keymaps
--

vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "Go to definition" })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Info hover" })
vim.keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, { desc = "Go to implementation" })
vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "List references" })
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("v", "ga", vim.lsp.buf.range_code_action, { desc = "Range code actions" })
vim.keymap.set("n", "go", require("telescope.builtin").lsp_document_symbols, { desc = "Document symbols" })
vim.keymap.set("n", "<space>=", function() vim.lsp.buf.format { async = true } end, { desc = "Format code" })
vim.keymap.set("v", "<space>=", vim.lsp.buf.format, { desc = "Format range of code" })

vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
vim.keymap.set('n', '<space>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = "List workspace folders" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<space>d", vim.diagnostic.setloclist, { desc = "Set loc list" })

-- diagnostic
vim.diagnostic.config({ update_in_insert = true })

vim.diagnostic.open_float =
(function(orig)
  return function(opts)
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    -- A more robust solution would check the "scope" value in `opts` to
    -- determine where to get diagnostics from, but if you're only using
    -- this for your own purposes you can make it as simple as you like
    local diagnostics = vim.diagnostic.get(opts.bufnr or 0, { lnum = lnum })
    local max_severity = vim.diagnostic.severity.HINT
    for _, d in ipairs(diagnostics) do
      -- Equality is "less than" based on how the severities are encoded
      if d.severity < max_severity then
        max_severity = d.severity
      end
    end
    local border_color =
    ({
      [vim.diagnostic.severity.HINT] = "NonText",
      [vim.diagnostic.severity.INFO] = "Question",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
      [vim.diagnostic.severity.ERROR] = "ErrorMsg"
    })[max_severity]
    opts.border = {
      { "╭", border_color },
      { "─", border_color },
      { "╮", border_color },
      { "│", border_color },
      { "╯", border_color },
      { "─", border_color },
      { "╰", border_color },
      { "│", border_color }
    }
    orig(opts)
  end
end)(vim.diagnostic.open_float)

--
-- servers
--

local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local schemastore = require('schemastore')

local capabilities = cmp_nvim_lsp.default_capabilities()

lspconfig.tsserver.setup {
  capabilities = capabilities,
  settings = {
    javascript = {
      format = {
        enable = false -- Use the formatter from null-ls
      }
    },
    typescript = {
      format = {
        enable = false -- Use the formatter from null-ls
      }
    }
  }
}
lspconfig.eslint.setup { capabilities = capabilities }
lspconfig.astro.setup { capabilities = capabilities }
lspconfig.bashls.setup { capabilities = capabilities }
lspconfig.clangd.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.texlab.setup { capabilities = capabilities }
lspconfig.cssls.setup { capabilities = capabilities }
lspconfig.sumneko_lua.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim", "use" }
      },
      telemetry = {
        enable = false
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
}
lspconfig.jsonls.setup {
  capabilities = capabilities,
  settings = {
    json = {
      schemas = schemastore.json.schemas(),
      validate = { enable = true }
    }
  }
}
lspconfig.yamlls.setup { capabilities = capabilities }
