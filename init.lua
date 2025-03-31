vim.o.number = true
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.textwidth = 80
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.backup = false

vim.o.shellcmdflag = '-c'
vim.o.shellxquote = ''

vim.o.foldlevel = 99
vim.o.foldtext = ""
vim.o.foldlevelstart = 99

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set("n", "<esc>", [[:nohl<CR>]])
vim.keymap.set("n", "<leader>qq", [[:q<CR>]])
vim.keymap.set("n", "<leader>ss", [[:w<CR>]])
vim.keymap.set("n", "<leader>so", [[:so<CR>]])
vim.keymap.set("n", "<leader>cd", [[:cd %:p:h<CR>]], { desc = "Changes to current file's dir" })

vim.keymap.set({ "v" }, "y", [[y'>]])
vim.keymap.set('t', '<esc>', '<C-\\><C-n>')

vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv', { noremap = true })

vim.keymap.set({ "n", "v" }, "<c-a>", "_")
vim.keymap.set({ "n", "v" }, "<c-e>", "$")
vim.keymap.set({ "i" }, "<c-a>", "<c-o>_")
vim.keymap.set({ "i" }, "<c-e>", "<c-o>$")
vim.keymap.set({ "i" }, "<c-y>", "<c-o>p")
--- Autoread
vim.o.autoread = true -- Only works for file changes detected outside of vim
local auto_reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = auto_reload_group,
  pattern = "*",
  callback = function()
    vim.cmd("silent! checktime")
  end
})

--- Execute
local exec_lua = vim.api.nvim_replace_termcodes(':lua<CR>', true, false, true)
vim.keymap.set({ "v" }, "<leader>xe", function() vim.api.nvim_feedkeys(exec_lua, 't', false) end)

--- Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local snacks = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    indent = { enabled = true },
    scroll = { enabled = true },
    scratch = { enabled = true },
    input = {
      enabled = true,
      win = {
        relative = "editor",
        row = math.floor(vim.api.nvim_win_get_height(0) / 2),
        col = math.floor(vim.api.nvim_win_get_width(0) / 2),
      },
    },
    statuscolumn = { enabled = true },
    picker = {
      actions = {
        cust_enter = function(picker, item)
          local score = item["score"] or 0
          if score == 0 then
            local hist = picker['history'] or {}
            local input = hist[#hist]['pattern'] or ""
            local user_cmd = input
            local cmd = '<esc><esc>:' .. user_cmd .. '<cr>'
            local exec = vim.api.nvim_replace_termcodes(cmd, true, false, true)
            vim.api.nvim_feedkeys(exec, 't', false)
          else
            Snacks.picker.actions.cmd(picker, item)
          end
        end,
        insert_to_search = function(picker, item)
          local selected = item["cmd"] or ""
          local score = item["score"] or 0
          if score > 0 then
            local cmd = '<esc>i' .. selected
            local exec = vim.api.nvim_replace_termcodes(cmd, true, false, true)
            vim.api.nvim_feedkeys(exec, 't', false)
          else
            Snacks.picker.actions.cmd(picker, item)
          end
        end,
      },
      ui_select = true,
      layout = {
        preview = "main",
        preset = "ivy"
      },
      sources = {
        command_history = {
          finder = "vim_history",
          name = "cmd",
          format = "text",
          layout = {
            preview = false,
            preset = "ivy",
          },
          main = { current = true },
          win = {
            input = {
              keys = {
                ["<cr>"] = { "cust_enter", mode = { "n", "i" } },
                ["<c-y>"] = { "insert_to_search", mode = { "n", "i" } },
              },
            }
          },
        },
      },
    },
  },

  keys = {
    --- Scratch
    { "<leader>.",  function() Snacks.scratch() end,                    desc = "Toggle Scratch Buffer" },
    { "<leader>fS", function() Snacks.scratch.select() end,             desc = "Select Scratch Buffer" },

    --- Terminal
    { "tt",         function() Snacks.terminal() end,                   desc = "Toggle Terminal" },
    --- Find
    { "<leader>fh", function() Snacks.picker.help() end,                desc = "Help Pages" },
    { "<leader>ff", function() Snacks.picker.files() end,               desc = "Find Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end,             desc = "Buffers" },
    --- Grep
    { "<leader>fg", function() Snacks.picker.grep() end,                desc = "Grep" },
    { "<leader>fl", function() Snacks.picker.lines() end,               desc = "Buffer Lines" },
    { "<leader>fL", function() Snacks.picker.grep_word() end,           desc = "Visual selection or word", mode = { "n", "x" } },
    --- Search
    { "<leader>fp", function() Snacks.picker.registers() end,           desc = "Registers" },
    { "<leader>fk", function() Snacks.picker.keymaps() end,             desc = "Keymaps" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end,         desc = "Diagnostics" },
    { "<leader>;",  function() Snacks.picker.command_history() end,     desc = "Command History" },
    { "<leader>fm", function() Snacks.picker.marks() end,               desc = "Marks" },
    { "<leader>fj", function() Snacks.picker.jumps() end,               desc = "Jumps" },
    { '<leader>fr', function() Snacks.picker.registers() end,           desc = "Registers" },
    { "<leader>fC", function() Snacks.picker.colorschemes() end,        desc = "Colorschemes" },
    --- LSP
    { "<leader>fo", function() Snacks.picker.lsp_symbols() end,         desc = "LSP Symbols" },
    { "gd",         function() Snacks.picker.lsp_definitions() end,     desc = "Goto Definition" },
    { "gr",         function() Snacks.picker.lsp_references() end,      nowait = true,                     desc = "References" },
    { "gi",         function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  }
}

local oil = {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  config = function()
    require("oil").setup({
      -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
      -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
      default_file_explorer = true,
      columns = {
        "icon",
        -- "permissions",
        "size",
        "mtime"
      },
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
      delete_to_trash = false,
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = false,
      -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
      -- (:help prompt_save_on_select_new_entry)
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,
      lsp_file_methods = {
        -- Enable or disable LSP file operations
        enabled = true,
        -- Time to wait for LSP file operations to complete before skipping
        timeout_ms = 1000,
        -- Set to true to autosave buffers that are updated with LSP willRenameFiles
        -- Set to "unmodified" to only save unmodified buffers
        autosave_changes = "unmodified",
      },
      constrain_cursor = "editable",
      watch_for_changes = true,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        -- ["<C-c>"] = { "actions.close", mode = "n" },
        ['<C-c>'] = {
          desc = 'Copy filepath to system clipboard',
          callback = function()
            require('oil.actions').copy_entry_path.callback()
            vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
          end,
          mode = "n"
        },
        ["<C-l>"] = "actions.refresh",
        ["<BS>"] = { "actions.parent", mode = "n" },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      -- Set to false to disable all of the above keymaps
      use_default_keymaps = true,
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          local m = name:match("^%.")
          return m ~= nil
        end,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return false
        end,
        -- Sort file names with numbers in a more intuitive order for humans.
        -- Can be "fast", true, or false. "fast" will turn it off for large directories.
        natural_order = "fast",
        -- Sort file and directory names case insensitive
        case_insensitive = false,
        sort = {
          -- sort order can be "asc" or "desc"
          -- see :help oil-columns to see which columns are sortable
          { "type", "asc" },
          { "name", "asc" },
        },
      },
    })
    vim.keymap.set("n", "<leader>er", [[:Oil<CR>]])
  end
}

local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  build = [[:TSUpdate]],
  opts = {
    ensure_installed = {
      "bash",
      "diff",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "vim",
      "vimdoc",
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "ruby" },
    },
    indent = { enable = false, disable = { "ruby" } },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
}

