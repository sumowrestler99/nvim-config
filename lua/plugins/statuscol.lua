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
          -- Signs in two segments. One 2-cell slot for DAP, diagnostics and
          -- TODO signs (highest priority wins), then a 1-cell column for
          -- gitsigns alone, so the git bar no longer disappears on lines that
          -- also carry a diagnostic or TODO. statuscol leaves namespaces that
          -- another segment claims out of the '.*' one (statuscol.lua:456-479).
          {
            sign = { name = { '.*' }, namespace = { '.*' }, maxwidth = 1, colwidth = 2, auto = true },
            click = 'v:lua.ScSa',
          },
          {
            sign = { namespace = { 'gitsigns' }, maxwidth = 1, colwidth = 1, auto = true },
            click = 'v:lua.ScSa',
          },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      }
    end,
  }
