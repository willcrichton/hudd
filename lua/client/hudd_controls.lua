/*
	///// HUDDProperties - uses DFrame base /////
	
	IMPORTANT INFORMATION:
		- The HUDDProperties is the default panel you should use for your plugins
		- It comes built in with x, y, width, height, and color -- tell me if you think something else should get put in
		- To add other stuff, just make the panel bigger and put in your own elements
		- TO SET/GET VALUES AND MAKE THAT AFFECT YOUR PANEL = SUPER IMPORTANT SUPER IMPORTANT:
			- HUDDProperties:OnValChanged(key,value) -- how it gets done, you should make this hook whenever you make the properties panel
				- To use it, you say something like "if key == "width" then panel:SetWide( value ) end"
			- To set a value ON the HUDDProperties panel, use HUDDProperties:SetVal( "key", value ) -- THIS DOES NOT CALL OnValChanged for a good reason
			- To call OnValChanged via a custom key, pass "true" as a third argument to the function -- HUDDProperties:SetVal( "my_key", value, true )
		-- REFERENCE: See hud_plugins/sample_plugin.lua for implementation if this is too confusing (PLUGIN:Create())
			
	IMPORTANT FUNCTIONS:
		HUDDProperties:SetVal( string key, var value, bool shouldAffectElements ) - explained above
		HUDDProperties:GetVal( string key ) - get the current value for the key
		HUDDProperties:OnThink() - gets called every think
		HUDDProperties:SetPanelName( string name ) - set the name drawn at the top left of the panel
		HUDDProperties:GetPanelName() - gets the name drawn at the top left
		
		
	
	
	///// HUDDQuery - uses DPanel base /////
	
	IMPORTANT INFORMATION:
		- HUDDQuery is a simple box used for getting a string from the user because I hate the default one
		- If you think it looks ugly, then get me some textures or something
		- use HUDDQuery:OnSubmit( string text ) to get the value returned
		- REFERENCE: See hud_plugins/image.lua for implementation (PLUGIN:OnClick())
	
	IMPORTANT FUNCTIONS:
		HUDDQuery:SetQuestion( string question ) - sets the question (drawn top left of panel)
		HUDDQuery:GetQuestion()
		HUDDQuery:SetHelpText( string text ) - sets text to help the player, drawn below the question
		HUDDQuery:GetHelpText()
		HUDDQuery:OnSubmit( string text ) -- called whenever the user submits an answer [in this case, is OnEnter]	
*/

PANEL = {}
PANEL.Vars = {}
/* VALID VARS:
	x		x-coordinate of the panel
	y		y-coordinate of the panel
	width 	Width of the panel
	height	Height of the panel
	color		Color of the panel
*/

function PANEL:Init()
	
	self:SetSize(280,160)
	self:MakePopup()
	self.m_bDraggable = true
	self.lblTitle:SetVisible( false )
	self.HUDDObject = "Unknown Panel"
	
	self.ColorPicker = vgui.Create( "DColorMixer",self )
	self.ColorPicker:SetPos(10,25)
	self.ColorPicker:SetSize(190,120)
	self.ColorPicker:SetColor(Color(255,255,255,10))
	
	self.Width = vgui.Create("DTextEntry",self)
	self.Width:SetPos( 230, 25 )
	self.Width:SetSize( 40, 20 )
	self.Width.OnTextChanged = function()
		local val = self.Width:GetValue()
		if tonumber(val) then
			self:SetVal("width",val,true)
		end
	end
	
	self.Height = vgui.Create("DTextEntry",self)
	self.Height:SetPos(230,50)
	self.Height:SetSize(40,20)
	self.Height.OnTextChanged = function()
		local val = self.Height:GetValue()
		if tonumber(val) then
			self:SetVal("height",val,true)
		end
	end
	
	self.CoordX = vgui.Create("DTextEntry",self)
	self.CoordX:SetPos(230,80)
	self.CoordX:SetSize(40,20)
	self.CoordX.OnTextChanged = function()
		local val = self.CoordX:GetValue()
		if tonumber(val) then
			self:SetVal("x",val,true)
		end
	end
	
	self.CoordY = vgui.Create("DTextEntry",self)
	self.CoordY:SetPos(230,105)
	self.CoordY:SetSize(40,20)
	self.CoordY.OnTextChanged = function()
		local val = self.CoordY:GetValue()
		if tonumber(val) then
			self:SetVal("y",val,true)
		end
	end
	
	self.LastCol = self:GetVal("color")
end

function PANEL:GetVal(key) return self.Vars[key] or nil end

function PANEL:SetVal(key,value,bChange)
	if bChange then self:OnValChanged(key,value) end
	self:ValChanged(key,value)
end

function PANEL:SetValNoChange(key,value)
	self:ValChanged(key,value)
end

function PANEL:ValChanged(key,value)
	key = string.lower(key)
	self.Vars[key] = value
	if key == "height" then self.Height:SetValue( value )
	elseif key =="width" then self.Width:SetValue( value )
	elseif key == "color" then self.ColorPicker:SetColor( value )
	elseif key=="x" then self.CoordX:SetValue( value )
	elseif key=="y" then self.CoordY:SetValue(value)
	end
end

function PANEL:OnValChanged(key,val) end

function PANEL:OnThink() end

function PANEL:Paint()
	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,220))
	draw.DrawText("Panel Properties - "..self.HUDDObject,"ScoreboardText",10,3,color_white,0)
	if self.Width:IsVisible() then draw.DrawText("Width:","Default",190,28,color_white,0) end
	if self.Height:IsVisible() then draw.DrawText("Height:","Default",190,53,color_white,0) end
	if self.CoordX:IsVisible() then draw.DrawText("X:","Default",210,83,color_white,0) end
	if self.CoordY:IsVisible() then draw.DrawText("Y:","Default",210,108,color_white,0) end
