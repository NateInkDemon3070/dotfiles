-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps her
local keymap = vim.keymap

-- BORRAR LÍNEA ENTERA (Como en Nano: CTRL + K)
-- Funciona en modo Insertar (i) y modo Normal (n)
keymap.set("i", "<C-k>", "<Esc>ddi", { desc = "Borrar línea (estilo Nano)" })
keymap.set("n", "<C-k>", "dd", { desc = "Borrar línea" })

-- BUSCAR PALABRA (Como en Nano: CTRL + F)
-- Usamos Telescope (el buscador de LazyVim) porque es mil veces mejor que el básico
keymap.set("i", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buscar en archivo" })
keymap.set("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buscar en archivo" })
