local matugen_path = vim.fn.stdpath("config") .. "/matugen.lua"

local function load_matugen()
  local ok = pcall(dofile, matugen_path)
  if not ok then
    vim.cmd.colorscheme("tokyonight")
  end
end

vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    load_matugen()
    pcall(vim.cmd, "Lazy! reload lualine.nvim")
  end,
})

load_matugen()
