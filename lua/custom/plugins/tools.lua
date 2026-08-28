return {
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            -- No icon column: icons are reserved for markdown rendering only.
            columns = {},
            keymaps = {
                ["<CR>"] = "actions.select",
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["."] = { "actions.toggle_hidden", mode = "n" },
            },
            use_default_keymaps = false,
        },
        lazy = false,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            file_types = { "markdown" },
            ignore = function(buf)
                -- Icons/markdown rendering are reserved for real `.md` files.
                -- Buffers can carry filetype=markdown without being a .md file
                -- on disk (scratch buffers, plugin output, etc.); ignore those
                -- so icons never leak.
                local name = vim.api.nvim_buf_get_name(buf)
                if not name:match("%.md$") then
                    return true
                end
                local win = vim.fn.bufwinid(buf)
                if win == -1 then
                    return false
                end
                return vim.api.nvim_win_get_config(win).relative ~= ""
            end,
            heading = {
                position = "inline",
                -- No icons: indentation encodes the heading level instead.
                -- Empty strings (not an empty table) conceal the '#' markers.
                icons = { "", "", "", "", "", "" },
                width = "full",
                -- Step each level further right so the indent shows the level.
                left_pad = { 1, 2, 3, 4, 5, 6 },
                right_pad = 1,
                sign = false,
            },
            code = {
                width = "block",
                left_pad = 2,
                right_pad = 2,
                min_width = 45,
                border = "thin",
                -- Show the language icon + name above each block.
                -- The icon comes from the icon provider (mini.icons, set up
                -- below) and falls back gracefully when no glyph exists.
                position = "left",
                language = true,
                language_icon = true,
                language_name = true,
            },
            bullet = {
                -- Indent every list type (bullet, ordered, task) by 2 columns.
                left_pad = 1,
                icons = { " ", " ", " ", " " },
            },
            checkbox = {
                checked = { icon = " " },
                unchecked = { icon = " " },
            },
            quote = { icon = "▎" },
            dash = { icon = "─" },
        },
        config = function(_, opts)
            -- Icon provider for code-block language icons (Nerd Font glyphs).
            -- render-markdown reads from mini.icons via the global `_G.MiniIcons`,
            -- which only exists once `setup()` has run. We deliberately do NOT
            -- mock nvim-web-devicons here: that would make every devicons consumer
            -- (e.g. oil) render file icons. Keeping the provider scoped to
            -- `_G.MiniIcons` limits icons to markdown rendering only.
            if not _G.MiniIcons then
                require("mini.icons").setup()
            end

            require("render-markdown").setup(opts)

            -- Pick the colorscheme to match the OS/terminal background.
            -- `background` is set by the terminal/OS integration before this
            -- file loads; the markdown palette below follows the same check.
            if vim.o.background == "dark" then
                vim.cmd.colorscheme("lackluster")
            else
                vim.cmd.colorscheme("gruvbox-material")
            end

            -- Lackluster-matched palette so markdown reads well on the muted theme.
            -- render-markdown creates its groups with `default = true`, so these
            -- overrides must run AFTER setup; the ColorScheme autocmd re-applies
            -- them if the theme is reloaded.
            local c = require("lackluster.color")
            local bg = "#101010" -- lackluster main background
            local blue = "#7aa2f7" -- real blue (c.blue is tweaked to green in styling.lua)

            local function style_markdown()
                local hl = function(group, val)
                    vim.api.nvim_set_hl(0, group, val)
                end

                -- Headings: colored icon/text per level + subtle full-width tints.
                local heads = {
                    { fg = c.green, bg = "#1c241c" },
                    { fg = c.luster, bg = "#232323" },
                    { fg = c.yellow, bg = "#21211a" },
                    { fg = c.orange, bg = "#241d18" },
                    { fg = c.gray7, bg = "#1a1a1a" },
                    { fg = c.gray6, bg = "#161616" },
                }
                for i, h in ipairs(heads) do
                    hl("RenderMarkdownH" .. i, { fg = h.fg, bold = true })
                    hl("RenderMarkdownH" .. i .. "Bg", { bg = h.bg })
                    -- Color the heading text itself (defaults to a dim gray5).
                    hl("@markup.heading." .. i .. ".markdown", { fg = h.fg, bold = true })
                end

                -- Code: raised blocks + readable inline code.
                hl("RenderMarkdownCode", { bg = "#181818" })
                hl("RenderMarkdownCodeBorder", { bg = "#1d1d1d" })
                hl("RenderMarkdownCodeInfo", { fg = c.gray6 })
                -- Inline code: white text on the strikethrough grey (c.gray6).
                hl("RenderMarkdownCodeInline", { fg = c.gray9, bg = c.gray3 })

                -- Lists, quotes, rules.
                -- RenderMarkdownBullet colors both bullet markers and ordered
                -- (numbered) list markers. Kept neutral so lists aren't green.
                hl("RenderMarkdownBullet", { fg = c.gray9 })
                hl("RenderMarkdownDash", { fg = c.gray5 })
                hl("RenderMarkdownQuote", { fg = c.gray6, italic = true })
                hl("RenderMarkdownSign", { fg = c.gray4 })

                -- Checkboxes.
                hl("RenderMarkdownChecked", { fg = c.green })
                hl("RenderMarkdownUnchecked", { fg = c.gray9 })
                hl("RenderMarkdownTodo", { fg = c.yellow })

                -- Tables. Header border matches the body rows (gray7). Header
                -- title text is captured as @markup.heading (lackluster dims it
                -- to gray5); set it to the body cell color (gray9) but bold.
                -- Real headings use @markup.heading.N.markdown (overridden
                -- above), so this only affects table titles.
                hl("RenderMarkdownTableHead", { fg = c.gray7 })
                hl("RenderMarkdownTableRow", { fg = c.gray7 })
                hl("RenderMarkdownTableFill", { fg = c.gray3 })
                hl("@markup.heading", { fg = c.gray9, bold = true })

                -- Links: blue icon + blue underlined text. RenderMarkdownLink
                -- only colors the icon; the visible label keeps its treesitter
                -- group (@markup.link.*), which lackluster dims to grey, so we
                -- override those too to get a proper underlined hyperlink.
                hl("RenderMarkdownLink", { fg = blue })
                hl("@markup.link", { fg = blue, underline = true })
                hl("@markup.link.label", { fg = blue, underline = true })
                hl("@markup.link.label.markdown_inline", { fg = blue, underline = true })
                hl("@markup.link.url", { fg = blue, underline = true })

                -- Highlights, math.
                hl("RenderMarkdownInlineHighlight", { fg = bg, bg = c.yellow })
                hl("RenderMarkdownMath", { fg = c.orange })

                -- Emphasis: lackluster sets these to dim grey (#444) with no
                -- attributes, so **bold**/*italic*/~~strike~~ just look dark.
                -- Apply the real gui attributes with a readable hierarchy.
                hl("@markup.strong", { bold = true, fg = c.luster })
                hl("@markup.italic", { italic = true, fg = c.gray9 })
                hl("@markup.strikethrough", { strikethrough = true, fg = c.gray6 })

                -- Plain prose: Normal is gray8; nudge markdown body text to
                -- gray9 (brighter) without touching global Normal. Applied only
                -- to markdown windows via winhighlight (FileType autocmd below).
                -- Inherit Normal's background so only the text color changes.
                local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
                hl("RenderMarkdownNormal", { fg = c.gray9, bg = normal_bg })

                -- Callouts / quote admonitions.
                hl("RenderMarkdownInfo", { fg = c.green })
                hl("RenderMarkdownSuccess", { fg = c.green })
                hl("RenderMarkdownHint", { fg = c.luster })
                hl("RenderMarkdownWarn", { fg = c.orange })
                hl("RenderMarkdownError", { fg = c.red })

                -- Language icons (code blocks, oil, ...): lackluster leaves the
                -- mini.icons groups at dim greys (#444/#7a7a7a). Brighten each to
                -- a lighter version of its hue so icons stay distinct and visible.
                local icon_colors = {
                    Azure = "#8ec7e0",
                    Blue = "#8fb3d9",
                    Cyan = "#8fd6cf",
                    Green = "#a3c9a3",
                    Grey = "#cccccc",
                    Orange = "#ffbf9b",
                    Purple = "#c2a8e0",
                    Red = "#e87a7a",
                    Yellow = "#d6d18a",
                }
                for name, fg in pairs(icon_colors) do
                    hl("MiniIcons" .. name, { fg = fg })
                end
            end

            -- Gruvbox Material Light palette, mirroring style_markdown() above
            -- but for `background = "light"`. The token set has no distinct
            -- orange or bright accent beyond yellow/aqua, so those roles reuse
            -- yellow and aqua respectively instead of inventing new hex values.
            local gm = {
                fg1 = "#4f3829", -- color15, darkest/most saturated text (emphasis)
                grey0 = "#a89984", -- color8
                grey1 = "#928374", -- inactive_tab_foreground
                grey2 = "#7c6f64", -- color7
                green = "#6c782e", -- color2/10
                yellow = "#b47109", -- color3/11 (also stands in for orange)
                red = "#c14a4a", -- color1/9
                blue = "#45707a", -- url_color, color4/12
                aqua = "#4c7a5d", -- color6/14 (stands in for lackluster's "luster")
                purple = "#945e80", -- color5/13
                bg0 = "#f9f5d7", -- background
                bg_green = "#dde5c2", -- mark1_background
                bg_yellow = "#f9eabf", -- selection_background / mark2_background
                bg_tan = "#f0ddc3", -- mark3_background
                bg_neutral = "#f2e5bc", -- inactive_tab_background
                bg_tab = "#f3eac7", -- tab_bar_background
            }

            local function style_markdown_light()
                local hl = function(group, val)
                    vim.api.nvim_set_hl(0, group, val)
                end

                -- Headings: colored icon/text per level + subtle full-width tints.
                local heads = {
                    { fg = gm.green, bg = gm.bg_green },
                    { fg = gm.aqua, bg = gm.bg_neutral },
                    { fg = gm.yellow, bg = gm.bg_yellow },
                    { fg = gm.yellow, bg = gm.bg_tan },
                    { fg = gm.grey2, bg = gm.bg_tab },
                    { fg = gm.grey0, bg = gm.bg0 },
                }
                for i, h in ipairs(heads) do
                    hl("RenderMarkdownH" .. i, { fg = h.fg, bold = true })
                    hl("RenderMarkdownH" .. i .. "Bg", { bg = h.bg })
                    hl("@markup.heading." .. i .. ".markdown", { fg = h.fg, bold = true })
                end

                -- Code: raised blocks + readable inline code.
                hl("RenderMarkdownCode", { bg = gm.bg_tab })
                hl("RenderMarkdownCodeBorder", { bg = gm.bg_tan })
                hl("RenderMarkdownCodeInfo", { fg = gm.grey0 })
                hl("RenderMarkdownCodeInline", { fg = gm.fg1, bg = gm.bg_neutral })

                -- Lists, quotes, rules.
                hl("RenderMarkdownBullet", { fg = gm.fg1 })
                hl("RenderMarkdownDash", { fg = gm.grey1 })
                hl("RenderMarkdownQuote", { fg = gm.grey0, italic = true })
                hl("RenderMarkdownSign", { fg = gm.grey1 })

                -- Checkboxes.
                hl("RenderMarkdownChecked", { fg = gm.green })
                hl("RenderMarkdownUnchecked", { fg = gm.fg1 })
                hl("RenderMarkdownTodo", { fg = gm.yellow })

                -- Tables.
                hl("RenderMarkdownTableHead", { fg = gm.grey2 })
                hl("RenderMarkdownTableRow", { fg = gm.grey2 })
                hl("RenderMarkdownTableFill", { fg = gm.grey0 })
                hl("@markup.heading", { fg = gm.fg1, bold = true })

                -- Links.
                hl("RenderMarkdownLink", { fg = gm.blue })
                hl("@markup.link", { fg = gm.blue, underline = true })
                hl("@markup.link.label", { fg = gm.blue, underline = true })
                hl("@markup.link.label.markdown_inline", { fg = gm.blue, underline = true })
                hl("@markup.link.url", { fg = gm.blue, underline = true })

                -- Highlights, math.
                hl("RenderMarkdownInlineHighlight", { fg = gm.bg0, bg = gm.yellow })
                hl("RenderMarkdownMath", { fg = gm.yellow })

                -- Emphasis.
                hl("@markup.strong", { bold = true, fg = gm.aqua })
                hl("@markup.italic", { italic = true, fg = gm.fg1 })
                hl("@markup.strikethrough", { strikethrough = true, fg = gm.grey0 })

                -- Plain prose.
                local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
                hl("RenderMarkdownNormal", { fg = gm.fg1, bg = normal_bg })

                -- Callouts / quote admonitions.
                hl("RenderMarkdownInfo", { fg = gm.green })
                hl("RenderMarkdownSuccess", { fg = gm.green })
                hl("RenderMarkdownHint", { fg = gm.aqua })
                hl("RenderMarkdownWarn", { fg = gm.yellow })
                hl("RenderMarkdownError", { fg = gm.red })

                -- Language icons (code blocks, oil, ...): saturated hues read
                -- fine directly against the light background, unlike the
                -- lightened variants dark mode needs.
                local icon_colors = {
                    Azure = gm.blue,
                    Blue = gm.blue,
                    Cyan = gm.aqua,
                    Green = gm.green,
                    Grey = gm.grey2,
                    Orange = gm.yellow,
                    Purple = gm.purple,
                    Red = gm.red,
                    Yellow = gm.yellow,
                }
                for name, fg in pairs(icon_colors) do
                    hl("MiniIcons" .. name, { fg = fg })
                end
            end

            local function style_markdown_for_background()
                if vim.o.background == "dark" then
                    style_markdown()
                else
                    style_markdown_light()
                end
            end

            style_markdown_for_background()
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = style_markdown_for_background,
                desc = "Re-apply render-markdown highlights for the active background",
            })

            -- Scope the plain-prose color to markdown windows only.
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    -- Skip floating windows (LSP hover, diagnostics, completion
                    -- docs). They set filetype=markdown too, but should keep the
                    -- uniform NormalFloat background instead of
                    -- RenderMarkdownNormal's darker editor bg, which produced a
                    -- two-tone hover look.
                    if vim.api.nvim_win_get_config(0).relative ~= "" then
                        return
                    end
                    vim.wo.winhighlight = "Normal:RenderMarkdownNormal"
                end,
                desc = "Brighten plain markdown prose to gray9",
            })
        end,
    },
    {
        "chomosuke/typst-preview.nvim",
        lazy = false,
        version = "1.*",
        opts = {
            open_cmd = "open -a Safari %s",
        },
    },
}
