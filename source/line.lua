
Line = {}
Line.__index = Line

local gfx <const> = playdate.graphics

function Line:new(fx, fy, tx, ty)
	local self = {}
	self.fx = fx
	self.fy = fy
	self.tx = tx
	self.ty = ty
	
	function self:draw()
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineCapStyle(gfx.kLineCapStyleRound)
		gfx.setLineWidth(20)
		gfx.drawLine(fx, fy, tx, ty)
	end

	return self
end
