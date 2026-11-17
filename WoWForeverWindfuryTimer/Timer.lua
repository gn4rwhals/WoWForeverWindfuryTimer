-- Timer: pure countdown and matching logic, no WoW API. Unit tested.
local _, ns = ...

local Timer = {}
ns.Timer = Timer

-- Seconds after a Windfury proc during which Stormstrike should not be cast.
Timer.WINDOW = 1.5

-- Seconds left in the window that started at startedAt, or 0.
function Timer.Remaining(startedAt, now)
	if not startedAt then return 0 end
	local left = startedAt + Timer.WINDOW - now
	if left <= 0 then return 0 end
	if left > Timer.WINDOW then return Timer.WINDOW end
	return left
end

-- "1.2": one decimal, rounded up so an active window never shows "0.0".
function Timer.Format(sec)
	return string.format("%.1f", math.ceil(sec * 10 - 1e-9) / 10)
end

-- True if match (a spell ID as text, or plain text) fits this spell or message.
-- Text matching is a case-insensitive substring search.
function Timer.Matches(match, text, spellId)
	if type(match) ~= "string" or match == "" then return false end
	local id = tonumber(match)
	if id then return spellId == id end
	if type(text) ~= "string" then return false end
	return text:lower():find(match:lower(), 1, true) ~= nil
end
