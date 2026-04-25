return {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
        {
            'L3MON4D3/LuaSnip',
            build = "make install_jsregexp",
        },
        'rafamadriz/friendly-snippets',
    },
    config = function()
        require('luasnip.loaders.from_vscode').lazy_load()

        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        local cmp      = require('cmp')
        local luasnip  = require('luasnip')
        local select_opts = { behavior = cmp.SelectBehavior.Select }

        local has_words_before = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local line, col = cursor[1], cursor[2]
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            sources = {
                { name = 'nvim_lsp', keyword_length = 1 },
                { name = 'luasnip',  keyword_length = 2 },
            },
            performance = {
                debounce = 300, -- ms delay before completion popup appears
                throttle = 60,
            },
            window = {
                completion = cmp.config.window.bordered({
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                }),
                documentation = cmp.config.window.bordered({
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                }),
            },
            formatting = {
                fields = { 'kind', 'abbr', 'menu' },
                format = function(entry, item)
                    local kind_icons = {
                    Text          = "󰉿",
                    Method        = "󰆧",
                    Function      = "󰊕",
                    Constructor   = "",
                    Field         = "󰜢",
                    Variable      = "󰀫",
                    Class         = "󰠱",
                    Interface     = "",
                    Module        = "",
                    Property      = "󰖷",
                    Unit          = "",
                    Value         = "󰎠",
                    Enum          = "",
                    Keyword       = "󰌋",
                    Snippet       = "󰐋",
                    Color         = "󰏘",
                    File          = "󰈙",
                    Reference     = "",
                    Folder        = "󰉋",
                    EnumMember    = "󰊻",
                    Constant      = "󰏿",
                    Struct        = "󰙅",
                    Event         = "",
                    Operator      = "󰆕",
                    TypeParameter = "󰊄",
                    }
                    local menu_icon = {
                        nvim_lsp = "[LSP]",
                        luasnip  = "[Snip]",
                        buffer   = "[Buf]",
                        path     = "[Path]",
                    }
                    item.kind = (kind_icons[item.kind] or "") .. " " .. (item.kind or "")
                    item.menu = menu_icon[entry.source.name] or ""
                    return item
                end,
            },
            mapping = {
                ['<CR>']   = cmp.mapping.confirm({ select = false }),
                ['<Up>']   = cmp.mapping.select_prev_item(select_opts),
                ['<Down>'] = cmp.mapping.select_next_item(select_opts),
                ['<C-p>']  = cmp.mapping.select_prev_item(select_opts),
                ['<C-n>']  = cmp.mapping.select_next_item(select_opts),
                ['<C-u>']  = cmp.mapping.scroll_docs(-4),
                ['<C-d>']  = cmp.mapping.scroll_docs(4),
                ['<C-e>']  = cmp.mapping.abort(),
                ['<C-y>']  = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    local col = vim.fn.col('.') - 1
                    if cmp.visible() then
                        cmp.select_next_item(select_opts)
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item(select_opts)
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            },
        })
    end,
}
