lines = {} -- Line objects

Line = {}
Line.__index = Line

local gfx <const> = playdate.graphics

function Line:new(fx, fy, tx, ty)
	local self = {}
	self.fx = fx
	self.fy = fy
	self.tx = tx
	self.ty = ty
	self.width = 20
	
	function self:draw()
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineCapStyle(gfx.kLineCapStyleRound)
		gfx.setLineWidth(self.width)
		gfx.drawLine(fx, fy, tx, ty)
	end

	return self
end
