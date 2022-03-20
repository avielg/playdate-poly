-- source: https://discord.com/channels/675983554655551509/821661913393004565/954803491069636768
import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- performance shortcut
local gfx = playdate.graphics

-- Utility functions to convert polar (radial) coordinates to cartesian (x,y)

function polarToCartesian(angle, distance)
	
	angle   = -angle + 90 -- 0 degrees is UP in Playdate SDK	
	local x = distance * math.cos(math.rad(angle))
	local y = -distance * math.sin(math.rad(angle)) -- correct for screen coordinate system

	return x, y	
end

function cartesianToPolar(x, y)
		
	local angle = math.atan(y, x)
		  angle = normalAngle(math.deg(angle) + 90) -- 0 degrees is UP in Playdate SDK	
	local distance = math.sqrt(x*x + y*y)
	
	return angle, distance
end

-- we'll need random values later, so let's seed now
math.randomseed(playdate.getSecondsSinceEpoch())

-- Rock

-- Rock metrics
local rockMaxWidth, rockMaxHeight = 100, 100
local rockMinRadius = math.max(rockMaxWidth/4, rockMaxHeight/4) -- 2 is a magic number here; set it to whatever you want
local rockMaxRadius = math.min(rockMaxWidth/2, rockMaxHeight/2) -- the farthest distance a point can be from the rock center
local rockCenterX, rockCenterY = rockMaxWidth/2, rockMaxHeight/2

function generateRock()

	local rockNumPoints = math.random(5, 15)
	
	rockPoly = playdate.geometry.polygon.new(rockNumPoints)
	
	-- generate all points
	
	-- -- first, we'll generate points along a circle in order. This will guarantee a closed polygon. 
	local angles = table.create(rockNumPoints, 0)
	for i = 1, rockNumPoints do
		-- angles[i] = math.random(0, 360) -- totally random angle
		-- regular division along the circle, but offset slightly
		angles[i] = i*(360/rockNumPoints) + math.random(-10,10)
	end
	table.sort(angles)
	
	for i = 1, rockNumPoints do	
		local x, y = polarToCartesian(angles[i], math.random(rockMinRadius, rockMaxRadius))
		
		rockPoly:setPointAt(i, rockCenterX + x, rockCenterY + y)
		print(rockPoly:getPointAt(i):unpack())	
	end
	rockPoly:close()
	return rockPoly
end

-- gfx.setColor(gfx.kColorBlack)
-- generateRock()
-- 
-- function playdate.update()
-- 
-- 	gfx.fillPolygon(rockPoly)
-- 	
-- 	if playdate.buttonJustPressed(playdate.kButtonA) then
-- 		gfx.clear(gfx.kColorWhite)
-- 		generateRock()
-- 	end
-- 	
-- end
