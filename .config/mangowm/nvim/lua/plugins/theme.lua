local colors_dir = vim.fn.stdpath("config") .. "/colors"
local matugen_colors = colors_dir .. "/matugen.lua"
local has_matugen = vim.fn.filereadable(matugen_colors) == 1

return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    init = function()
      if not has_matugen then
        return
      end

      local uv = vim.uv or vim.loop
      local handle = uv.new_fs_event()
      if not handle then
        return
      end

      local timer = uv.new_timer()
      handle:start(colors_dir, {}, function(err, filename)
        if err or filename ~= "matugen.lua" then
          return
        end
        timer:start(
          200,
          0,
          vim.schedule_wrap(function()
            if vim.g.colors_name == "matugen" then
              pcall(vim.cmd.colorscheme, "matugen")
            end
          end)
        )
      end)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = has_matugen and "matugen" or "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
    },
  },
}
