
local gfx <const> = playdate.graphics
local gem <const> = playdate.geometry

math.randomseed(playdate.getSecondsSinceEpoch())

class('Rock').extends(gfx.sprite)

import 'poly'
import 'rockgen'

local rockPattern = gfx.image.new("images/patterns/rock1")
assert(rockPattern)

function Rock:init(x,y)
	Rock.super.init(self)
	
	local rand <const> = math.random
	
	local kThreshold <const> = 10
	-- local sx, sy = rand(0, kThreshold), rand(0, kThreshold) -- start, north west
	
	-- local nwX, nwY = sx, sy
	-- local neX, neY = rand(sx, sx + kThreshold), rand(0, kThreshold)
	-- local seX, seY = rand(sx, sx + kThreshold), rand(neY, neY + kThreshold)
	-- local swX, swY = rand(0, kThreshold), rand(neY, neY + kThreshold)
	-- self.polygon = gem.polygon.new(
	-- 	nwX, nwY,
	-- 	neX, neY,
	-- 	seX, seY,
	-- 	swX, swY
	-- )
	
	
	-- local polyNE = polyRegular(14, 30, {})
	-- -- print("BEFORE", #polyNE, table.unpack(polyNE))
	-- local lowestX = 0
	-- local lowestY = 0
	-- for i = 1, #polyNE do
	-- 	if i % 2 == 0 then
	-- 		lowestY = math.min(lowestY, polyNE[i])
	-- 	else
	-- 		lowestX = math.min(lowestX, polyNE[i])
	-- 	end
	-- end
	-- for i = 1, #polyNE do
	-- 	if i % 2 == 0 then
	-- 		polyNE[i] += math.abs(lowestY)
	-- 	else
	-- 		polyNE[i] += math.abs(lowestX)
	-- 	end
	-- 	polyNE[i] = math.floor(polyNE[i])
	-- end
	-- print("AFTER", #polyNE, table.unpack(polyNE))
	-- 
	-- self.polygon = gem.polygon.new(table.unpack(polyNE))
	-- 
	
	local t = gem.affineTransform.new()
	self.polygon = generateRock()
	
	-- self.polygon:close()

	
	-- print(self.polygon)
	local _, _, width, height = self.polygon:getBounds()
	self:setSize(width, height)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:add()
	
	return self
end

function Rock:draw(x, y, width, height)
		gfx.setClipRect(x, y, width, height)
		gfx.setColor(gfx.kColorXOR) -- kinda looks like dither
		gfx.setColor(gfx.kColorBlack)
		-- gfx.setPattern(rockPattern)
		

		gfx.fillPolygon(self.polygon)
		gfx.clearClipRect()
end

local rocks = {}
local rocksCount = math.random(3, 6)
while rocksCount > 0 do
	local x = math.random(0, 240)
	local y = math.random(60, 400)
	table.insert(rocks, Rock(x,y))
	rocksCount -= 1
end