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
        "sainnhe/gruvbox-material",
        priority = 1000,
        config = function()
            vim.o.background = "light"
            vim.o.termguicolors = true
            vim.g.gruvbox_material_background = "hard" -- "hard" | "medium" | "soft"
            vim.g.gruvbox_material_foreground = "material" -- "material" | "mix" | "original"
            vim.g.gruvbox_material_better_performance = 1
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "gruvbox-material",
                callback = function()
                    vim.api.nvim_set_hl(0, "MatchParen", { fg = "#000000", bold = true })
                    vim.api.nvim_set_hl(0, "TelescopeMatching", { bold = true, italic = false, underline = true })
                    cursor_bg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg
                    vim.api.nvim_set_hl(0, "NormalFloat", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "FloatBorder", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "Pmenu", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "VirtualTextError", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "VirtualTextWarning", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "VirtualTextHint", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "VirtualTextInfo", { bg = cursor_bg })
                    vim.api.nvim_set_hl(0, "VirtualTextOk", { bg = cursor_bg })
                end,
            })
        end,
    },
}
