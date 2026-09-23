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

vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
local wk = require("which-key")

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
