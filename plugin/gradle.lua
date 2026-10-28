-- Gradle
vim.pack.add({
    'https://github.com/oclay1st/gradle.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
    'https://github.com/folke/which-key.nvim',
})
local wk = require("which-key")

-- Only load gradle.nvim (and nui) once it's actually needed
local loaded = false
local function load_gradle()
    if not loaded then
        loaded = true
        require("gradle").setup({
            -- Prefer the project's wrapper when there is one
            gradle_executable = vim.fn.filereadable("gradlew") == 1 and "./gradlew" or "gradle",
        })
    end
    return require("gradle")
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'java', 'kotlin', 'groovy' },
    once = true,
    callback = function() load_gradle() end,
})

wk.add({
    { "<leader>G",  group = "Gradle" },
    { "<leader>Gg", function() load_gradle().toggle_projects_view() end,   desc = "Gradle projects" },
    { "<leader>Ge", function() load_gradle().show_execution_view() end,    desc = "Gradle execute" },
    { "<leader>Gf", function() load_gradle().show_favorite_commands() end, desc = "Gradle favorites" },
    { "<leader>Gi", function() load_gradle().show_initializer_view() end,  desc = "Gradle new project" },
})