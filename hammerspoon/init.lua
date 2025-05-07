-- init.lua

local hotkey = require("hs.hotkey")
local window = require("hs.window")
local screen = require("hs.screen")

-- Function to move windows to screen by name
function moveWindowToScreenByName(win, screenName)
	local screens = screen.allScreens()

	for i, scr in ipairs(screens) do
		print("Screen " .. i .. ": " .. scr:name())
		if scr:name():find(screenName) then
			local wasFS = win:isFullScreen()

			if wasFS then
				-- If fullscreen, exit and wait before moving
				win:setFullScreen(false)
				hs.timer.doAfter(0.6, function()
					win:moveToScreen(scr)
					win:setFullScreen(true)
				end)
			else
				-- If not fullscreen, move immediately
				win:moveToScreen(scr)
			end

			return
		end
	end
end

-- Set up hotkeys for specific screens by name
hotkey.bind({ "alt", "cmd" }, "left", function()
	local win = window.focusedWindow()
	moveWindowToScreenByName(win, "27QHD240")
end)

hotkey.bind({ "alt", "cmd" }, "up", function()
	local win = window.focusedWindow()
	moveWindowToScreenByName(win, "DELL P2722HE")
end)

hotkey.bind({ "alt", "cmd" }, "right", function()
	local win = window.focusedWindow()
	moveWindowToScreenByName(win, "Retina Display")
end)
