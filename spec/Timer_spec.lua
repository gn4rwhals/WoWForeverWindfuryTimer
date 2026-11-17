local helper = require("spec.helper")
local Timer = helper.load("Timer").Timer

describe("Remaining", function()
	it("is the full window right at the proc", function()
		assert.are.equal(1.5, Timer.Remaining(100, 100))
	end)

	it("counts down during the window", function()
		assert.is_true(math.abs(Timer.Remaining(100, 100.4) - 1.1) < 1e-9)
	end)

	it("is 0 at and after the end of the window", function()
		assert.are.equal(0, Timer.Remaining(100, 101.5))
		assert.are.equal(0, Timer.Remaining(100, 105))
	end)

	it("is 0 when no proc has happened", function()
		assert.are.equal(0, Timer.Remaining(nil, 100))
	end)

	it("never exceeds the window", function()
		assert.are.equal(1.5, Timer.Remaining(100, 99))
	end)
end)

describe("Format", function()
	it("shows one decimal", function()
		assert.are.equal("1.5", Timer.Format(1.5))
		assert.are.equal("1.0", Timer.Format(1))
	end)

	it("rounds up so an active window never shows 0.0", function()
		assert.are.equal("0.1", Timer.Format(0.01))
		assert.are.equal("1.2", Timer.Format(1.11))
		assert.are.equal("1.1", Timer.Format(1.1))
	end)
end)

describe("Matches", function()
	it("matches a case-insensitive substring of the text", function()
		assert.is_true(Timer.Matches("Windfury", "Windfury Weapon"))
		assert.is_true(Timer.Matches("windfury", "Your WINDFURY Totem hits Boar for 300."))
		assert.is_false(Timer.Matches("Windfury", "Stormstrike"))
	end)

	it("treats a numeric match as a spell ID", function()
		assert.is_true(Timer.Matches("25584", "anything", 25584))
		assert.is_false(Timer.Matches("25584", "Windfury Attack", 8232))
		assert.is_false(Timer.Matches("25584", "25584"))
	end)

	it("does not treat match text as a pattern", function()
		assert.is_false(Timer.Matches("W.ndfury", "Windfury"))
	end)

	it("is false for missing values", function()
		assert.is_false(Timer.Matches("Windfury", nil))
		assert.is_false(Timer.Matches(nil, "Windfury"))
		assert.is_false(Timer.Matches("", "Windfury"))
	end)
end)
