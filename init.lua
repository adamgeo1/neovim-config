-- Base Configs

-- Set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Line numbers
vim.o.relativenumber = true
vim.o.number = true

-- Spacing
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Case insensitive searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Sync clipboards
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Raise dialog if unsaved buffer
vim.o.confirm = true

-- Snappy escape
vim.o.timeoutlen = 500

-- Vim diagnostics
vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    float = { source = 'if_many' },
    jump = { float = true },
})

-- Show diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'show diagnostics' })

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank() end
})

-- Plugins

vim.pack.add({
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/neovim/nvim-lspconfig',
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') }, -- pinning so rust binary dependency automatically downloads
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/kdheepak/lazygit.nvim',
})

-- Which-Key
require("which-key").setup({
    preset = "helix",
    plugins = {
        marks = true,
        registers = true,
        spelling = { enabled = true, suggestions = 20 },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
        },
    },
})

-- Fzflua
require("fzf-lua").setup({
    keymap = {
        builtin = {
            ["<C-d>"] = 'preview-page-down',
            ["<C-u>"] = 'preview-page-up',
        }
    }
})

vim.keymap.set('n', '<leader><leader>', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Find live grep' })

-- TreeSitter
vim.cmd('syntax off')
vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end,
})

-- Blink
require('blink.cmp').setup({
    signature = {
        enabled = true,
    },
})

-- Dap
local dap = require('dap')
dap.adapters.debugpy = function(cb, config)
    if config.request == 'attach' then
        cb({
            type = 'server',
            port = config.connect.port,
            host = config.connect.host or '127.0.0.1',
        })
    else
        cb({
            type = 'executable',
            command = 'debugpy-adapter',
        })
    end
end
dap.configurations.python = { -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file',
        module = 'pytest',
        args = { '${file}', '-s' },
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file -k',
        module = 'pytest',
        args = function()
            local test_name = vim.fn.input('pytest -k: ')
            return { '${file}', '-s', '-k', test_name }
        end,
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
}
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug continue' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug terminate' })
vim.keymap.set('n', '<leader>dr', function()
    dap.repl.open({ height = 12 }, 'belowright split')
end, { desc = 'Debug open REPL' })
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dap-repl',
    callback = function(ev)
        vim.keymap.set('i', '<C-p>', function() require('dap.repl').on_up() end,
            { buffer = ev.buf, desc = 'DAP REPL previous history' })
        vim.keymap.set('i', '<C-n>', function() require('dap.repl').on_down() end,
            { buffer = ev.buf, desc = 'DAP REPL next history' })
    end,
})
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug run last' })
vim.keymap.set({ 'n', 'v' }, '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug hover' })
vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'Debug step over' })
vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'Debug step into' })
vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'Debug step out' })
vim.keymap.set('n', '<Up>', dap.restart_frame, { desc = 'Debug restart frame' })

-- LSP
vim.lsp.enable({
    'ty',
    'ruff',
    'lua_ls',
    'vtsls',
    'clangd',
})
vim.o.signcolumn = 'yes'
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
-- Auto-format ("lint") on save (adapted from neovim docs :help auto-format)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = vim.api.nvim_create_augroup('my.lsp.fmt', { clear = false }),
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

-- Oil
require("oil").setup({
    view_options = {
        show_hidden = true,
    },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- LazyGit
vim.keymap.set('n', '<leader>g', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
