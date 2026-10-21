vim.pack.add({ 'https://github.com/lervag/vimtex' })

vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_quickfix_mode = 0

-- Delete vimtex's auxiliary/junk files (aux, log, synctex, etc.) on exit,
-- keeping the .tex source and the compiled .pdf.
vim.api.nvim_create_autocmd('VimLeavePre', {
  pattern = '*',
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'tex' then
        vim.api.nvim_buf_call(buf, function()
          if vim.fn.exists(':VimtexClean') == 2 then
            vim.cmd('VimtexClean')
          end
        end)
      end
    end
  end,
})

