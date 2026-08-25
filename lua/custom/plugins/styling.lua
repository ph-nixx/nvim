return {
    {
        "slugbyte/lackluster.nvim",
        priority = 1000,
        init = function()
            local lackluster = require("lackluster")
            local lackluster_color = require("lackluster.color")
            lackluster.setup({
                tweak_color = {
                    lack = lackluster_color.green,
                    blue = lackluster_color.green,
                },
                tweak_highlight = {
                    ["@comment"] = { overwrite = false, italic = true },
                    -- Dark auto complete
                    Pmenu = { overwrite = true, bg = "NONE" },
                    TelescopeMatching = { overwrite = true, bold = true, italic = false, underline = true },
                    DiagnosticVirtualTextWarn = { overwrite = true, fg = "#FFAA88" },
                    MatchParen = { overwrite = true, fg = "#ffffff", bold = true },
                },
            })
        end,
    },
    {
        "everviolet/nvim",
        name = "evergarden",
        priority = 1000,
        opts = {
            theme = {
                variant = "summer",
                accent = "green",
            },
            overrides = {
                Function = { fg = "#000000" },
                ["@function"] = { fg = "#000000" },
                ["@function.call"] = { fg = "#000000" },
                ["@function.method.call"] = { fg = "#000000" },
                ["@function.builtin"] = { fg = "#000000" },
                ["@module"] = { fg = "#000000" },
                ["@operator"] = { fg = "#AC5354" },
                ["@keyword.operator"] = { fg = "#AC5354" },
                ["@annotation"] = { link = "@keyword" },
                ["@type"] = { fg = "#b7945c" },
                ["@string"] = { fg = "#647a4d" },
                ["@string.special"] = { fg = "#647a4d" },
                MsgArea = { fg = "#455355", bg = "NONE" },
                TelescopeNormal = { link = "Normal" },
                TelescopeBorder = { fg = "#ACB5A4", bg = "#F5EFE6" },
                TelescopeMatching = { style = { "bold", "underline" } },
                TelescopePromptNormal = { fg = "#000000" },
                Cursor = { bg = "#000000" },
                MatchParen = { fg = "#000000", style = { "bold" } },
                BlinkCmpMenuBorder = { fg = "#000000", bg = "#EDE8DD" },
            },
            style = {
                keyword = {},
                types = {},
            },
            editor = {
                transparent_background = false,
                sign = { color = "none" },
                float = {
                    color = "surface0",
                    solid_border = false,
                },
                completion = {
                    color = "surface0",
                },
            },
        },
    },
}
