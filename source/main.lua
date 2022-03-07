import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'

local gfx <const> = playdate.graphics

local player = nil

function gameSetup()
	local playerImg = gfx.image.new("images/player")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:moveTo(200,80)
	player:setZIndex(-32768)
	player:add()
	
	-- gfx.sprite.setBackgroundDrawingCallback(
	-- 	function( x, y, width, height )
	-- 		gfx.setClipRect(x, y, width, height)
	-- 		gfx.setColor(playdate.graphics.kColorBlack)
	-- 		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
	-- 		gfx.fillRect(x,y,width, height)
	-- 		gfx.clearClipRect()
	-- 	end
	-- )
end

gameSetup()

local moving = 0

function playdate.cranked(change, acceleratedChange)
	local currentRotation = player:getRotation()
	player:setRotation(currentRotation + change)
	moving = 1
	playdate.timer.performAfterDelay(150, 
		function()
			moving = 0
		end
	)
end

local lines = {}

function playdate.update()
	local dx = 0
	local dy = 0
	if moving == 1 then
		local angle = player:getRotation()
		dx = math.cos(math.rad(angle))
		dy = math.sin(math.rad(angle))
		
		local fx = player.x
		local fy = player.y
		player:moveBy(dx*1.1,dy*1.1)
		local tx = player.x
		local ty = player.y

		local line = Line:new(fx, fy, tx, ty)
		table.insert(lines, line)
	end
	
	gfx.sprite.update()
	
	for _, line in ipairs(lines) do
		line:draw()
	end
	
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(2,2,140,46)
	gfx.drawText("dx " .. dx, 5,5)
	gfx.drawText("dy " .. dy, 5,25)
	
	playdate.timer.updateTimers()
end

function playdate.upButtonDown()	moving = 1	end
function playdate.upButtonUp()		moving = 0	end
