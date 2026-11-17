-- Core: add-on namespace, saved variables and the /wft slash command.
-- Every file in the TOC receives the same two values: the add-on folder name
-- and a private table (ns) shared between our files without using globals.
local addonName, ns = ...

-- Forever (like Retail 12.x) can hand add-ons "secret values". Comparing,
-- concatenating or indexing a secret throws an error, so every value read from
-- the game goes through Readable: a secret value comes back as nil.
function ns.IsSecret(v)
	return v ~= nil and issecretvalue ~= nil and issecretvalue(v) and true or false
end

function ns.Readable(v)
	if ns.IsSecret(v) then return nil end
	return v
end

function ns.Print(...)
	print("|cff33ff99WindfuryTimer|r:", ...)
end

-- Prints only while /wft debug is on.
function ns.Debug(...)
	if ns.db and ns.db.debug then ns.Print(...) end
end

-- Functions other files want run once saved variables are ready.
ns.onLoad = {}

-- Slash command handlers, added by other files: ns.commands.name = function(rest)
ns.commands = {}

ns.commands.match = function(rest)
	if rest ~= "" then ns.db.match = rest end
	ns.Print("a proc is a spell or message matching: " .. ns.db.match)
end

ns.commands.debug = function()
	ns.db.debug = not ns.db.debug
	ns.Print("debug " .. (ns.db.debug and "ON" or "OFF"))
	if ns.db.debug and ns.Detect then ns.Detect.PrintSources() end
end

SLASH_WINDFURYTIMER1 = "/wft"
SlashCmdList.WINDFURYTIMER = function(msg)
	local cmd, rest = (msg or ""):match("^(%S*)%s*(.-)$")
	local handler = ns.commands[cmd:lower()]
	if handler then
		handler(rest)
	else
		local names = {}
		for name in pairs(ns.commands) do names[#names + 1] = name end
		table.sort(names)
		ns.Print("commands: /wft " .. table.concat(names, " | /wft "))
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
	if name ~= addonName then return end
	-- SavedVariables are only loaded once our ADDON_LOADED fires.
	WindfuryTimerDB = WindfuryTimerDB or {}
	ns.db = WindfuryTimerDB
	if ns.db.locked == nil then ns.db.locked = true end
	ns.db.match = ns.db.match or "Windfury"
	for _, fn in ipairs(ns.onLoad) do fn() end
	self:UnregisterEvent("ADDON_LOADED")
end)
