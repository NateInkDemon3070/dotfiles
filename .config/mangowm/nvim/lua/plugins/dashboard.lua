return {
  { "nvim-mini/mini.starter", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
     ██╗██╗   ██╗ █████╗ ███╗   ██╗    ██╗   ██╗██╗███╗   ███╗
     ██║██║   ██║██╔══██╗████╗  ██║    ██║   ██║██║████╗ ████║
     ██║██║   ██║███████║██╔██╗ ██║    ██║   ██║██║██╔████╔██║
██   ██║██║   ██║██╔══██║██║╚██╗██║    ╚██╗ ██╔╝██║██║╚██╔╝██║
╚█████╔╝╚██████╔╝██║  ██║██║ ╚████║     ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
          keys = {
            { icon = " ", key = "f", desc = "Buscar archivo", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "Archivo nuevo", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Buscar texto", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Archivos recientes", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Configuración", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restaurar sesión", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Salir", action = ":qa" },
          },
        },
      },
    },
  },
}
