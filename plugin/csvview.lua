vim.pack.add({
    "https://github.com/hat0uma/csvview.nvim",
})
require("csvview").setup({
    keymaps = {
        -- insert mode is handled in after/ftplugin/csv.lua and after/ftplugin/tsv.lua
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
})
