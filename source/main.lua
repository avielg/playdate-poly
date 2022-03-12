import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'
import 'alert'

local fontFamily = {
  [playdate.graphics.font.kVariantNormal] = "fonts/Nontendo/Nontendo-Light",
  [playdate.graphics.font.kVariantBold] = "fonts/Nontendo/Nontendo-Bold"
  -- [playdate.graphics.font.kVariantItalic] = "path/to/italicFont"
}

local gfx <const> = playdate.graphics

local font = gfx.font.newFamily(fontFamily)
gfx.setFontFamily(font)

local player = nil
local hud = nil
-- local ground = nil
local scorpion = nil
local scorpionLine = nil

local lines = {} -- Line objects
local slines = {} -- sprites of the lines

local timer = nil

local dx = 0
local dy = 0
local playerY = 0
local playerX = 0

local moving = 0

local kStateGoing = 1
local kStateLost = 2
local state = kStateGoing

local alert = nil

function resetGame()
	alert:clearAlert()
	dx = 0
	dy = 0
	playerX = 0
	playerY = 0
	moving = 0
	lines = {}
	
	for i = 1, #slines do
		slines[i]:remove()
	end
	slines = {}
	
	player:moveTo(200,30)
	player:setRotation(90)
	
	scorpion:moveTo(200,0)
	scorpion:setVisible(false)
	
	hud:markDirty()
	
	state = kStateGoing
	timer:start()
end

function gameSetup()
	alert = Alert()
	alert:setZIndex(998)
	alert:setIgnoresDrawOffset(true)
	
	local playerImg = gfx.image.new("images/player")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:moveTo(200,30)
	player:setRotation(90)
	player:setCollideRect(0, 0, player:getSize())
	player:add()
	
	local scorpionImg = gfx.image.new("images/scorpion")
	assert(scorpionImg)
	
	scorpion = gfx.sprite.new(scorpionImg)
	scorpion:moveTo(200,0)
	scorpion:setCollideRect(0, 0, scorpion:getSize())
	scorpion:add()
	scorpion:setVisible(false)

	local function timerCallback()
		scorpion:setVisible(player.y > 100)
		-- print("scorpion!")
		if scorpion:isVisible() then
			if scorpionLine then
				scorpionLine += 1
			else
				scorpionLine = 1
			end
			local line = lines[scorpionLine]
			local radians = math.atan2(line.tx-line.fx, line.ty-line.fy)
			local degrees = 360 - math.deg(radians)
			scorpion:moveTo(line.fx, line.fy)
			scorpion:setRotation(degrees)
		end
	end
	timer = playdate.timer.new(20, timerCallback)
	timer.repeats = true

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
	hud:setZIndex(999)
	hud:setSize(400, 14)
	hud:setCenter(0, 0)
	hud:moveTo(0, 0)
	hud:setIgnoresDrawOffset(true)	
	hud.draw = function(s, x, y, width, height)
		gfx.setClipRect( x, y, width, height )
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x, y, width, height)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		gfx.drawText("Lines " .. #lines, 0, 0)
		gfx.drawText("Player " .. playerX .. ", " .. playerY, 80, 0)
		gfx.drawText("dx " .. dx, 260,0)
		gfx.drawText("dy " .. dy, 330,0)
		gfx.clearClipRect()
	end
	hud:add()
end

gameSetup()

function playdate.cranked(change, acceleratedChange)
	if state == kStateGoing then
		local currentRotation = player:getRotation()
		player:setRotation(currentRotation + change)
		moving = 1
		playdate.timer.performAfterDelay(150, 
			function()
				moving = 0
			end
		)
	end
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
	if state == kStateLost then
		timer:pause()
		
		alert.alertMessage = "*You are dead!*\nThe scorpion ate you..."
		alert.alertContinue = alert.kAlertContinueTryAgain
		alert.alertClearCallback = function()
			resetGame()
		end
		alert:markDirty()
	elseif moving == 1 and state == kStateGoing then
		
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
		playerY = ty
		playerX = tx

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

		local offsetStart = 100
		if playerY - offsetStart > 0 then
			local offset = -(playerY - offsetStart)
			-- print(offset ,fx, fy, tx, ty)
			
			gfx.setDrawOffset(0,offset)
			-- gfx.sprite.addDirtyRect(0, -offset, 400, 240)
		end
	end

	local collisions = gfx.sprite.allOverlappingSprites()
	
	for i = 1, #collisions do
			local collisionPair = collisions[i]
			local s1 = collisionPair[1]
			local s2 = collisionPair[2]
			if scorpion:isVisible() then
				if (s1 == player and s2 == scorpion) or (s2 == player and s1 == scorpion) then
					state = kStateLost
				end
			end
			
	end
	
	gfx.sprite.update()
	playdate.timer.updateTimers()
end

function playdate.upButtonDown()	moving = 1	end
function playdate.upButtonUp()		moving = 0	end
function playdate.leftButtonDown()
	if state == kStateGoing then
		local currentRotation = player:getRotation()
		player:setRotation(currentRotation - 20)
	end
end
function playdate.rightButtonDown()
	if state == kStateGoing then
		local currentRotation = player:getRotation()
		player:setRotation(currentRotation + 20)
	end
end
function playdate.AButtonUp()
	resetGame()
end
