-- ToggleTerm
vim.pack.add({
    'https://github.com/akinsho/toggleterm.nvim',
    'https://github.com/folke/which-key.nvim',
})
local wk = require("which-key")

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
