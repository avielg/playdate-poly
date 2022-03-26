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
	return self
end
