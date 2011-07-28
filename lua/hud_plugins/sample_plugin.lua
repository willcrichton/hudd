////////////////////////////////////////////////
///// SAMPLE PLUGIN - Simple Box
///// Author: Entoros
///// Description: Creates a simple rounded box



////////////////////////////////////////////////
///// REQUIRED ELEMENTS
///// You need to have ALL of these variables WITH THE SAME NAME and the SAME DATA TYPE

local PLUGIN = {}
PLUGIN.PrintName = "Simple Box"			// The name of the plugin that will show up in the selection panel
PLUGIN.Class = "sbox"					// Class name - should be unique, shows up on each element of the class
PLUGIN.Texture = "hudd/simplebox"			// Path to the texture that will show in the selection panel
PLUGIN.Elements = {}					// The sub-elements created from each plugins
PLUGIN.Windows = {}					// Other windows created, like property panels [so we can close out of them]
PLUGIN.Code = ""						// The code to be generated
PLUGIN.IsActive = false					// Whether the plugin is active



////////////////////////////////////////////////
///// PLUGIN:Create()
///// This is what should be called in PLUGIN.OnClick, or just how you make the box in general

function PLUGIN:Create()
	self.IsActive = true										// Make sure you include this, for now

	local box = vgui.Create("HUDDFrame")							// HUDDFrame is an included control - it's basically a DFrame that can resize
	box:SetSize(100,100)
	box:SetPos( ScrW() / 2 - box:GetWide() / 2, ScrH() / 2 - box:GetTall() / 2 )
	box:SetTitle("")
	box:SetSizable(true)
	box.Col = color_white
	box.Prop = nil
	box.ZPos = 0
	box.HUDDName = self.Class.."_"..tostring(#self.Elements)				// For now you have to draw the classname manually, but I"ll probably put that in later
	function box:Paint()
		draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall(),self.Col)
		draw.DrawText(self.HUDDName,"ScoreboardText",5,3,Color(180,180,180,255),0)
	end
	function box:OnResize(x,y)									// See the autorun/client/hudd_controls.lua for more info about the HUDDFrame and 
		if IsValid(self.Prop) then								// HUDDProperties panels
			self.Prop:SetVal("width",x)
			self.Prop:SetVal("height",y)
		end
	end
	function box:OnMove(x,y)
		if IsValid(self.Prop) then
			self.Prop:SetVal("x",x)
			self.Prop:SetVal("y",y)
		end
	end
	function box:OnDoubleClick()
		local frProp = vgui.Create("HUDDProperties")
		frProp:Center()
		frProp:SetDraggable(true)
		frProp:SetVal( "color",self.Col )
		frProp:SetVal( "width", self:GetWide() )
		frProp:SetVal( "height", self:GetTall() )
		local posx,posy = self:GetPos()
		frProp:SetVal( "x", posx )
		frProp:SetVal( "y", posy )
		frProp:SetPanelName( self.HUDDName )
		self.Prop = frProp
		function frProp:OnValChanged(key,val)
			local x,y = box:GetPos()
			if key == "width" then box:SetWide(val)
			elseif key=="height" then box:SetTall(val)
			elseif key=="color" then box.Col = val
			elseif key=="x" then box:SetPos(val,y) 
			elseif key=="y" then box:SetPos(x,val)
			end
		end
		table.insert(PLUGIN.Windows,frProp)
	end
		
	function box:OnClose()
		if IsValid(self.Prop) then self.Prop:Remove() end
		// Should we reset the numbering in case or just let it keep going?
		for k,v in pairs(PLUGIN.Elements) do								// PLEASE make sure you remove the element and its property window on close
			if v == self then table.remove(PLUGIN.Elements,k) end
		end
	end
	
	table.insert(self.Elements,box)										// DO NOT forget to insert the created element in to the plugin table
end



////////////////////////////////////////////////
///// PLUGIN:GenerateCode()
///// This is how we actually create the HUDs - using patterns or formatting or however the hell you want, turn the existing elements into a string of Lua code

function PLUGIN:GenerateCode()
	if not IsValid( self.Elements[1] ) then return "" end
	self.Code = ""
	for _,v in pairs(self.Elements) do
		if IsValid( v ) then
			local str = "draw.RoundedBox( 0, %s, %s, %s, %s, %s )"
			local x,y = v:GetPos()
			local w,h = v:GetSize()
			local col = "Color( " .. tostring( v.Col.r ) .. ", " .. tostring( v.Col.g ) .. ", " .. tostring( v.Col.b ) .. ", " .. tostring( v.Col.a ) .. " )"
			if HUDD:SizeRelative() then									// HUDD supports relative sizes - make sure you do something like this
				x,y = HUDD:GetRelativeSize(x,y)
				w,h = HUDD:GetRelativeSize(w,h)
				x = tostring(x) .. " * ScrW()"
				y = tostring(y) .. " * ScrH()"
				w = tostring(w) .. " * ScrW()"
				h = tostring(h) .. " * ScrH()"
			end
			str = string.format( str, x, y, w, h, col )
			self.Code = self.Code .. str .. "\n"
		end
	end
	self.Code = string.Trim(self.Code)
	return self.Code
end



////////////////////////////////////////////////
///// PLUGIN:OnClick()
///// This gets called whenever the user clicks on your icon in the selection panel - generally you just create the element, but if you refer to image.lua/ptext.lua
///// you can see the other ways you can do it (get a query and pass its value to the element you're creating, for example)

function PLUGIN:OnClick()
	self:Create()
end



HUDD:RegisterPlugin(PLUGIN)											// DO NOT NOT NOT forget to register your plugin, as such