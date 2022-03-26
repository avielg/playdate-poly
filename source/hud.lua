import 'constants'

local gfx <const> = playdate.graphics

class('Hud').extends(gfx.sprite)

function Hud:init()
	Hud.super.init(self)
	
	self:setZIndex(999)
	self:setSize(400, 16)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setIgnoresDrawOffset(true)	
	self:add()
	
	self:bellyText()
	self:reset()
	return self
end

function Hud:bellyText()
	if self.belly == 0 then return ""
	elseif self.belly == 1 then return "O"
	elseif self.belly == 2 then return "OO"
	elseif self.belly == 3 then return "OOO"
	elseif self.belly == 4 then return "OOOO"
	elseif self.belly == 5 then return "NEED TO POOP!"
	end
end

local offsetBellyText = 0
local shakeTimer = nil
function Hud:shakeBellyText()
	if shakeTimer ~= nil then return end

	local t = playdate.timer.new(40, 0, 10)
	t.reverses = true
	t.repeats = true
	t.reverseEasingFunction = playdate.easingFunctions.outQuad
	t.updateCallback = function(timer)
		offsetBellyText = timer.value
	end
	t.timerEndedCallback = function(timer)
		shakeTimer = nil
		timer:remove()		
	end
	t = shakeTimer
end

function Hud:draw(x, y, width, height)
	gfx.setClipRect(x, y, width, height)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(x, y, width, height)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	
	local dy = 2 -- draw Y
	if self.debugMode then
		if self.scorpionLine then
			gfx.drawText("Lines " .. self.numLines .. " | " .. self.numLines - self.scorpionLine, 0, dy)
		else
			gfx.drawText("Lines " .. self.numLines, 0, dy)
		end
		gfx.drawText("Player " .. self.playerX .. ", " .. self.playerY, 80, dy)
		gfx.drawText("dx " .. self.dx, 260,dy)
		gfx.drawText("dy " .. self.dy, 330,dy)
	else
		local adjustedY = self.playerY - 60
		local digging = adjustedY > 0
		if digging then
			local cm = adjustedY / 100 -- each pixel is a millimeter...
			gfx.drawText("Depth: *" .. math.floor(cm) .. " cm*", 2, dy)
			
			local bt = self:bellyText()
			local spaces = ""
			for i = 1, offsetBellyText do
				if i % 3 == 0 then
					local tick = " "
					spaces = spaces .. tick
				end
			end
			gfx.drawText("Food: *" .. self.numFoods .. " noms*  " .. spaces .. bt, 80, dy)
		else
			gfx.drawText("Start digging!", 2, dy)
		end
		
		if self.scorpionLine then
			local distance = self.numLines - self.scorpionLine - kLinesWhenScorpionHitPlayer
			distance = math.min(kAboveGroundSpace, distance)
			local careful = distance < 16
			local text = ""
			for i = 1, distance do
				if i % 3 == 0 then
					local tick = "I"
					if careful then tick = "!  " end
					text = text .. "*" .. tick .. "* "
				end
			end
			if careful and distance > 0 then
				gfx.drawText("*Careful*", 232, dy)
			end	
			gfx.drawText(text, 280, dy)
		end
	end
	gfx.clearClipRect()
end

function Hud:reset()
	self.debugMode = false
	self.dx = 0
	self.dy = 0
	self.playerY = 0
	self.playerX = 0
	self.numLines = 0
	self.numFoods = 0
	self.belly = 0
	self.scorpionLine = nil
	self:markDirty()
end
