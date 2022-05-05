import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'constants'
import 'line'
import 'alert'
import 'hud'
import 'scorpion'
import 'stone'


local fontFamily = {
  [playdate.graphics.font.kVariantNormal] = "fonts/Nontendo/Nontendo-Light",
  [playdate.graphics.font.kVariantBold] = "fonts/Nontendo/Nontendo-Bold"
}

local gfx <const> = playdate.graphics

local font = gfx.font.newFamily(fontFamily)
gfx.setFontFamily(font)

-- Sprites --
-------------

-- Sprite Tags
local kTagSign, kTagFood, kTagScorpion = 1, 2, 3

local player = nil
local hud = Hud()
local scorpion = Scorpion(kTagScorpion)
local stones = {}
local foods = {}
local poops = {}

-- State --
-----------

local screenW, screenH = playdate.display.getSize()

local slines = {} -- sprites of the lines
local offsetY = 0

local moving = 0

local kStateGoing, kStateEating, kStatePoopin, kStateLost, kStateSign = 1, 2, 3, 4, 5
local state = kStateGoing

local alert = nil

function addAboveGroundArt()
	local bushImg = gfx.image.new("images/bush")
	local bush = gfx.sprite.new(bushImg)
	bush:moveTo(360,52)
	bush:add()
	
	local treeImg = gfx.image.new("images/tree")
	local tree = gfx.sprite.new(treeImg)
	tree:moveTo(25,34)
	tree:add()
	
	local signImg = gfx.image.new("images/sign")
	local sign = gfx.sprite.new(signImg)
	sign:setCollideRect(0, 0, sign:getSize())
	sign:setTag(kTagSign)
	sign:moveTo(300,50)
	sign:add()
end

local kAddStoneOffScreen, kAddStoneOnScreen = 1, 2
function addStone(offScreen)
	local extraOffsetFromGround = 30
	local minY = kAboveGroundSpace + extraOffsetFromGround + math.abs(offsetY)
	
	if offScreen == kAddStoneOffScreen then 
		minY += screenH
	end

	local s = stoneSprite(
		0, minY, -- from X,Y
		screenW, minY + screenH -- to X,Y
	)
	table.insert(stones, s)
end

