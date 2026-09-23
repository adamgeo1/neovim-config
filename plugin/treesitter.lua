-- TreeSitter
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })
vim.cmd('syntax off')
vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end,
})
