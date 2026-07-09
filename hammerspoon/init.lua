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

-- Auto-quit Zoom when no meeting is active (checks every 2 minutes)
--
-- Meeting detection: a live Zoom meeting spawns the "CptHost" helper process.
-- This is distinct from "caphost", which Zoom launches at app startup and keeps
-- running the whole time it is open (so caphost is NOT a meeting indicator).
-- The Zoom meeting window is not a standard AXWindow, so window enumeration
-- reports zero windows even mid-call; the process check is the reliable signal.
local zoomLog = hs.logger.new("zoomQuit", "info")

local function zoomMeetingActive()
	-- pgrep -x matches the exact process name, so "CptHost" won't match "caphost".
	local _, _, _, rc = hs.execute("pgrep -x CptHost")
	return rc == 0
end

-- Require two consecutive idle checks before quitting, so a brief gap between
-- meetings (or a reconnect) can't kill an active meeting.
local zoomIdleCount = 0
zoomQuitTimer = hs.timer.doEvery(120, function()
	-- Match by bundle ID: hs.application.find("zoom.us") matches many unrelated
	-- helper apps (e.g. "zoom.us Calendar Web Content") and may kill the wrong one.
	local zoom = hs.application.get("us.zoom.xos")
	if not zoom then
		zoomIdleCount = 0
		return
	end
	if zoomMeetingActive() then
		zoomIdleCount = 0
		return
	end
	zoomIdleCount = zoomIdleCount + 1
	zoomLog.f("no active meeting (idle check %d/2)", zoomIdleCount)
	if zoomIdleCount >= 2 then
		zoomLog.i("quitting Zoom")
		zoom:kill()
		zoomIdleCount = 0
	end
end)

-- Load the IPC module so the `hs` CLI can introspect/reload this config.
require("hs.ipc")