local conform = {
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      ["*"] = { "codespell" },
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
  }
}

local undotree = {
  "mbbill/undotree",
  config = function()
    vim.g.undotree_DiffCommand = "FC"
    vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle)
  end,
}

local mini = {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.ai").setup()
    require("mini.surround").setup({
      mappings = {
        add = 'za',            -- Add surrounding in Normal and Visual modes
        delete = 'zd',         -- Delete surrounding
        find = 'zf',           -- Find surrounding (to the right)
        find_left = 'zF',      -- Find surrounding (to the left)
        highlight = 'zh',      -- Highlight surrounding
        replace = 'zr',        -- Replace surrounding
        update_n_lines = 'zn', -- Update `n_lines`
        suffix_last = 'l',     -- Suffix to search with "prev" method
        suffix_next = 'n',     -- Suffix to search with "next" method
      },
    })
    require("mini.bracketed").setup()
    require("mini.jump").setup()
    require("mini.pairs").setup()
    require("mini.align").setup()
  end,
}

local autotags = {
  'windwp/nvim-ts-autotag',
  config = function()
    require('nvim-ts-autotag').setup({
      opts = {
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
      },
    })
  end
}

local gitsigns = {
  "lewis6991/gitsigns.nvim",
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      -- Navigation
      map('n', ']h', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']h', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end)

      map('n', '[h', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[h', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end)

      -- Actions
      map('n', 'tb', gitsigns.toggle_current_line_blame)
      map('n', 'td', gitsigns.toggle_deleted)
      map('n', 'tr', gitsigns.reset_hunk)

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      map({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>')
    end
  }
}

local neogit = {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",  -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    -- Only one of these is needed.
    -- "nvim-telescope/telescope.nvim", -- optional
    -- "ibhagwan/fzf-lua",
    -- "echasnovski/mini.pick",
  },
  opts = {},
  config = function()
    local neogit = require("neogit")
    neogit.setup {
      process_spinner = false,
      integrations = { diffview = true }, -- adds integration with diffview.nvim
      mappings = {
        commit_editor = {
          ["q"] = "Close",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["<m-p>"] = "PrevMessage",
          ["<m-n>"] = "NextMessage",
          ["<m-r>"] = "ResetMessage",
        },
        commit_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        rebase_editor = {
          ["p"] = "Pick",
          ["r"] = "Reword",
          ["e"] = "Edit",
          ["s"] = "Squash",
          ["f"] = "Fixup",
          ["x"] = "Execute",
          ["d"] = "Drop",
          ["b"] = "Break",
          ["q"] = "Close",
          ["<cr>"] = "OpenCommit",
          ["gk"] = "MoveUp",
          ["gj"] = "MoveDown",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["[c"] = "OpenOrScrollUp",
          ["]c"] = "OpenOrScrollDown",
        },
        rebase_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        finder = {
          ["<cr>"] = "Select",
          ["<c-c>"] = "Close",
          ["<esc>"] = "Close",
          ["<c-n>"] = "Next",
          ["<c-p>"] = "Previous",
          ["<down>"] = "Next",
          ["<up>"] = "Previous",
          ["<tab>"] = "InsertCompletion",
          ["<space>"] = "MultiselectToggleNext",
          ["<s-space>"] = "MultiselectTogglePrevious",
          ["<c-j>"] = "NOP",
          ["<ScrollWheelDown>"] = "ScrollWheelDown",
          ["<ScrollWheelUp>"] = "ScrollWheelUp",
          ["<ScrollWheelLeft>"] = "NOP",
          ["<ScrollWheelRight>"] = "NOP",
          ["<LeftMouse>"] = "MouseClick",
          ["<2-LeftMouse>"] = "NOP",
        },
        -- Setting any of these to `false` will disable the mapping.
        popup = {
          ["?"] = "HelpPopup",
          ["A"] = "CherryPickPopup",
          ["d"] = "DiffPopup",
          ["M"] = false,
          ["E"] = "RemotePopup",
          ["P"] = "PushPopup",
          ["X"] = "ResetPopup",
          ["Z"] = "StashPopup",
          ["i"] = "IgnorePopup",
          ["t"] = "TagPopup",
          ["b"] = "BranchPopup",
          ["B"] = "BisectPopup",
          ["w"] = "WorktreePopup",
          ["c"] = "CommitPopup",
          ["f"] = "FetchPopup",
          ["l"] = "LogPopup",
          ["m"] = false,
          ["e"] = "MergePopup",
          ["p"] = "PullPopup",
          ["r"] = "RebasePopup",
          ["v"] = "RevertPopup",
        },
        status = {
          ["j"] = "MoveDown",
          ["k"] = "MoveUp",
          ["o"] = "OpenTree",
          ["q"] = "Close",
          ["I"] = "InitRepo",
          ["1"] = "Depth1",
          ["2"] = "Depth2",
          ["3"] = "Depth3",
          ["4"] = "Depth4",
          ["Q"] = "Command",
          ["<tab>"] = "Toggle",
          ["x"] = "Discard",
          ["s"] = "Stage",
          ["S"] = "StageUnstaged",
          ["<c-s>"] = "StageAll",
          ["u"] = "Unstage",
          ["K"] = "Untrack",
          ["U"] = "UnstageStaged",
          ["y"] = "ShowRefs",
          ["$"] = "CommandHistory",
          ["Y"] = "YankSelected",
          ["<c-r>"] = "RefreshBuffer",
          ["<cr>"] = "GoToFile",
          ["<s-cr>"] = "PeekFile",
          ["<c-v>"] = "VSplitOpen",
          ["<c-x>"] = "SplitOpen",
          ["<c-t>"] = "TabOpen",
          ["{"] = "GoToPreviousHunkHeader",
          ["}"] = "GoToNextHunkHeader",
          ["[c"] = "OpenOrScrollUp",
          ["]c"] = "OpenOrScrollDown",
          ["<c-k>"] = "PeekUp",
          ["<c-j>"] = "PeekDown",
        },
      },

    }
    -- Don't use current buffer's working directory since that doesn't play nice with Oil
    -- vim.keymap.set("n", "<leader>gg", [[:Neogit cwd=%:p:h<CR>]])
    vim.keymap.set("n", "<leader>gg", [[:Neogit<CR>]])
  end

}

local quicker = {
  'stevearc/quicker.nvim',
  opts = {},
  config = function()
    vim.keymap.set("n", "<leader>qf", function()
      require("quicker").toggle()
    end, {
      desc = "Toggle quickfix",
    })
    vim.keymap.set("n", "<leader>lf", function()
      require("quicker").toggle({ loclist = true })
    end, {
      desc = "Toggle loclist",
    })

    require("quicker").setup({
      keys = {
        {
          "<Tab>",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<S-Tab>",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
        {
          "gr",
          function()
            require("quicker").refresh()
          end,
          desc = "Collapse quickfix context",
        },
      },
    })
  end
}

local nvim_lspconfig = {
  "neovim/nvim-lspconfig",
  dependencies = {
    'saghen/blink.cmp',
  },
  config = function()
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "gh", vim.diagnostic.open_float)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

    local servers = {
      clangd = {},
      -- gopls = {},
      -- pyright = {},
      pylsp = {},
      -- rust_analyzer = {},
      -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      lua_ls = {},
      denols = {
        root_dir = require('lspconfig').util.root_pattern("deno.json", "deno.jsonc"),
      },
      zls = {},
      -- ts_ls = {
      --   root_dir = require('lspconfig').util.root_pattern("package.json"),
      --   cmd = { "bun", "run", "node_modules/typescript-language-server/lib/cli.mjs", "--stdio" },
      -- },
      svelte = {
        cmd = { "bun", "run", "node_modules/svelte-language-server/bin/server.js", "--stdio" }
      }
    }

    for server_name, config in pairs(servers) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities or {})
      require("lspconfig")[server_name].setup(config)
    end
  end,
}

local lazydev = {
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}

local blink = {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    -- ... Other dependencies
  },
  version = '1.*',
  opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = {
      preset = 'enter',
      -- cmdline = {
      --   preset = 'enter',
      -- }
    },
    cmdline = {
      enabled = true,
      keymap = { preset = 'enter' },
      completion = {
        menu = { auto_show = true },
      }
    },
    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      -- use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },
    completion = { documentation = { auto_show = true } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}

