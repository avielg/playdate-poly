
import 'constants'
import 'line'

local gfx <const> = playdate.graphics

class('Scorpion').extends(gfx.sprite)

function Scorpion:init(tag)
	local scorpionImg = gfx.image.new("images/scorpion3")
	assert(scorpionImg)
	
	Scorpion.super.init(self, scorpionImg)
	
	self:setZIndex(zIndexScorpion)
	self:setTag(tag)
	self:reset()
	self:updateCollision()
	self:add()
	
	self.timer = playdate.timer.new(20, 
		function(t)
			self:timerCallback(t)
		end
	)
	self.timer.repeats = true
	
	return self
end

function Scorpion:updateCollision()
	local d = self:getRotation() % 180
	if d > 45 and d < 135 then
		self:setCollideRect(20, 7, 30, 16)
	else
		self:setCollideRect(7, 20, 16, 30)
	end
end

function Scorpion:checkCollisionWithNumLines(numLines)
	local visible = numLines > kNumOfLinesWhenScorpionAppears
	if self:isVisible() ~= visible then
		self:setVisible(visible)
	end
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
		self:updateCollision()
	end
end

function Scorpion:reset()
	self.scorpionMovesWithoutTurns = 0
	self.scorpionLine = nil
	self:moveTo(200,0)
	self:setVisible(false)
end
