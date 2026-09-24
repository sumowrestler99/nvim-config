return {
    'luukvbaal/statuscol.nvim',
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        setopt = true,
        -- statuscol's default handlers (statuscol.lua:338-348) toggle a DAP
        -- breakpoint on a line-number click and reset/stage a hunk on a
        -- middle/right click of a git sign, with no confirmation. `false`
        -- disables a handler (statuscol.lua:121-130); the fold, diagnostic and
        -- DAP-sign handlers are kept.
        clickhandlers = {
          Lnum     = false,
          gitsigns = function(args)
            if args.button == 'l' then require('gitsigns').preview_hunk() end
          end,
        },
        -- override the default list of segments with:
        -- number-less fold indicator, then signs, then line number & separator
        segments = {
          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
          { text = { '%s' }, click = 'v:lua.ScSa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      }
    end,
  }
