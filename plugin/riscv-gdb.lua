-- Interactive gdb for riscv64 binaries compiled from .s files, run via
-- QEMU user-mode's own "-g <port>" gdbstub (qemu-riscv64-static), connected
-- to by a native gdb-multiarch (riscv64 target support, but running
-- natively -- no emulation needed for gdb itself).
--
-- This is NOT wired through nvim-dap: gdb's --interpreter=dap cannot
-- reliably resume or step a remote (gdbstub) target at all -- continue,
-- pause, next, and REPL-evaluated commands all silently run the whole
-- program to completion regardless of breakpoints, even though the exact
-- same commands work correctly via plain gdb CLI, and DAP mode works fine
-- for a native (ptrace) target. That's a real limitation in gdb 15.1's
-- still-experimental DAP interpreter talking to a remote target, not
-- something fixable from this config. Plain gdb commands -- break,
-- continue, next, print, etc. -- in an ordinary interactive session work
-- correctly against this same setup, so that's what this opens.
--
-- Needs the binary compiled with `-g -static` (debug info, and no
-- dependency on riscv64 shared libraries this container doesn't have), and
-- the riscv-debug image (gdb-multiarch + qemu-user-static, native platform,
-- no --platform flag) built from term-only/debug.dockerfile.
local function debug_riscv()
    local program_name = vim.fn.expand('%:t:r')
    local hostcwd = vim.fn.getcwd()
    local program = hostcwd .. '/' .. program_name

    local script = 'qemu-riscv64-static -g 1234 ' .. program
        .. ' > ' .. hostcwd .. '/.debuggee-output.log 2>&1 & '
        -- Wait for the port to actually be listening before connecting, but
        -- via /proc/net/tcp (pure kernel-state read) rather than opening a
        -- probe connection: qemu's gdbstub only accepts ONE client ever, so
        -- a TCP-connect-based poll (e.g. bash's /dev/tcp) steals that one
        -- slot with its own probe connection, causing qemu to treat it as
        -- "the debugger attached and detached" and resume/exit before the
        -- real gdb ever connects. 04D2 is 1234 in hex; 0A is TCP_LISTEN.
        .. 'for i in $(seq 1 50); do '
        .. 'awk \'$2 ~ /:04D2$/ && $4 == "0A" {f=1} END{exit !f}\' /proc/net/tcp && break; '
        .. 'sleep 0.1; done; '
        .. 'exec gdb-multiarch -ex "set pagination off" -ex "file ' .. program .. '" -ex "target remote localhost:1234"'

    vim.cmd('botright new')
    vim.cmd('resize 20')
    vim.fn.termopen({
        'docker', 'run', '--rm', '-it',
        '-v', hostcwd .. ':' .. hostcwd,
        '-w', hostcwd,
        'riscv-debug',
        'bash', '-c', script,
    })
    vim.cmd('startinsert')
end

vim.api.nvim_create_user_command('RiscvGdb', debug_riscv, {})
vim.keymap.set('n', '<leader>dg', debug_riscv, { desc = 'Debug: open interactive gdb (riscv, via qemu gdbstub)' })
