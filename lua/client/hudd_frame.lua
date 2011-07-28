/* 
	HUDDFrame
	
	IMPORTANT INFORMATION:
		- The frame comes with a grabber for resizing. Turn it off with PANEL:SetSizable(false)
		- The frame also comes with some useful hooks:
			- HUDDFrame:OnResize(w,h): gets called every time the w/h change
			- HUDDFrame:OnMove(x,y): gets called every time the x/y change
			- HUDDFrame:OnClose(): gets called when the user exits the panel
			- HUDDFrame:OnDoubleClick(): gets called when the user double clicks the panel, you should use this to bring up property panels
		- Please tell me if you need any other hooks or whatnot
*/

PANEL = {}

AccessorFunc( PANEL, "m_bDraggable", 		"Draggable", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable", 			"Sizable", 			FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 		"ScreenLock", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bDeleteOnClose", 	"DeleteOnClose", 	FORCE_BOOL )

AccessorFunc( PANEL, "m_bBackgroundBlur", 	"BackgroundBlur", 	FORCE_BOOL )


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self:SetFocusTopLevel( true )

//	self:SetCursor( "sizeall" )
	
	self.btnClose = vgui.Create( "DSysButton", self )
	self.btnClose:SetType( "close" )
	self.btnClose.DoClick = function ( button )
		self:OnClose() 
		self:Close() 
	end
	self.btnClose:SetDrawBorder( false )
	self.btnClose:SetDrawBackground( false )
	
	self.btnResize = vgui.Create("DSysButton",self)
	self.btnResize:SetType("grip")
	self.btnResize.DoClick = function() end
	self.btnResize:SetDrawBorder(false)
	self.btnResize:SetDrawBackground( false )
	self.btnResize:SetSize(25,25)
	self.btnResize.OnMousePressed = function() 
		local x,y = gui.MousePos()
		self.Sizing = {x - self:GetWide(),y - self:GetTall()}
	end
	self.btnResize.OnMouseReleased = function() self.Sizing = false end
	
	self.lblTitle = vgui.Create( "DLabel", self )
	
	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetScreenLock( true )
	self:SetDeleteOnClose( true )
	self:SetTitle( "#Untitled DFrame" )
	
	// This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	
	self.m_fCreateTime = SysTime()
	self.LastClick = 0

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:ShowCloseButton( bShow )

	self.btnClose:SetVisible( bShow )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetTitle( strTitle )

	self.lblTitle:SetText( strTitle )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Close()

	self:SetVisible( false )

	if ( self:GetDeleteOnClose() ) then
		self:Remove()
	end

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Center()

	self:InvalidateLayout( true )
	self:SetPos( ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2 )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Think()

	if (self.Dragging) then
		local posx,posy = self:GetPos()
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]

		// Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then
		
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
		end
		
		self:SetPos( x, y )
		if x!=posx || y!=posy then self:OnMove(x,y) end
	end
	
	
	if ( self.Sizing and self.m_bSizable) then
	
		local posx,posy = self:GetSize()
		local x = math.Clamp(gui.MouseX() - self.Sizing[1],50,ScrW())
		local y = math.Clamp(gui.MouseY() - self.Sizing[2],50,ScrH())	
	
		self:SetSize( x, y )
		self:SetCursor( "sizenwse" )
		
		if posx != x || posy != y then self:OnResize(x,y) end
		return
	end
	self.btnResize:SetVisible( self.m_bSizable )
	
	if ( self.Hovered &&
         self.m_bSizable &&
	     gui.MouseX() > (self.x + self:GetWide() - 20) &&
	     gui.MouseY() > (self.y + self:GetTall() - 20) ) then	

		self:SetCursor( "sizenwse" )
		return
		
	end
	
	if ( self.Hovered && self:GetDraggable() ) then
		self:SetCursor( "sizeall" )
	end
	
end

function PANEL:OnResize(x,y) end

function PANEL:OnMove(x,y) end

function PANEL:OnClose() end

function PANEL:OnDoubleClick() end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Paint()

	if ( self.m_bBackgroundBlur ) then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

	derma.SkinHook( "Paint", "Frame", self )
	return true

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnMousePressed()

	if CurTime() - self.LastClick < 0.25 then self:OnDoubleClick() end
	self.LastClick = CurTime()

	if ( self.m_bSizable ) then
	
		if ( gui.MouseX() > (self.x + self:GetWide() - 20) &&
			gui.MouseY() > (self.y + self:GetTall() - 20) ) then			
	
			self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end
		
	end
	
	if ( self:GetDraggable() ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
	
end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:OnMouseReleased()

	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

	derma.SkinHook( "Layout", "Frame", self )
	self.btnResize:SetPos( self:GetWide() - self.btnResize:GetWide() , self:GetTall() - self.btnResize:GetTall() )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:IsActive()

	if ( self:HasFocus() ) then return true end
	if ( vgui.FocusedHasParent( self ) ) then return true end
	
	return false

end


derma.DefineControl( "HUDDFrame", "A simpe window", PANEL, "EditablePanel" )