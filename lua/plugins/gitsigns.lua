
return {
  'lewis6991/gitsigns.nvim',
    -- Load gitsigns after a buffer is read from disk.
    -- This means it only activates when you open a file, not for empty scratch buffers, etc.
    event = "BufReadPost",
  -- The 'config' function runs after the plugin is successfully loaded
  config = function()
    require('gitsigns').setup {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
        untracked    = { text = '▎' },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(gs.next_hunk)
          return '<Ignore>'
        end, 'Next hunk')
        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(gs.prev_hunk)
          return '<Ignore>'
        end, 'Prev hunk')

        -- Stage / unstage
        map('n', '<leader>hs', gs.stage_hunk,        'Stage hunk')
        map('n', '<leader>hS', gs.stage_buffer,      'Stage buffer')
        map('n', '<leader>hu', gs.undo_stage_hunk,   'Undo stage hunk')
        map('n', '<leader>hU', gs.reset_buffer_index,'Unstage buffer')
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
        end, 'Stage selected lines')

        -- Reset (discard changes)
        map('n', '<leader>hr', gs.reset_hunk,   'Reset hunk')
        map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
        end, 'Reset selected lines')

        -- Inspect
        map('n', '<leader>hp', gs.preview_hunk,          'Preview hunk')
        map('n', '<leader>hb', gs.blame_line,             'Blame line')
        map('n', '<leader>hd', gs.diffthis,               'Diff against index')
        map('n', '<leader>hD', function() gs.diffthis('~') end, 'Diff against last commit')

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle inline blame')
        map('n', '<leader>tw', gs.toggle_word_diff,           'Toggle word diff')

        -- Text object: select hunk in visual/operator mode
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
      end,
    }
  end,
}
