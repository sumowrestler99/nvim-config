return {
  "nvim-lualine/lualine.nvim",
  dependencies = 'nvim-tree/nvim-web-devicons',
    -- Eagerly load Lualine.nvim.
    -- This ensures your custom statusline is present from the very beginning of Neovim startup.
    lazy = false,
    priority = 900, -- Below catppuccin (1000) so the theme is available when lualine loads.
  config = function()
    -- Use catppuccin palette so colors adapt to the active variant (mocha/macchiato/etc.)
    local palette = require("catppuccin.palettes").get_palette()
    local colors = {
      red    = palette.red,
      orange = palette.peach,
      green  = palette.green,
      white  = palette.text,
      grey   = palette.overlay1,
      black  = palette.base,
    }

    local empty = require('lualine.component'):extend()
    function empty:draw(default_highlight)
      self.status = ''
      self.applied_separator = ''
      self:apply_highlights(default_highlight)
      self:apply_section_separators()
      return self.status
    end

    -- Put proper separators and gaps between components in sections
    local function process_sections(sections)
      for name, section in pairs(sections) do
        local left = name:sub(9, 10) < 'x'
        for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
          table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = colors.white } })
        end
        for id, comp in ipairs(section) do
          if type(comp) ~= 'table' then
            comp = { comp }
            section[id] = comp
          end
          comp.separator = left and { right = '' } or { left = '' }
        end
      end
      return sections
    end

    local function search_result()
      if vim.v.hlsearch == 0 then
        return ''
      end
      local last_search = vim.fn.getreg('/')
      if not last_search or last_search == '' then
        return ''
      end
      -- Strip Vim regex metacharacters (word boundaries \<\>, nomagic \V, etc.)
      local display = last_search:gsub('\\[<>VvMm]', ''):gsub('\\%(', '('):gsub('\\%)', ')')
      local searchcount = vim.fn.searchcount { maxcount = 9999 }
      return display .. ' (' .. searchcount.current .. '/' .. searchcount.total .. ')'
    end

    local function modified()
      if vim.bo.modified then
        return '●'
      elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        return ''
      end
      return ''
    end

    require('lualine').setup {
      options = {
        theme = "catppuccin-" .. require("catppuccin").flavour,
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { "NvimTree", "Packer", "Avante", "AvanteInput" }
      },
      sections = process_sections {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          'diff',
          {
            'diagnostics',
            source = { 'nvim' },
            sections = { 'error' },
            diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
          },
          {
            'diagnostics',
            source = { 'nvim' },
            sections = { 'warn' },
            diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
          },
          { 'filename', file_status = false, path = 1 },
          { modified, color = { bg = colors.red } },
          {
            '%w',
            cond = function()
              return vim.wo.previewwindow
            end,
          },
          {
            '%r',
            cond = function()
              return vim.bo.readonly
            end,
          },
          {
            '%q',
            cond = function()
              return vim.bo.buftype == 'quickfix'
            end,
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { search_result, 'filetype' },
        lualine_z = { '%l:%c', '%p%%/%L' },
      },
      inactive_sections = {
        lualine_c = { '%f %y %m' },
        lualine_x = {},
      },
    }
  end,
}
