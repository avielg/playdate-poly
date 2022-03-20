
local gfx <const> = playdate.graphics

local stone2 = gfx.image.new("images/patterns/stone2")
local stone1 = gfx.image.new("images/patterns/stone1")
local stone3 = gfx.image.new("images/patterns/stone3")
local stonesImages = {stone1,stone2,stone3}


function stoneSprite(fromX, fromY, toX, toY)
	local img = stonesImages[math.random(1,3)]
	local stone = gfx.sprite.new(img)
	
	local x = math.random(fromX, toX)
	local y = math.random(fromY, toY)
	stone:moveTo(x,y)
	-- stone:setCollideRect(0, 0, player:getSize())
	stone:add()
	return stone
end
