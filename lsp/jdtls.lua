return {
    cmd = function(dispatchers, config)
        local root = (config or {}).root_dir or vim.fn.getcwd()
        local data_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. vim.fn.fnamemodify(root, ':p:h:t')
        return vim.lsp.rpc.start({ 'jdtls', '-data', data_dir }, dispatchers)
    end,
    filetypes = { 'java' },
    root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
}
