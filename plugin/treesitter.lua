-- TreeSitter
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })
vim.cmd('syntax off')
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        local ok = pcall(vim.treesitter.start)
        if not ok then
            vim.bo.syntax = vim.bo.filetype
        end
    end,
})
