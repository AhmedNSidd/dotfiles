-- init.lua

local hotkey = require("hs.hotkey")
local window = require("hs.window")
local screen = require("hs.screen")

-- Function to get all screens sorted from left to right based on x-coordinate
function getScreensSortedLeftToRight()
	local allScreens = screen.allScreens()
	table.sort(allScreens, function(a, b)
		return a:frame().x < b:frame().x
	end)
	return allScreens
end

-- Function to move window to another screen and handle fullscreen state
function moveWindowToScreen(win, targetScreen)
	if not win or not targetScreen then
		return
	end

	local wasFS = win:isFullScreen()

	if wasFS then
		-- If fullscreen, exit and wait before moving
		win:setFullScreen(false)
		hs.timer.doAfter(0.6, function()
			win:moveToScreen(targetScreen)
			win:setFullScreen(true)
		end)
	else
		-- If not fullscreen, move immediately
		win:moveToScreen(targetScreen)
	end
end

-- Function to move window to screen on the left
function moveWindowToLeftScreen()
	local win = window.focusedWindow()
	if not win then
		return
	end

	local currentScreen = win:screen()
	local sortedScreens = getScreensSortedLeftToRight()

	-- Find the index of the current screen
	local currentIndex = 0
	for i, scr in ipairs(sortedScreens) do
		if scr:id() == currentScreen:id() then
			currentIndex = i
			break
		end
	end

	-- Move to the screen on the left if it exists
	if currentIndex > 1 then
		moveWindowToScreen(win, sortedScreens[currentIndex - 1])
	end
end

-- Function to move window to screen on the right
function moveWindowToRightScreen()
	local win = window.focusedWindow()
	if not win then
		return
	end

	local currentScreen = win:screen()
	local sortedScreens = getScreensSortedLeftToRight()

	-- Find the index of the current screen
	local currentIndex = 0
	for i, scr in ipairs(sortedScreens) do
		if scr:id() == currentScreen:id() then
			currentIndex = i
			break
		end
	end

	-- Move to the screen on the right if it exists
	if currentIndex < #sortedScreens then
		moveWindowToScreen(win, sortedScreens[currentIndex + 1])
	end
end

-- Set up hotkeys for moving to physical left and right screens
hotkey.bind({ "alt", "cmd" }, "left", moveWindowToLeftScreen)
hotkey.bind({ "alt", "cmd" }, "right", moveWindowToRightScreen)
