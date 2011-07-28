if SERVER then

		
end

if CLIENT then
	
	/* Created by Entoros, 2010
	Bugs:
		Alpha doesn't work on color mixer! [use CtrlColor?]
		You can't set the color of the color mixer via Lua
		Color mixer messes up sometimes [colors go wacko]
	Ideas:
		ZPos - send elements to front/back
		Make the menu work for smaller resolutions
	References:
		See hud_plugins/sample_plugin.lua on how to make a plugin
		See client/hudd_frame.lua for how to use the HUDDFrame
		See client/hudd_controls for how to use the other HUDD derma controls
	*/
	
	HUDD = {}
	HUDD.HasInit = false
	HUDD.Plugins = {}
	HUDD.Menu =  {}
	HUDD.MenuSize = { x = 500, y = 150 }
	//HUDD.MenuSize = { x = ScrW() / 2.5, y = ScrH() / 6 }
	
	function HUDD:Initialize()
		self.HasInit = true
		
		print("////////////// HUDD INITIALIZING //////////////")
		
		local bPluginsLoaded = self:LoadPlugins()
		print( (bPluginsLoaded && "///// PLUGINS Loaded" || "///// PLUGINS Failed!"))
		
		concommand.Add("hudd_menu",function() self:CreateMenu() end)
		
		print("////////////// HUDD INITIALIZED //////////////")
	end
	
	function HUDD:LoadPlugins()
		if not self.HasInit then return false end
		
		local luaFiles =  file.FindInLua("autorun/hud_plugins/*.lua")
		if not luaFiles[1] then return false end
		for _,v in pairs(luaFiles) do
			include( "hud_plugins/"..v)
		end
		return true
	end
	
	function HUDD:RegisterPlugin( plugin )
		if not self.HasInit then return false end
		
		table.insert(self.Plugins,plugin)
	end
	
	function HUDD:CreateMenu()
		self.Menu.Frame = vgui.Create("DFrame")
		self.Menu.Frame:SetSize(self.MenuSize.x,self.MenuSize.y)
		self.Menu.Frame:SetPos( ScrW() - self.Menu.Frame:GetWide() - 30,30)
		self.Menu.Frame:SetTitle("")
		self.Menu.Frame:ShowCloseButton(false)
		self.Menu.Frame:MakePopup()
		function self.Menu.Frame:Paint()
			draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,220))
			draw.DrawText("HUD Designer","ScoreboardText",10,3,color_white,0)
			draw.DrawText("Relative?","Default",350,5,color_white,0)
		end
		self.Menu.Frame.Close = vgui.Create( "DSysButton", self.Menu.Frame )
		self.Menu.Frame.Close:SetPos( self.Menu.Frame:GetWide() - 25,0)
		self.Menu.Frame.Close:SetSize(25,25)
		self.Menu.Frame.Close:SetType( "close" )
		self.Menu.Frame.Close.DoClick = function()
			self:OnClose()
			self.Menu.Frame:Remove()
		end
		self.Menu.Frame.Close:SetDrawBorder( false )
		self.Menu.Frame.Close:SetDrawBackground( false )
		
		self.Menu.List = vgui.Create("DPanelList",self.Menu.Frame)
		self.Menu.List:SetPos(10,25)
		self.Menu.List:SetSize( self.Menu.Frame:GetWide() - 20, self.Menu.Frame:GetTall() - 35 )
		self.Menu.List:EnableHorizontal( true )
		self.Menu.List:EnableVerticalScrollbar( true )
		self.Menu.List:SetPadding( 5 )
		self:PopulateList()
		
		self.Menu.btnClear = vgui.Create("DButton",self.Menu.Frame)
		self.Menu.btnClear:SetPos(110,5)
		self.Menu.btnClear:SetSize(110,15)
		self.Menu.btnClear:SetText("Clear All Elements")
		self.Menu.btnClear.DoClick = function()
			self:RemoveElements()
		end
		
		self.Menu.btnCode = vgui.Create("DButton",self.Menu.Frame)
		self.Menu.btnCode:SetPos(230,5)
		self.Menu.btnCode:SetSize(110,15)
		self.Menu.btnCode:SetText("Print Code")
		self.Menu.btnCode.DoClick = function()
			print("///// GENERATING CODE /////")
			for _,v in pairs(self.Plugins) do
				print(v:GenerateCode())
			end
			print("///// CODE GENERATED /////")
		end
		
		self.Menu.chbRel = vgui.Create("DCheckBox",self.Menu.Frame)
		self.Menu.chbRel:SetPos(400,5)
		self.Menu.chbRel:SetSize(15,15)
		self.Menu.chbRel:SetValue(true)
	end
	
	function HUDD:SizeRelative()
		if not self.Menu.chbRel then return end
		return self.Menu.chbRel:GetChecked()
	end
	
	function HUDD:GetRelativeSize(x,y)
		x = x / ScrW()
		y = y / ScrW()
		return x,y
	end
	
	function HUDD:InverseColor( col, a )
		a = a or 255
		return Color( 255 - col.r, 255 - col.g, 255 - col.b, a )
	end
	
	function HUDD:PopulateList()
		if not IsValid( self.Menu.List ) then return end
		self.Menu.Buttons = {}
		for _,v in pairs( self.Plugins ) do
			local pan = vgui.Create("DPanel")
			pan:SetSize( self.Menu.List:GetWide() / 5, self.Menu.List:GetTall() - 10 )
			pan.Paint = function()
				draw.DrawText( v.PrintName, "Default", pan:GetWide() / 2, 0, color_white, 1 )
			end
			
			local btn = vgui.Create("DImageButton",pan)
			local tex = ( string.Trim(v.Texture) != "" && v.Texture || "vgui/swepicon" )
			btn:SetImage( tex )
			btn:SetPos( 5,15 )
			btn:SetSize( pan:GetWide() - 10, pan:GetTall() - 10 )
			btn.DoClick = function()
				v:OnClick()
			end
			self.Menu.Buttons[v.PrintName] = btn
			
			self.Menu.List:AddItem(pan)
		end
	end
	
	function HUDD:RemoveElements()
		for _,plugin in pairs( self.Plugins ) do
			for _,pan in pairs( table.Add(plugin.Elements,plugin.Windows) ) do
				if string.lower(type(pan)) == "panel" then pan:Remove() end
			end
		end
	end
	
	function HUDD:OnClose()
		self:RemoveElements()
		// print hud and/or save code
	end
	
	HUDD:Initialize()
	
end