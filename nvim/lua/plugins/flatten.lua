-- flatten.nvim — when something inside a :terminal (e.g. `git commit`) tries to
-- launch nvim, open that file as a buffer in THIS (outer) nvim instead of
-- spawning a nested instance. Removing the nesting means Esc reaches the
-- commit buffer normally, and our terminal-mode <C-[> escape-to-outer binding
-- (keymaps.lua) stays unambiguous because no nested nvim collapses C-[ onto Esc.
return {
	"willothy/flatten.nvim",
	-- Must initialize at startup so the host server + guest detection are ready
	-- before any terminal is opened.
	lazy = false,
	priority = 1001,
	opts = {
		window = {
			-- Open the forwarded file in the previous (non-terminal) window
			-- rather than inside the BetterTerm split.
			open = "alternate",
		},
		-- Make the terminal's git process wait until we finish editing.
		-- (These are flatten's defaults, listed explicitly for clarity.)
		block_for = {
			gitcommit = true,
			gitrebase = true,
		},
	},
}