local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    theme = 'gruvbox-material',
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
    },
  }

}

local autosession = {
  'rmagatti/auto-session',
  lazy = false,
  keys = {
    -- Will use Telescope if installed or a vim.ui.select picker otherwise
    { '<leader>fs', '<cmd>SessionSearch<CR>', desc = 'Session search' },
  },
  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    -- log_level = 'debug',
    enabled = true,                                        -- Enables/disables auto creating, saving and restoring
    root_dir = vim.fn.stdpath "data" .. "/sessions/",      -- Root dir where sessions will be stored
    auto_save = true,                                      -- Enables/disables auto saving session on exit
    auto_restore = true,                                   -- Enables/disables auto restoring session on start
    auto_create = true,                                    -- Enables/disables auto creating new session files. Can take a function that should return true/false if a new session file should be created or not
    allowed_dirs = { '~/projects/*', '~/termux-config/' }, -- Allow session restore/create in certain directories
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    auto_restore_last_session = true,                      -- On startup, loads the last saved session if session for cwd does not exist
    use_git_branch = true,                                 -- Include git branch name in session name
    lazy_support = true,                                   -- Automatically detect if Lazy.nvim is being used and wait until Lazy is done to make sure session is restored correctly. Does nothing if Lazy isn't being used. Can be disabled if a problem is suspected or for debugging
    bypass_save_filetypes = nil,                           -- List of filetypes to bypass auto save when the only buffer open is one of the file types listed, useful to ignore dashboards
    close_unsupported_windows = true,                      -- Close windows that aren't backed by normal file before autosaving a session
    args_allow_single_directory = true,                    -- Follow normal sesion save/load logic if launched with a single directory as the only argument
    args_allow_files_auto_save = false,                    -- Allow saving a session even when launched with a file argument (or multiple files/dirs). It does not load any existing session first. While you can just set this to true, you probably want to set it to a function that decides when to save a session when launched with file args. See documentation for more detail
    continue_restore_on_error = true,                      -- Keep loading the session even if there's an error
    show_auto_restore_notif = false,                       -- Whether to show a notification when auto-restoring
    cwd_change_handling = false,                           -- Follow cwd changes, saving a session before change and restoring after
    lsp_stop_on_restore = false,                           -- Should language servers be stopped when restoring a session. Can also be a function that will be called if set. Not called on autorestore from startup
    log_level = "error",                                   -- Sets the log level of the plugin (debug, info, warn, error).

    session_lens = {
      load_on_setup = false, -- Initialize on startup (requires Telescope)
      theme_conf = {         -- Pass through for Telescope theme options
        -- layout_config = { -- As one example, can change width/height of picker
        --   width = 0.8,    -- percent of window
        --   height = 0.5,
        -- },
      },
      previewer = false, -- File preview for session picker

      mappings = {
        -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
        delete_session = { "i", "<C-D>" },
        alternate_session = { "i", "<C-S>" },
        copy_session = { "i", "<C-Y>" },
      },

      session_control = {
        control_dir = vim.fn.stdpath "data" .. "/auto_session/", -- Auto session control dir, for control files, like alternating between two sessions with session-lens
        control_filename = "session_control.json",               -- File name of the session control file
      },
    },
    post_cwd_changed_cmds = {
      function()
        require("lualine").refresh() -- example refreshing the lualine status line _after_ the cwd changes
      end
    }
  },

}

