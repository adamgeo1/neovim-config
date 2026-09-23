-- Dap
vim.pack.add({ 'https://github.com/mfussenegger/nvim-dap' })
local dap = require('dap')
dap.adapters.debugpy = function(cb, config)
    if config.request == 'attach' then
        cb({
            type = 'server',
            port = config.connect.port,
            host = config.connect.host or '127.0.0.1',
        })
    else
        cb({
            type = 'executable',
            command = 'debugpy-adapter',
        })
    end
end
dap.configurations.python = { -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file',
        module = 'pytest',
        args = { '${file}', '-s' },
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
    {
        type = 'debugpy',
        request = 'launch',
        name = 'Pytest current file -k',
        module = 'pytest',
        args = function()
            local test_name = vim.fn.input('pytest -k: ')
            return { '${file}', '-s', '-k', test_name }
        end,
        justMyCode = false,
        python = function()
            local root = vim.fs.root(0, '.venv')
            return { root and root .. '/.venv/bin/python' or 'python3' }
        end,
        cwd = function()
            return vim.fs.root(0, '.venv') or vim.fn.getcwd()
        end,
    },
}
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug toggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug continue' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug terminate' })
vim.keymap.set('n', '<leader>dr', function()
    dap.repl.open({ height = 12 }, 'belowright split')
end, { desc = 'Debug open REPL' })
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dap-repl',
    callback = function(ev)
        vim.keymap.set('i', '<C-p>', function() require('dap.repl').on_up() end,
            { buffer = ev.buf, desc = 'DAP REPL previous history' })
        vim.keymap.set('i', '<C-n>', function() require('dap.repl').on_down() end,
            { buffer = ev.buf, desc = 'DAP REPL next history' })
    end,
})
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug run last' })
vim.keymap.set({ 'n', 'v' }, '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug hover' })
vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'Debug step over' })
vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'Debug step into' })
vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'Debug step out' })
vim.keymap.set('n', '<Up>', dap.restart_frame, { desc = 'Debug restart frame' })
