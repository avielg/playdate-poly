import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'

local gfx <const> = playdate.graphics

local player = nil
local hud = nil
local ground = nil
local linesSprites = nil

local lines = {}

local dx = 0
local dy = 0

function gameSetup()
	local playerImg = gfx.image.new("images/player")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:moveTo(200,30)
	player:setRotation(90)
	player:add()
	
	ground = gfx.sprite.new()
	ground:setZIndex(-32768)
	ground:setSize(400, 240)
	ground:setCenter(0,0)
	ground:moveTo(0, 0)
	ground:setIgnoresDrawOffset(true)
	ground.draw = function(s, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
		gfx.fillRect(0, 0, width, height)
	end
	ground:add()
	
	linesSprite = gfx.sprite.new()
	linesSprite:setSize(400,240) -- sprite per line
	linesSprite:setCenter(0,0)
	linesSprite:moveTo(0,0)
	linesSprite.draw = function(s, x, y, width, height)
		for key, _ in pairs(lines) do
			lines[key]:draw()
		end
	end
	linesSprite:add()
	
	hud = gfx.sprite.new()
	hud:setSize(140, 60)
	hud:setCenter(0, 0)
	hud:moveTo(0, 0)
	hud:setIgnoresDrawOffset(true)	
	hud.draw = function(s, x, y, width, height)
		gfx.setColor(playdate.graphics.kColorWhite)
		gfx.fillRect(x, y, width, height)
		gfx.drawText("dx " .. dx, 2,2)
		gfx.drawText("dy " .. dy, 2,22)
		gfx.drawText("lines " .. #lines, 2, 42)
	end
	hud:add()
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
		
		hud:markDirty()
		linesSprite:markDirty()
	end
	
	-- local _, y = player:getPosition()
	-- if y-150 > 0 then
	-- 	local offset = -(y-150)
	-- 	gfx.setDrawOffset(0,offset)
	-- end
	
	gfx.sprite.update()
	
	playdate.timer.updateTimers()
end

function playdate.upButtonDown()	moving = 1	end
function playdate.upButtonUp()		moving = 0	end
