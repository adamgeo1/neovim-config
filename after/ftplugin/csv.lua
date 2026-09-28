-- Automatically enable csvview's tabular display when opening csv files.
-- Normal/visual mode Tab and S-Tab are handled by csvview's own keymaps
-- (see plugin/csvview.lua).
vim.cmd("CsvViewEnable display_mode=border")
