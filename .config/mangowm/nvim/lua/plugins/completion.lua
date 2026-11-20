-- Disable automatic completion popup (blink.cmp).
-- The menu now only shows when you explicitly request it with <C-Space>.
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {
          show_on_keyword = false,
          show_on_trigger_character = false,
          show_on_insert = false,
          show_on_insert_on_trigger_character = false,
          show_on_backspace = false,
          show_on_backspace_in_keyword = false,
          show_on_backspace_after_accept = false,
          show_on_backspace_after_insert_enter = false,
        },
      },
    },
  },
}
