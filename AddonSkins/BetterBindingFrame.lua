
function Skinner:BetterBindingFrame()
	if not self.db.profile.MenuFrames then return end

	self:skinScrollBar{obj=BetterBindingFrame_HeadersScrollFrame}
	self:skinEditBox{obj=BBF_SearchEditBox, regs={9}, move=true}

	-- this is the Headers Frame
	self:addSkinFrame{obj=self:getChild(KeyBindingFrame, 24), ftype=ftype, kfs=true, bg=true, y1=-4, x2=-45, y2=4}
	
end
