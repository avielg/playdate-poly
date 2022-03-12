
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

	local w = 240
	local h = 100
	self:setSize(w, h)
	self:moveTo(screenW/2 - w/2, screenH/2 - h/2 + 20)
	self:setCenter(0,0)
	self:add()
end

function Alert:set(message, continue, callback)
	self:markDirty()
end

function Alert:draw(x,y,w,h)	
	if self.alertMessage then		
		local r = 8 -- corner radius
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(x,y,w,h,r)
		gfx.setColor(gfx.kColorBlack)
		gfx.setLineWidth(2)
		gfx.drawRoundRect(x,y,w,h,r)
		local m = 4 -- margin
		gfx.drawRoundRect(x+m,y+m,w-m*2,h-m*2,r/2)
		local p = 20 -- padding
		
		local fnt = gfx.font
		local prevFontNormal = gfx.getFont()
		local prevFontBold = gfx.getFont(fnt.kVariantBold)
		local prevFontItalic = gfx.getFont(fnt.kVariantItalic)

		gfx.setFont(gfx.getSystemFont())
		gfx.setFont(gfx.getSystemFont(fnt.kVariantBold), fnt.kVariantBold)
		gfx.setFont(gfx.getSystemFont(fnt.kVariantItalic), fnt.kVariantItalic)

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
		
		gfx.setFont(prevFontNormal)
		gfx.setFont(prevFontBold, fnt.kVariantBold)
		gfx.setFont(prevFontItalic, fnt.kVariantItalic)
		gfx.setImageDrawMode(prevDrawMode)
	end
end

function Alert:clearAlert()
	self.alertMessage = nil
	self.alertContinue = nil
	self.alertClearCallback = nil
	self:markDirty()
end
