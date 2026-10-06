-- TreeSitter
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })
vim.cmd('syntax off')

-- `:syntax off` disables the normal FileType -> 'syntax' option -> legacy
-- highlighting chain, so setting 'syntax' afterwards is a no-op; source the
-- syntax file directly instead.
local function start_legacy_syntax(ft)
    vim.cmd('runtime! syntax/' .. ft .. '.vim')
end

vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        -- vimtex's own regex syntax is more complete than the latex treesitter
        -- parser and some vimtex features depend on it; see :h vimtex-faq-treesitter
        if ft == 'tex' or ft == 'plaintex' or ft == 'bib' then
            start_legacy_syntax(ft)
            return
        end
        local lang = vim.treesitter.language.get_lang(ft) or ft
        local installed = require('nvim-treesitter.config').get_installed('parsers')
        if not vim.tbl_contains(installed, lang) and require('nvim-treesitter.parsers')[lang] then
            require('nvim-treesitter').install(lang):wait(120000)
        end
        local ok = pcall(vim.treesitter.start)
        if not ok then
            start_legacy_syntax(ft)
        end
    end,
})
