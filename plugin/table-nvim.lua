vim.pack.add({ "https://github.com/SCJangra/table-nvim" })

require("table-nvim").setup({
    mappings = {
        next = false, -- handled in after/ftplugin/markdown.lua
        prev = false,
    }
})
