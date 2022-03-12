
local gfx <const> = playdate.graphics

class('Alert').extends(gfx.sprite)

local screenW, screenH = playdate.display.getSize()

function Alert:init()
	Alert.super.init(self)
	
	self.alertMessage = nil
	self.alertClearCallback = nil
	self.alertContinue = nil
	self.kAlertContinueContinue = 1
	self.kAlertContinueTryAgain = 2
	self.kAlertContinueNext = 3

	self:setSize(screenW, screenH)
	self:setCenter(0,0)
	self:add()
end

function Alert:set(message, continue, callback)
	self:markDirty()
end

function Alert:draw(_,_,_,_)
	print("draw")
	
	if self.alertMessage then
		print("ALERT", self.alertMessage)
		-- gfx.drawText("Continue Ⓐ", 100, 100)
		
		local sw = screenW -- screen width
		local sh = screenH -- screen height
	
		local w = 240
		local h = 100
		
		local x = sw/2 - w/2
		local y = sh/2 - h/2 + 20
		
		local r = 8 -- corner radius
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(x,y,w,h,r)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(x,y,w,h,r)
		local m = 4 -- margin
		gfx.drawRoundRect(x+m,y+m,w-m*2,h-m*2,r/2)
		local p = 20 -- padding
		
		local prevFont = gfx.getFont()
		gfx.setFontFamily(gfx.getSystemFont())
		local prevDrawMode = gfx.getImageDrawMode()
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		
		gfx.setColor(gfx.kColorBlack)
		gfx.drawTextInRect(self.alertMessage, x+p, y+p, w-p*2, h-p*2)
		if self.alertContinue == self.kAlertContinueContinue then
			gfx.drawText("Continue Ⓐ", x+142, y+h-p-8)
		elseif self.alertContinue == self.kAlertContinueTryAgain then
			gfx.drawText("Try Again Ⓐ", x+132, y+h-p-8)
		elseif self.alertContinue == self.kAlertContinueNext then
			gfx.drawText("Next Ⓐ", x+172, y+h-p-8)
		end
		gfx.setFontFamily(prevFont)
		gfx.setImageDrawMode(prevDrawMode)
	end
end

function Alert:clearAlert()
	print("clear")
	self.alertMessage = nil
	self.alertContinue = nil
	self.alertClearCallback = nil
end