-- RISC-V assembly syntax/ftdetect
vim.pack.add({ 'https://github.com/henry-hsieh/riscv-asm-vim' })
vim.filetype.add({ extension = { s = "riscv_asm" } })
-- riscv-asm-vim's ftplugin only falls back to the default ISA string
-- ("rv64gc") the first time a buffer of this filetype is opened in the
-- session: the parsed remainder is cached in a SCRIPT-local (not buffer-
-- local) variable, so the second and every later .s buffer inherits the
-- first file's already-consumed (empty) string, hits xlen==0, and prints
-- "ERROR: Can't resolve remaining ISA string: ". Setting g:riscv_asm_isa
-- explicitly makes the ftplugin re-seed that variable from this value on
-- every buffer load instead of relying on the once-only fallback.
--
-- Deliberately not using riscv_asm_all_enable: it loads every RISC-V
-- extension's instruction keywords (incl. Zbb's `min`/`max` mnemonics),
-- which collide with and miscolor same-named data labels as instructions.
-- rv64gc matches what the container's gcc actually targets.
vim.g.riscv_asm_isa = "rv64gc"

-- riscv_asm's syntax/riscv_asm.vim guards on b:current_syntax and only
-- sources once per buffer, so once it's loaded, nothing re-triggers it even
-- when the syntax state actually needs rebuilding. Force a resync.
local function resync_riscv_asm_syntax(buf)
  if vim.bo[buf].filetype == "riscv_asm" then
    vim.api.nvim_buf_call(buf, function()
      vim.b.current_syntax = nil
      vim.cmd("set syntax=riscv_asm")
    end)
  end
end

-- codediff.nvim's diff/merge buffers for a .s file never (re)trigger that
-- load, so once a codediff session closes, the real buffer is left without
-- highlighting.
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeDiffClose",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      resync_riscv_asm_syntax(buf)
    end
  end,
})

-- :e reloading an already-open .s buffer doesn't change 'filetype' (it's
-- already riscv_asm), so FileType never refires either, but the reload
-- still invalidates the buffer's syntax state. b:current_syntax guard above
-- then sees it's "already loaded" and skips rebuilding it, leaving the
-- buffer permanently unhighlighted after the first :e.
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.s",
  callback = function(ev)
    resync_riscv_asm_syntax(ev.buf)
  end,
})
