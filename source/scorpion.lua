-- scorpion appears (and begins moving) only after player moved this many lines
local kNumOfLinesWhenScorpionAppears = 60

-- When the scorpion distance to player is this many lines - we lost
local kLinesWhenScorpionHitPlayer = 15

import 'line'

local gfx <const> = playdate.graphics

class('Scorpion').extends(gfx.sprite)

function Scorpion:init()
	local scorpionImg = gfx.image.new("images/scorpion2")
	assert(scorpionImg)
	
	Scorpion.super.init(self, scorpionImg)
	
	self:reset()

	self:setCollideRect(0, 0, self:getSize())
	self:add()
	
	self.timer = playdate.timer.new(20, 
		function(t)
			self:timerCallback(t)
		end
	)
	self.timer.repeats = true
	
	return self
end

function Scorpion:checkCollisionWithNumLines(numLines)
	self:setVisible(numLines > kNumOfLinesWhenScorpionAppears)
	if numLines > 0 and self.scorpionLine then
		if self.scorpionLine > (numLines - kLinesWhenScorpionHitPlayer) then
			return true
		end
	end
end

function Scorpion:setMoving(isMoving)
	if isMoving then
		self.timer:start()
	else
		self.timer:pause()
	end
end

function Scorpion:timerCallback(t)
	if self:isVisible() then
		if self.scorpionLine then
			self.scorpionLine += 1
		else
			self.scorpionLine = 1
		end
		local line = lines[self.scorpionLine]
		local radians = math.atan2(line.tx-line.fx, line.ty-line.fy)
		local degrees = 360 - math.deg(radians)
		
		local scorpionDegrees  = self:getRotation()
		local degTo = degrees
		local degFrom = scorpionDegrees
		local a = degTo - degFrom
		a = (a + 180) % 360 - 180
		-- next timer update is # of degrees:
		-- the larger the degrees slower the movement...
		t.duration = math.max(4, a * 2)
		
		-- also, no turn (0 degrees) skips lines
		if a == 0 then
			self.scorpionMovesWithoutTurns += 1
			-- if scorpion moves straight 5 times in a row it skips a line!
			if self.scorpionMovesWithoutTurns % 3 == 0 then
				self.scorpionLine += 1
				line = lines[self.scorpionLine]
			end
		else
			self.scorpionMovesWithoutTurns = 0
		end
		
		self:moveTo(line.fx, line.fy)
		self:setRotation(degrees)
	end
end

function Scorpion:reset()
	self.scorpionMovesWithoutTurns = 0
	self.scorpionLine = nil
	self:moveTo(200,0)
	self:setVisible(false)
end