function addFood()
	local minY = kAboveGroundSpace + math.abs(offsetY) + screenH -- always offscreen
	
	local s = gfx.sprite.new()
	local padding = 4
	local x = math.random(padding, screenW - padding)
	local y = math.random(minY, minY + screenH)
	s:moveTo(x,y)
	s:setSize(6,6)
	s:setCollideRect(0, 0, s:getSize())
	s:setTag(kTagFood)
	s.draw = function (self, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillCircleInRect(0,0,width,height)
	end
	s:add()
	table.insert(foods, s)
end

function addPoop()
	local length = 10
	local s = gfx.sprite.new()
	local lo = 6 -- lines offset
	local line = lines[#lines - lo]
	local x = line.fx - length
	local y = line.fy - length
	s:moveTo(x, y)
	s:setSize(length,length) -- we rotate so we need a square to draw in...
	s:setCenter(0,0)
	s:setRotation(player:getRotation())
	s:setZIndex(zIndexPoop)
	s.draw = function(self, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		local w = self.width
		local r = playdate.geometry.rect.new(0, w/2, w, 3) -- 3 will be thickness
		local t = playdate.geometry.affineTransform.new()
		t:rotate(self:getRotation(), w/2, w/2)
		local p = r:toPolygon()
		local np = p * t
		gfx.fillPolygon(np)
	end
	s:add()
	table.insert(poops, s)
end

function resetStones()
	for i = 1, #stones do stones[i]:remove() end
	stones = {}
	for i = 1, math.random(3,6) do addStone(kAddStoneOnScreen) end
end

function resetFoods()
	for i = 1, #foods do foods[i]:remove() end
	foods = {}
end

function resetPoops()
	for i = 1, #poops do poops[i]:remove() end
	poops = {}
end

function resetGame()
	alert:dismiss()
	hud:reset()
	moving = 0
	lines = {}
	
	for i = 1, #slines do slines[i]:remove() end
	slines = {}
	
	resetStones()
	resetFoods()
	resetPoops()

	gfx.setDrawOffset(0,0)
	
	player:moveTo(200,kAboveGroundPlayerPositionY)
	player:setRotation(0)
	
	scorpion:reset()	
	scorpion:setMoving(true)

	gfx.sprite.redrawBackground()

	state = kStateGoing
end

function gameSetup()
	addAboveGroundArt()

	local playerImg = gfx.image.new("images/player5")
	assert(playerImg)
	
	player = gfx.sprite.new(playerImg)
	player:setZIndex(zIndexPlayer)
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
	
	resetStones()
end

gameSetup()

function playdate.cranked(change, acceleratedChange)
	if state == kStateGoing then
		local currentRotation = player:getRotation()
		player:setRotation(currentRotation + change/3)
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
	s:setZIndex(zIndexLine)
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

function isBellyFull()
	return hud.belly >= kMaxFoodInBelly
end

function playdate.update()
	if state == kStateLost then
		scorpion:setMoving(false)
		alert:show(
			"*You are dead!*\nThe scorpion ate you...",
			alert.kAlertContinueTryAgain,
			resetGame
		)
	elseif state == kStatePoopin then
		
	elseif moving == 1 and state == kStateGoing then
		
		-- Move Player --
		------------------
		
		local angle = player:getRotation()
		local dx = math.cos(math.rad(angle))
		local dy = math.sin(math.rad(angle))
		
		local fx = player.x -- from X
		local fy = player.y
		
		local newX = dx * 5
		local newY = dy * 5
		
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
		
				
		local cantMove = false
		local collisions = player:overlappingSprites()
		for i = 1, #collisions do
			local s = collisions[i]
			local tag = s:getTag()
			if tag == kTagFood then
				-- hit food --
				s:remove()
				
				if not isBellyFull() then
					hud.numFoods += 1
					hud.belly += 1
					
					state = kStateEating
					playdate.timer.performAfterDelay(400, 
						function()
							if state == kStateEating then
								state = kStateGoing
							end
						end
					)
				else
					hud:shakeBellyText()
				end
			elseif tag == kTagSign then
				-- hit sign --
				cantMove = true
				state = kStateSign
				alert:show(
					"*Danger!* This area of the desert is full of scorpions!",
					alert.kAlertContinueContinue,
					resetGame
				)
			elseif tag == kTagScorpion then
				-- hit scorpion (maybe) --
				if player:alphaCollision(s) then
					cantMove = true
					state = kStateLost
				end
			else
				-- hit stone --
				cantMove = cantMove or player:alphaCollision(s)
			end
		end
		if cantMove then
			player:moveTo(fx, fy) -- undo move
		end
		
		local tx = player.x
		local ty = player.y
		
		if tx ~= fx or ty ~= fy then
			
			-- Add Line --
			-----------------------------
	
			local line = Line:new(fx, fy, tx, ty)
			table.insert(lines, line)
			addLine(line)
			
			-- Maybe Add Stones & Food --
			-----------------------------
			
			if math.random(1,20) % 20 == 0 then
				addStone(kAddStoneOffScreen)
			end
			
			if math.random(1,20) % 20 == 0 then
				addFood()
			end
			
			-- Scroll Screen --
			-------------------
			
			local offsetStart = 100
			if ty - offsetStart > 0 then
				local offset = -(ty - offsetStart)
				gfx.setDrawOffset(0,offset)
			else
				gfx.setDrawOffset(0,0)
			end
			
		end -- tx ~= fx or ty ~= fy

		hud.playerY = ty
		hud.playerX = tx
		hud.dx = dx
		hud.dy = dy
		hud.numLines = #lines
		hud.scorpionLine = scorpion.scorpionLine
		hud:markDirty()
	else
		if hud.scorpionLine ~= scorpion.scorpionLine then
			hud.scorpionLine = scorpion.scorpionLine
			hud:markDirty()
		end
	end	

	if kScorpionEnabled then
		if scorpion:checkCollisionWithNumLines(#lines) then
			state = kStateLost
		end
	end

	_, offsetY = gfx.getDrawOffset()

	gfx.sprite.update()
	playdate.timer.updateTimers()
	if hud.debugMode then
		playdate.drawFPS(0, 227)
	end
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
	elseif isBellyFull() then
		if state == kStatePoopin then
			if hud.leftToPoop > 0 then
				hud.leftToPoop -= 1
			end
			if hud.leftToPoop == 0 then
				hud.belly = 0
				addPoop()
				state = kStateGoing
			end
			hud:markDirty()
		else
			state = kStatePoopin
			hud.leftToPoop = 10
			hud:shakeBellyText()
			hud:markDirty()
		end
	end
end
