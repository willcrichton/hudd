local PLUGIN = {}

PLUGIN.PrintName = "Player Text"
PLUGIN.Class = "ptext"
PLUGIN.Texture = "hudd/text"
PLUGIN.Elements = {}
PLUGIN.Windows = {}
PLUGIN.Code = ""
PLUGIN.IsActive = false

PLUGIN.TextTypes = {
	["Health"] = function() return LocalPlayer():Health(), "LocalPlayer():Health()" end,
	["Armor"] = function() return LocalPlayer():Armor(), "LocalPlayer():Armor()" end,
	["Ping"] = function() return LocalPlayer():Ping(), "LocalPlayer():Ping()" end,
	["Name"] = function() return LocalPlayer():Name(), "LocalPlayer():Name()" end,
	["Frags"] = function() return LocalPlayer():Frags(), "LocalPlayer():Frags()" end,
	["Deaths"] = function() return LocalPlayer():Deaths(), "LocalPlayer():Deaths()" end,
}

function PLUGIN:Create( texttype )
	self.IsActive = true
	
	local box = vgui.Create("HUDDFrame")
	box:SetSize(200,40)
	box:SetPos( ScrW() / 2 - box:GetWide() / 2, ScrH() / 2 - box:GetTall() / 2 )
	box:SetTitle("")
	box:SetSizable(false)
	box.Col = Color(255,255,255,100)
	box.Prop = nil
	box.HUDDName = self.Class.."_"..tostring(#self.Elements)
	box.TextType = texttype
	box.DrawFunc = self.TextTypes[box.TextType]
	function box:Paint()
		surface.SetFont("ScoreboardText")
		local w,h = surface.GetTextSize(self.DrawFunc())
		self:SetSize(w + 20,h + 20)
		local col = self.Col
		col.a = 100
		draw.RoundedBox(0,0,0,self:GetWide(),self:GetTall() / 2, col )
		draw.RoundedBox(0,0,self:GetTall() /2,self:GetWide(),self:GetTall(),HUDD:InverseColor( self.Col, 100 ))
		draw.DrawText(self.HUDDName,"ScoreboardText",5,1,HUDD:InverseColor( self.Col ),0)
		col.a = 255
		draw.DrawText( self.DrawFunc(), "ScoreboardText", self:GetWide() / 2, self:GetTall()/2,col,1)
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
		frProp.Width:SetVisible( false )
		frProp.Height:SetVisible( false )
		local posx,posy = self:GetPos()
		frProp:SetVal( "x", posx )
		frProp:SetVal( "y", posy )
		frProp:SetPanelName( self.HUDDName )
		self.Prop = frProp
		function frProp:OnValChanged(key,val)
			local x,y = box:GetPos()
			if key=="color" then box.Col = val
			elseif key=="x" then box:SetPos(val,y) 
			elseif key=="y" then box:SetPos(x,val)
			end
		end
		table.insert(PLUGIN.Windows,frProp)
	end
	function box:OnClose()
		if IsValid(self.Prop) then self.Prop:Remove() end
		// Should we reset the numbering in case or just let it keep going?
		for k,v in pairs(PLUGIN.Elements) do
			if v == self then table.remove(PLUGIN.Elements,k) end
		end
	end
	
	table.insert(self.Elements,box)
end

function PLUGIN:GenerateCode()
	if not IsValid( self.Elements[1] ) then return "" end
	self.Code = ""
	for _,v in pairs(self.Elements) do
		if IsValid( v ) then
			local func,f_str = self.TextTypes[v.TextType]()
			local str = "draw.DrawText( %s, \"ScoreboardText\", %s, %s, %s, 1 )"
			local x,y = v:GetPos()
			local col = "Color( " .. tostring( v.Col.r ) .. ", " .. tostring( v.Col.g ) .. ", " .. tostring( v.Col.b ) .. ", " .. tostring( v.Col.a ) .. " )"
			if HUDD:SizeRelative() then
				x,y = HUDD:GetRelativeSize(x,y)
				x = tostring(x) .. " * ScrW()"
				y = tostring(y) .. " * ScrH()"
			end
			str = string.format( str, f_str, x, y, col )
			self.Code = self.Code .. str .. "\n"
		end
	end
	self.Code = string.Trim(self.Code)
	return self.Code
end

function PLUGIN:OnClick()
	local menu = DermaMenu()
	for k,v in pairs(self.TextTypes) do
		menu:AddOption(k,function() 
			self:Create( k )
		end)
	end
	menu:Open()

end

HUDD:RegisterPlugin(PLUGIN)