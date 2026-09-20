return {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml' },
    settings = {
        yaml = {
            validate = true,
            format = { enable = true },
            schemaStore = { enable = true },
        },
    },
}
