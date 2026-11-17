-- Display: a movable number that counts down the Windfury window.
local _, ns = ...
local Timer = ns.Timer

local Display = {}
ns.Display = Display

local startedAt -- GetTime() of the last proc, nil when idle

local frame = CreateFrame("Frame", "WindfuryTimerFrame", UIParent)
frame:SetSize(90, 44)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:Hide()

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.5)

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\FRIZQT__.TTF", 32, "OUTLINE")
text:SetPoint("CENTER")
text:SetTextColor(1, 0.2, 0.2)

-- Idle look: hidden when locked, a placeholder to drag when unlocked.
local function idle()
	startedAt = nil
	frame:SetScript("OnUpdate", nil)
	if ns.db.locked then
		frame:Hide()
	else
		text:SetText(Timer.Format(Timer.WINDOW))
		frame:Show()
	end
end

local function onUpdate()
	local left = Timer.Remaining(startedAt, GetTime())
	if left > 0 then
		text:SetText(Timer.Format(left))
	else
		idle()
	end
end

function Display.Start()
	startedAt = GetTime()
	text:SetText(Timer.Format(Timer.WINDOW))
	frame:SetScript("OnUpdate", onUpdate)
	frame:Show()
end

local function savePosition()
	local point, _, _, x, y = frame:GetPoint()
	ns.db.point, ns.db.x, ns.db.y = point, x, y
end

local function setLocked(locked)
	ns.db.locked = locked
	frame:EnableMouse(not locked)
	if locked then bg:Hide() else bg:Show() end
	if not startedAt then idle() end
end

frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	savePosition()
end)

ns.commands.unlock = function()
	setLocked(false)
	ns.Print("timer unlocked: drag it, then /wft lock")
end

ns.commands.lock = function()
	setLocked(true)
	ns.Print("timer locked")
end

ns.commands.reset = function()
	frame:ClearAllPoints()
	frame:SetPoint("CENTER")
	savePosition()
	ns.Print("timer moved to screen center")
end

ns.commands.test = function()
	Display.Start()
end

table.insert(ns.onLoad, function()
	if ns.db.point then
		frame:ClearAllPoints()
		frame:SetPoint(ns.db.point, UIParent, ns.db.point, ns.db.x, ns.db.y)
	end
	setLocked(ns.db.locked)
end)
