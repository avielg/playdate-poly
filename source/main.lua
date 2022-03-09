import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'

local gfx <const> = playdate.graphics

local player = nil
local hud = nil
-- local ground = nil

local lines = {} -- Line objects
local slines = {} -- sprites of the lines

local dx = 0
local dy = 0

function gameSetup()
	local playerImg = gfx.image.new("images/player")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:moveTo(200,30)
	player:setRotation(90)
	player:add()
	
	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height )
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
			gfx.fillRect(x, y, width, height)
			gfx.clearClipRect()
		end
	)

	-- ground = gfx.sprite.new()
	-- ground:setSize(playdate.display.getSize())
	-- ground:setCenter(0,0)
	-- ground:moveTo(0, 0)
	-- ground:setZIndex(-32768)
	-- ground:setIgnoresDrawOffset(true)
	-- ground:setUpdatesEnabled(false)
	-- ground.draw = function(s, x, y, width, height)
	-- 	gfx.setClipRect( x, y, width, height )
	-- 	gfx.setColor(gfx.kColorBlack)
	-- 	gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
	-- 	gfx.fillRect(0, 0, width, height)
	-- 	gfx.clearClipRect()
	-- end
	-- ground:add()
	
	hud = gfx.sprite.new()
	hud:setSize(400, 20)
	hud:setCenter(0, 0)
	hud:moveTo(0, 0)
	hud:setIgnoresDrawOffset(true)	
	hud.draw = function(s, x, y, width, height)
		gfx.setClipRect( x, y, width, height )
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x, y, width, height)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		gfx.drawText("dx " .. dx, 2,2)
		gfx.drawText("dy " .. dy, 142,2)
		gfx.drawText("lines " .. #lines, 282, 2)
		gfx.clearClipRect()
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

function addLine(line)
	local s = gfx.sprite.new()
	s:setSize(
		(line.tx-line.fx)+20,
		(line.ty-line.fy)+20
	)
	s:moveTo(line.tx,line.ty)
	-- s:setSize(100+line.ty,240)
	-- s:moveTo(0,0)
	-- s:setCenter(0,0)
	s.draw = function(self ,x, y, width, height)
		-- gfx.setClipRect( x, y, width, height )
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineCapStyle(gfx.kLineCapStyleRound)
		gfx.setLineWidth(20)
		gfx.drawLine(0,0,width,height)
		-- gfx.drawLine(line.fx, line.fy, line.tx, line.ty)
		-- gfx.clearClipRect()
	end
	s:add()
	table.insert(slines, s)
end

function playdate.update()
	if moving == 1 then
		
		-- Move Player --
		------------------
		
		local angle = player:getRotation()
		dx = math.cos(math.rad(angle))
		dy = math.sin(math.rad(angle))
		
		local fx = player.x -- from X
		local fy = player.y
		
		local newX = dx*2
		local newY = dy * 2
		player:moveBy(0,newY) -- Can always move Y, but X not always...
		
		-- Avoid going past screen edges
		if player.x + newX < 400 and player.x + newX >= 0 then
			player:moveBy(newX,0)
		end

		local tx = player.x
		local ty = player.y

		-- Draw Lines & Background --
		-----------------------------

		local line = Line:new(fx, fy, tx, ty)
		table.insert(lines, line)
		addLine(line)
		hud:markDirty()
		
		for _, s in pairs(slines) do
			s:markDirty()
		end
		-- ground:markDirty()
		gfx.sprite.redrawBackground()
		
		-- Scroll Screen --
		-------------------

		local _, y = player:getPosition()
		local offsetStart = 100
		if y - offsetStart > 0 then
			local offset = -(y - offsetStart)
			-- print(offset ,fx, fy, tx, ty)
			
			gfx.setDrawOffset(0,offset)
			-- gfx.sprite.addDirtyRect(0, -offset, 400, 240)
		end
	end

	gfx.sprite.update()
	playdate.timer.updateTimers()
end

function playdate.upButtonDown()	moving = 1	end
function playdate.upButtonUp()		moving = 0	end
function playdate.leftButtonDown()
	local currentRotation = player:getRotation()
	player:setRotation(currentRotation - 20)
end
function playdate.rightButtonDown()
	local currentRotation = player:getRotation()
	player:setRotation(currentRotation + 20)
end