local compile_mode = {
  "ej-shafran/compile-mode.nvim",
  -- you can just use the latest version:
  branch = "latest",
  -- or the most up-to-date updates:
  -- branch = "nightly",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- if you want to enable coloring of ANSI escape codes in
    -- compilation output, add:
    { "m00qek/baleia.nvim", tag = "v1.3.0" },
  },
  config = function()
    ---@type CompileModeOpts
    vim.g.compile_mode = {
      -- to add ANSI escape code support, add:
      baleia_setup = true,
    }

    vim.keymap.set("n", "rr", function()
      vim.cmd([[botright Compile]])
    end)
    vim.keymap.set("n", "rc", function()
      vim.cmd([[botright Recompile]])
    end)
  end
}

local scan = {
  "ljimmy9/open-sesame.nvim",
  -- dir = "~/projects/open-sesame.nvim/",
  config = function()
    local open_sesame = require('open-sesame')

    open_sesame.setup({})
    vim.keymap.set({ "n", "v" }, "<leader>gd", open_sesame.selection_to_path, { noremap = true })
  end
}

local gp = {
  "robitx/gp.nvim",
  config = function()
    local conf = {
      -- For customization, refer to Install > Configuration in the Documentation/Readme
      providers = {
        openai = {
          disable = true,
          endpoint = "https://api.openai.com/v1/chat/completions",
          -- secret = os.getenv("OPENAI_API_KEY"),
        },
        ollama = {
          -- endpoint = "http://localhost:11434/v1/chat/completions",
          endpoint = os.getenv("OLLAMA_ENDPOINT")
        },
      },
      agents = {
        {
          name = "ChatOllamaLlama3.1-8B",
          disable = true,
        },
        {
          name = "qwen2.5-coder:14b",
          chat = true,
          command = true,
          provider = "ollama",
          model = { model = "qwen2.5-coder:14b" },
          system_prompt = "I am an AI meticulously crafted to provide programming guidance and code assistance. "
              .. "To best serve you as a computer programmer, please provide detailed inquiries and code snippets when necessary, "
              .. "and expect precise, technical responses tailored to your development needs.\n",
        },
        {
          name = "deepseek-coder:6.7b",
          chat = true,
          command = true,
          provider = "ollama",
          model = { model = "deepseek-coder:6.7b" },
          system_prompt = "I am an AI meticulously crafted to provide programming guidance and code assistance. "
              .. "To best serve you as a computer programmer, please provide detailed inquiries and code snippets when necessary, "
              .. "and expect precise, technical responses tailored to your development needs.\n",
        },
      }
    }
    require("gp").setup(conf)

    -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    local function keymapOptions(desc)
      return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
      }
    end

    vim.keymap.set({ "n" }, "<leader>ac", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
    vim.keymap.set({ "n" }, "<leader>at", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))

    -- Doesnt really work?
    vim.keymap.set({ "n" }, "<leader>af", "<cmd>GpChatFinder<cr>", keymapOptions("Toggle Chat"))

    vim.keymap.set({ "n" }, "<leader>as", "<cmd>GpStop<cr>", keymapOptions("Stop"))
    vim.keymap.set({ "n" }, "<leader>an", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

    vim.keymap.set({ "n", "v" }, "<leader>ae", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
    vim.keymap.set("v", "<leader>aa", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
  end
}

--- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    {
      gp,
      scan,
      compile_mode,
      autosession,
      gitsigns,
      lualine,
      blink,
      lazydev,
      nvim_lspconfig,
      quicker,
      neogit,
      autotags,
      mini,
      snacks,
      oil,
      treesitter,
      conform,
      undotree
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = false },
})

vim.cmd([[colorscheme slate]])
