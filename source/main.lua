import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'line'
import 'alert'
import 'hud'

-- When the scorpion distance to player is this many lines - we lost
local kLinesWhenScorpionHitPlayer = 25

-- scorpion appears (and begins moving) only after player moved this many lines
local kNumOfLinesWhenScorpionAppears = 60

local fontFamily = {
  [playdate.graphics.font.kVariantNormal] = "fonts/Nontendo/Nontendo-Light",
  [playdate.graphics.font.kVariantBold] = "fonts/Nontendo/Nontendo-Bold"
}

local gfx <const> = playdate.graphics

local font = gfx.font.newFamily(fontFamily)
gfx.setFontFamily(font)

local player = nil
local hud = Hud()
local scorpion = nil

local scorpionLine = nil
local lines = {} -- Line objects
local slines = {} -- sprites of the lines

local timer = nil
local moving = 0

local kStateGoing, kStateLost = 1, 2
local state = kStateGoing

local alert = nil

function resetGame()
	alert:dismiss()
	hud:reset()
	moving = 0
	lines = {}
	scorpionLine = nil
	
	for i = 1, #slines do
		slines[i]:remove()
	end
	slines = {}
	
	player:moveTo(200,30)
	player:setRotation(90)
	
	scorpion:moveTo(200,0)
	scorpion:setVisible(false)
	
	gfx.setDrawOffset(0,0)
	
	state = kStateGoing
	timer:start()
end

local scorpionMovesWithoutTurns = 0

function gameSetup()
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

	local function timerCallback(t)
		scorpion:setVisible(#lines > kNumOfLinesWhenScorpionAppears)
		if scorpion:isVisible() then
			if scorpionLine then
				scorpionLine += 1
			else
				scorpionLine = 1
			end
			local line = lines[scorpionLine]
			local radians = math.atan2(line.tx-line.fx, line.ty-line.fy)
			local degrees = 360 - math.deg(radians)
			
			local scorpionDegrees  = scorpion:getRotation()
			local degTo = degrees
			local degFrom = scorpionDegrees
			local a = degTo - degFrom
			a = (a + 180) % 360 - 180
			-- next timer update is # of degrees:
			-- the larger the degrees slower the movement...
			t.duration = math.max(4, a * 2)
			
			-- also, no turn (0 degrees) skips lines
			if a == 0 then
				scorpionMovesWithoutTurns += 1
				-- if scorpion moves straight 5 times in a row it skips a line!
				if scorpionMovesWithoutTurns % 3 == 0 then
					scorpionLine += 1
					line = lines[scorpionLine]
				end
			else
				scorpionMovesWithoutTurns = 0
			end
			
			scorpion:moveTo(line.fx, line.fy)
			scorpion:setRotation(degrees)
			hud.scorpionLine = scorpionLine
			hud:markDirty()
		end
	end
	timer = playdate.timer.new(20, timerCallback)
	timer.repeats = true

	alert = Alert()

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height )
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.8, gfx.image.kDitherTypeScreen)
			gfx.fillRect(x, y, width, height)
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
		timer:pause()

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
		hud:markDirty()
	end

	if #lines > 0 and scorpionLine then
		if scorpionLine > (#lines - kLinesWhenScorpionHitPlayer) then
			state = kStateLost
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
	if alert:isShowing() then
		resetGame()
	end
end
