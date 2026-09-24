return {
    'tpope/vim-fugitive',
    -- Exact names: lazy.nvim creates one stub per entry. The file commands
    -- are capitalised since fugitive 3.x (plugin/fugitive.vim:598-630); the
    -- old Gmove/Gdelete/Gremove/Gbrowse spellings are only error stubs.
    cmd = {
        "G", "Git", "Gedit", "Gsplit", "Gvsplit", "Gtabedit", "Gpedit", "Gdrop",
        "Gread", "Gwrite", "Gwq", "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit",
        "Ggrep", "Glgrep", "Gclog", "Gllog", "GcLog", "GlLog", "Gcd", "Glcd",
        "GMove", "GRename", "GDelete", "GRemove", "GUnlink", "GBrowse",
    },
}

