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
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'show diagnostics' })

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Move between buffers
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Splits
vim.keymap.set('n', '<leader>s', ':split<CR>', { silent = true })
vim.keymap.set('n', '<leader>v', ':vsplit<CR>', { silent = true })

-- Terminal Mode
vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], { desc = 'Move focus to the left window' })
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], { desc = 'Move focus to the right window' })
vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], { desc = 'Move focus to the lower window' })
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], { desc = 'Move focus to the upper window' })

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
    'https://github.com/esmuellert/codediff.nvim',
    'https://github.com/windwp/nvim-autopairs',
    'https://github.com/ellisonleao/gruvbox.nvim',
    'https://github.com/nvim-mini/mini.tabline',
    'https://github.com/nvim-mini/mini.icons',
    'https://github.com/coder/claudecode.nvim',
    'https://github.com/3rd/image.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/akinsho/toggleterm.nvim',
    'https://github.com/pandalec/gradle.nvim',
    'https://github.com/bullets-vim/bullets.vim',
})

-- Colorscheme
require("gruvbox").setup({})
vim.cmd.colorscheme("gruvbox")

-- Which-Key
local wk = require("which-key")
wk.setup({
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

-- Close a buffer without wrecking your window layout
local function close_buffer(buf)
    buf = buf or vim.api.nvim_get_current_buf()

    if vim.bo[buf].modified then
        local name = vim.fn.bufname(buf)
        if name == "" then name = "[No Name]" end
        local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Yes\n&No\n&Cancel", 3)
        if choice == 1 then
            vim.api.nvim_buf_call(buf, function() vim.cmd("write") end)
        elseif choice ~= 2 then
            return
        end
    end

    -- Move every window showing this buffer onto another one first,
    -- so :bdelete doesn't close the windows
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        vim.api.nvim_win_call(win, function()
            local alt = vim.fn.bufnr("#")
            if alt > 0 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
                vim.cmd("buffer " .. alt)
            else
                vim.cmd("bprevious")
            end
            if vim.api.nvim_get_current_buf() == buf then
                vim.cmd("enew") -- it was the only buffer
            end
        end)
    end

    if vim.api.nvim_buf_is_valid(buf) then
        vim.cmd("bdelete! " .. buf)
    end
end

-- Close every listed buffer except the current one (skips unsaved ones)
local function close_others()
    local current = vim.api.nvim_get_current_buf()
    local skipped = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.bo[buf].buflisted then
            if vim.bo[buf].modified then
                skipped = skipped + 1
            else
                vim.cmd("bdelete " .. buf)
            end
        end
    end
    if skipped > 0 then
        vim.notify(("Kept %d buffer(s) with unsaved changes"):format(skipped), vim.log.levels.WARN)
    end
end

wk.add({
    { "<leader>b",  group = "buffers" },
    { "<leader>bb", function() require("fzf-lua").buffers() end, desc = "Pick buffer" },
    { "<leader>bl", "<cmd>b#<cr>",                               desc = "Last buffer" },
    { "<leader>bd", function() close_buffer() end,               desc = "Close buffer" },
    { "<leader>bo", close_others,                                desc = "Close other buffers" },
    { "<leader>bx", "<cmd>enew<cr>",                             desc = "New empty buffer" },
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
    keymap = {
        preset = 'super-tab',
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
    'jsonls',
    'yamlls',
    'taplo',
    'jdtls',
    'marksman'
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

-- Codediff
require("codediff").setup({})

-- Autopairs
require("nvim-autopairs").setup({})

-- Mini
require('mini.icons').setup({})
require('mini.tabline').setup({})

-- Claude Code
require("claudecode").setup({})

wk.add({
    { "<leader>a",  group = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'oil',
    callback = function(ev)
        vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', { buffer = ev.buf, desc = 'Add file' })
    end,
})

-- Image
require("image").setup({})

-- Telescope
require("telescope").setup({})

-- ToggleTerm
require("toggleterm").setup({})

wk.add({
    { "<leader>t",  group = "Terminal" },
    { "<leader>tt", "<cmd>ToggleTerm<cr>",                      desc = "Toggle terminal" },
    { "<leader>tn", "<cmd>TermNew<cr>",                         desc = "New terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "Float terminal" },
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "Vertical terminal" },
    { "<leader>ts", "<cmd>TermSelect<cr>",                      desc = "Select terminal" },
})

-- Easily escape terminal mode, but only in toggleterm buffers so it doesn't
-- swallow double-esc in other terminals (e.g. Claude Code's rewind binding)
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'toggleterm',
    callback = function(ev)
        vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { buffer = ev.buf, desc = 'Exit terminal mode' })
    end,
})

-- Gradle
require("gradle").setup({
    keymaps = false,
})
