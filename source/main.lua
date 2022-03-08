import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'

local gfx <const> = playdate.graphics

local player = nil

local lines = {}

function gameSetup()
	local playerImg = gfx.image.new("images/player")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:setZIndex(100)
	player:moveTo(200,30)
	player:setRotation(90)
	player:add()
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect(x, y, width, height)
			
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
			gfx.fillRect(0, 60, 400, 180)
			
			for key, _ in pairs(lines) do
				local line = lines[key]
				local outsideDrawRect = 
					line.tx < x or line.fx > x+width 
					or line.ty < y or line.fy > y+height
				
				if not outsideDrawRect then
					line:draw()
				end
			end
			
			gfx.clearClipRect()
		end
	)
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
	
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(0,0,140,60)
	gfx.drawText("dx " .. dx, 2,2)
	gfx.drawText("dy " .. dy, 2,22)
	gfx.drawText("lines " .. #lines, 2, 42)
	
	playdate.timer.updateTimers()
end

function playdate.upButtonDown()	moving = 1	end
function playdate.upButtonUp()		moving = 0	end
