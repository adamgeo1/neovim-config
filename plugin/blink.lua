-- Blink
vim.pack.add({
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') }, -- pinning so rust binary dependency automatically downloads
})
require('blink.cmp').setup({
    signature = {
        enabled = true,
    },
    keymap = {
        preset = 'super-tab',
        ["<Tab>"] = { "select_next", "snippet_backward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
})
