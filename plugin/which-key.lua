-- Which-Key
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
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
