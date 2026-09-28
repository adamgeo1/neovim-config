-- line navigation
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.keymap.set("n", "j", "gj", { buffer = true })
vim.keymap.set("n", "k", "gk", { buffer = true })
vim.keymap.set("n", "0", "g0", { buffer = true })
vim.keymap.set("n", "$", "g$", { buffer = true })

-- spell check
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en_us" }

-- bullets
local function on_bullet()
    local line = vim.api.nvim_get_current_line()
    local prefix = line:match("^(%s*[-*+]%s+%[.%]%s+)") -- - [ ] task
        or line:match("^(%s*[-*+]%s+)")                 -- - item
        or line:match("^(%s*%d+[.)]%s+)")               -- 1. item
        or line:match("^(%s*%a[.)]%s+)")                -- a. item
    if not prefix then return false end

    local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-based byte offset of the cursor
    local is_empty = line:sub(#prefix + 1):match("^%s*$") ~= nil
    local at_start = col <= #prefix

    return is_empty or at_start
end

local function feed(keys, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), mode, false)
end

local nav = require("table-nvim.nav")

local function in_table()
    return vim.api.nvim_get_current_line():match("^%s*|")
end

vim.keymap.set("i", "<Tab>", function()
    if in_table() then
        feed(nav.next(), "n")
    elseif on_bullet() then
        feed("<C-t>", "m")
    else
        feed("<Tab>", "n")
    end
end, { buffer = true, desc = "Table cell / indent bullet" })

vim.keymap.set("i", "<S-Tab>", function()
    if in_table() then
        feed(nav.prev(), "n")
    elseif on_bullet() then
        feed("<C-d>", "m")
    else
        feed("<S-Tab>", "n")
    end
end, { buffer = true, desc = "Table cell / unindent bullet" })

vim.keymap.set("n", "<Tab>", nav.next, { buffer = true, expr = true, desc = "Next table cell" })
vim.keymap.set("n", "<S-Tab>", nav.prev, { buffer = true, expr = true, desc = "Prev table cell" })
