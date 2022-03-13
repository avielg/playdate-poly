
local gfx <const> = playdate.graphics

class('Hud').extends(gfx.sprite)

function Hud:init()
	Hud.super.init(self)
	
	self:setZIndex(999)
	self:setSize(400, 14)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setIgnoresDrawOffset(true)	
	self:add()
	
	self:reset()
	return self
end

function Hud:draw(x, y, width, height)
	gfx.setClipRect(x, y, width, height)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(x, y, width, height)
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	if self.scorpionLine then
		gfx.drawText("Lines " .. self.numLines .. " | " .. self.numLines - self.scorpionLine, 0, 0)
	else
		gfx.drawText("Lines " .. self.numLines, 0, 0)
	end
	gfx.drawText("Player " .. self.playerX .. ", " .. self.playerY, 80, 0)
	gfx.drawText("dx " .. self.dx, 260,0)
	gfx.drawText("dy " .. self.dy, 330,0)
	gfx.clearClipRect()
end

function Hud:reset()
	self.dx = 0
	self.dy = 0
	self.playerY = 0
	self.playerX = 0
	self.numLines = 0
	self.scorpionLine = nil
	self:markDirty()
end