end

function PANEL:Think()
	
	self:SetVal("color",self.ColorPicker:GetColor(),true)
	
	if (self.Dragging) then
	
		local x = gui.MouseX() - self.Dragging[1]
		local y = gui.MouseY() - self.Dragging[2]

		// Lock to screen bounds if screenlock is enabled
		//if ( self:GetScreenLock() ) then
		
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
		//end
		
		self:SetPos( x, y )
	
	end
	
	self:OnThink()
end

function PANEL:OnMousePressed()

	self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
	self:MouseCapture( true )
	return

end

function PANEL:SetPanelName( str )
	self.HUDDObject = str
end

function PANEL:GetPanelName() return self.HUDDObject end

vgui.Register("HUDDProperties",PANEL,"DFrame")




/**** HUDDColor - a color selector? ****/
local PANEL = {}

AccessorFunc( PANEL, "m_ConVarR", 				"ConVarR" )
AccessorFunc( PANEL, "m_ConVarG", 				"ConVarG" )
AccessorFunc( PANEL, "m_ConVarB", 				"ConVarB" )
AccessorFunc( PANEL, "m_ConVarA", 				"ConVarA" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Mixer = vgui.Create( "DColorMixer", self )
	
	self.txtR = vgui.Create( "DNumberWang", self )
	self.txtR:SetDecimals( 0 )
	self.txtR:SetMinMax( 0, 255 )
	self.txtG = vgui.Create( "DNumberWang", self )
	self.txtG:SetDecimals( 0 )
	self.txtG:SetMinMax( 0, 255 )
	self.txtB = vgui.Create( "DNumberWang", self )
	self.txtB:SetDecimals( 0 )
	self.txtB:SetMinMax( 0, 255 )
	self.txtA = vgui.Create( "DNumberWang", self )
	self.txtA:SetDecimals( 0 )
	self.txtA:SetMinMax( 0, 255 )
	self.txtA:SetVisible( false )
	
end

/*---------------------------------------------------------
   Name: ConVarR
---------------------------------------------------------*/
function PANEL:SetConVarR( cvar )
	self.Mixer:SetConVarR( cvar )
	self.txtR:SetConVar( cvar )
end

/*---------------------------------------------------------
   Name: ConVarG
---------------------------------------------------------*/
function PANEL:SetConVarG( cvar )
	self.Mixer:SetConVarG( cvar )
	self.txtG:SetConVar( cvar )
end

/*---------------------------------------------------------
   Name: ConVarB
---------------------------------------------------------*/
function PANEL:SetConVarB( cvar )
	self.Mixer:SetConVarB( cvar )
	self.txtB:SetConVar( cvar )
end

/*---------------------------------------------------------
   Name: ConVarA
---------------------------------------------------------*/
function PANEL:SetConVarA( cvar )

	if ( cvar ) then self.txtA:SetVisible( true ) end
	self.Mixer:SetConVarA( cvar )
	self.txtA:SetConVar( cvar )
	
end

//function PANEL:RefreshText()
//	self.txtR:SetValue

function PANEL:GetColor()
	return self.Mixer:GetColor()
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local y =  0 //self.Label1:GetTall() + 5

	self:SetTall( 110 )
	
	self.Mixer:SetSize( 150, 100 )
	self.Mixer:Center()
	self.Mixer:AlignLeft( 5 )
	
	self.txtR:SizeToContents()
	self.txtG:SizeToContents()
	self.txtB:SizeToContents()
	self.txtA:SizeToContents()
	
	self.txtR:AlignRight( 5 )
	self.txtR:AlignTop( 5 )
		self.txtG:CopyBounds( self.txtR )
		self.txtG:CenterVertical( 0.375 )
			self.txtB:CopyBounds( self.txtG )
			self.txtB:CenterVertical( 0.625 )
				self.txtA:CopyBounds( self.txtB )
				self.txtA:AlignBottom( 5 )

end

vgui.Register( "HUDDColor", PANEL, "DPanel" )




local PANEL = {}
function PANEL:Init()
	self.Question = "Question?"
	self.HelpText = ""
	self:SetSize( 500, 200 )
	self:SetTitle("")
	self:Center()
	self:MakePopup()
	
	self.Query = vgui.Create("DTextEntry", self)
	self.Query:SetPos(  10, self:GetTall() - 30 )
	self.Query:SetSize( self:GetWide() - 20, 20 )
	self.Query:SetEditable( true )
	self.Query:SetValue("Press enter to submit")
	self.Query.Init = false
	self.Query.OnGetFocus = function()
		if not self.Query.Init then
			self.Query.Init = true
			self.Query:SetValue("")
		end
	end
	self.Query.OnEnter = function()
		self:OnSubmit( self.Query:GetValue() )
		self:Close()
	end
end
function PANEL:SetQuestion( str ) self.Question = str end
function PANEL:GetQuestion() return self.Question end
function PANEL:SetHelpText( str ) self.HelpText = str end
function PANEL:GetHelpText() return self.HelpText end
function PANEL:OnSubmit( str ) end

function PANEL:Paint()
	draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,220))
	draw.DrawText("Query - "..self.Question,"ScoreboardText",10,3,color_white,0)
	draw.DrawText( self.HelpText, "Default", 15, 35, color_white, 0 )
end

vgui.Register("HUDDQuery",PANEL,"DFrame")