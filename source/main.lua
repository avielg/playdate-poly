import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'
import 'alert'
import 'hud'
import 'scorpion'

-- The height of space above ground shown when starting the game
local kAboveGroundSpace = 60

-- The Y position at which the player appears walking "on ground"
local kAboveGroundPlayerPositionY = 46

local fontFamily = {
  [playdate.graphics.font.kVariantNormal] = "fonts/Nontendo/Nontendo-Light",
  [playdate.graphics.font.kVariantBold] = "fonts/Nontendo/Nontendo-Bold"
}

local gfx <const> = playdate.graphics

local font = gfx.font.newFamily(fontFamily)
gfx.setFontFamily(font)

local player = nil
local hud = Hud()
local scorpion = Scorpion()

local slines = {} -- sprites of the lines
local offsetY

local moving = 0

local kStateGoing, kStateLost = 1, 2
local state = kStateGoing

local alert = nil

function resetGame()
	alert:dismiss()
	hud:reset()
	moving = 0
	lines = {}
	
	for i = 1, #slines do
		slines[i]:remove()
	end
	slines = {}
	
	gfx.setDrawOffset(0,0)
	
	player:moveTo(200,kAboveGroundPlayerPositionY)
	
	scorpion:reset()	
	scorpion:setMoving(true)

	gfx.sprite.redrawBackground()

	state = kStateGoing
end

function gameSetup()
	local playerImg = gfx.image.new("images/player3")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:moveTo(200,kAboveGroundPlayerPositionY)
	player:setCollideRect(0, 0, player:getSize())
	player:add()
	
	alert = Alert()

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height )
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
			local offsetedSpace = kAboveGroundSpace + offsetY
			gfx.fillRect(x, math.max(y, offsetedSpace), width, height)
			gfx.clearClipRect()
		end
	)
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
	s.draw = function(self ,x, y, width, height)
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineCapStyle(gfx.kLineCapStyleRound)
		gfx.setLineWidth(20)
		gfx.drawLine(0,0,width,height)
	end
	s:add()
	table.insert(slines, s)
end

function playdate.update()
	if state == kStateLost then
		scorpion:setMoving(false)
		alert:show(
			"*You are dead!*\nThe scorpion ate you...",
			alert.kAlertContinueTryAgain,
			resetGame
		)
	elseif moving == 1 and state == kStateGoing then
		
		-- Move Player --
		------------------
		
		local angle = player:getRotation()
		local dx = math.cos(math.rad(angle))
		local dy = math.sin(math.rad(angle))
		
		local fx = player.x -- from X
		local fy = player.y
		
		local newX = dx*2
		local newY = dy * 2
		
		-- Avoid going higher than "ground level"
		if player.y + newY > kAboveGroundPlayerPositionY then
			player:moveBy(0,newY)	
		else
			player:setRotation(0) -- don't rotate if not digging
		end
		
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
		
		for _, s in pairs(slines) do
			s:markDirty()
		end
		gfx.sprite.redrawBackground()
		
		-- Scroll Screen --
		-------------------

		local offsetStart = 100
		if ty - offsetStart > 0 then
			local offset = -(ty - offsetStart)
			gfx.setDrawOffset(0,offset)
		else
			gfx.setDrawOffset(0,0)
		end
		
		hud.playerY = ty
		hud.playerX = tx
		hud.dx = dx
		hud.dy = dy
		hud.numLines = #lines
		hud.scorpionLine = scorpion.scorpionLine
		hud:markDirty()
	end

	if scorpion:checkCollisionWithNumLines(#lines) then
		state = kStateLost
	end

	_, offsetY = gfx.getDrawOffset()

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
	if alert:isShowing() then
		resetGame()
	end
end
