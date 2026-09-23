-- Gradle
vim.pack.add({
    'https://github.com/pandalec/gradle.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/akinsho/toggleterm.nvim',
})
require("gradle").setup({
    keymaps = false,
})
