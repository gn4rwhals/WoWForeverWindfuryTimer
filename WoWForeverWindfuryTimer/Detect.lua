-- Detect: starts the timer when Windfury procs. Forever may block the combat
-- log for add-ons, so several sources are tried. Each is registered in a pcall:
-- an event the client refuses is skipped. /wft debug shows which sources are
-- active and which one saw a proc.
local _, ns = ...
local R, Timer = ns.Readable, ns.Timer

local Detect = {}
ns.Detect = Detect

local active, blocked = {}, {}

local frame = CreateFrame("Frame")

local function listen(event, unit)
	local ok
	if unit then
		ok = pcall(frame.RegisterUnitEvent, frame, event, unit)
	else
		ok = pcall(frame.RegisterEvent, frame, event)
	end
	table.insert(ok and active or blocked, event)
end

function Detect.PrintSources()
	ns.Print("listening: " .. (#active > 0 and table.concat(active, ", ") or "none"))
	if #blocked > 0 then ns.Print("blocked: " .. table.concat(blocked, ", ")) end
end

local function proc(source, name, spellId)
	ns.Display.Start()
	ns.Debug("proc via " .. source .. ":", name or "?", spellId or "")
end

local function spellName(id)
	if C_Spell and C_Spell.GetSpellName then
		local ok, name = pcall(C_Spell.GetSpellName, id)
		return ok and R(name) or nil
	elseif GetSpellInfo then
		local ok, name = pcall(GetSpellInfo, id)
		return ok and R(name) or nil
	end
end

local CLEU_SUBEVENTS = { SPELL_DAMAGE = true, SPELL_MISSED = true, SPELL_EXTRA_ATTACKS = true }

local function onCombatLog()
	local ok, _, sub, _, src, _, _, _, _, _, _, _, spellId, name = pcall(CombatLogGetCurrentEventInfo)
	if not ok then return end
	sub, src, spellId, name = R(sub), R(src), R(spellId), R(name)
	if not CLEU_SUBEVENTS[sub] or src == nil or src ~= R(UnitGUID("player")) then return end
	if Timer.Matches(ns.db.match, name, spellId) then proc("combat log " .. sub, name, spellId) end
end

frame:SetScript("OnEvent", function(_, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		onCombatLog()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local spellId = R(select(3, ...))
		local name = spellId and spellName(spellId)
		ns.Debug("cast", name or "?", spellId or "?")
		if Timer.Matches(ns.db.match, name, spellId) then proc("spellcast", name, spellId) end
	else -- legacy combat chat events
		local msg = R((...))
		if Timer.Matches(ns.db.match, msg) then proc(event, msg) end
	end
end)

table.insert(ns.onLoad, function()
	listen("COMBAT_LOG_EVENT_UNFILTERED")
	listen("UNIT_SPELLCAST_SUCCEEDED", "player")
	listen("CHAT_MSG_SPELL_SELF_DAMAGE")
	listen("CHAT_MSG_COMBAT_SELF_HITS")
	listen("CHAT_MSG_COMBAT_SELF_MISSES")
	if ns.db.debug then Detect.PrintSources() end
end)
