local PLUGIN = {}

PLUGIN.PrintName = "Image Box"
PLUGIN.Class = "ibox"
PLUGIN.Texture = "hudd/textures"
PLUGIN.Elements = {}
PLUGIN.Windows = {}
PLUGIN.Code = ""
PLUGIN.IsActive = false

function PLUGIN:Create( tex )
	
	self.IsActive = true

	local box = vgui.Create("HUDDFrame")
	box:SetSize(100,100)
	box:SetPos( ScrW() / 2 - box:GetWide() / 2, ScrH() / 2 - box:GetTall() / 2 )
	box:SetTitle("")
	box:SetSizable(true)
	box.Col = color_white
	box.Texture = tex
	box.Prop = nil
	box.ZPos = 0
	box.HUDDName = self.Class.."_"..tostring(#self.Elements)
	function box:Paint()
		draw.TexturedQuad({
			texture = surface.GetTextureID( self.Texture ),
			color = self.Col,
			x = 0,
			y = 0,
			w = self:GetWide(),
			h = self:GetTall(),
			})
		draw.DrawText(self.HUDDName,"ScoreboardText",5,3,Color(180,180,180,255),0)
	end
	function box:OnResize(x,y)
		if IsValid(self.Prop) then
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
			elseif key=="texture" then box.Texture = val
			end
		end
		
		frProp.MatSelect = vgui.Create("DTextEntry",frProp)
		frProp.MatSelect:SetPos( 60, frProp:GetTall() + 5 )
		frProp.MatSelect:SetSize( frProp:GetWide() - 70, 20 )
		frProp.MatSelect.OnEnter = function()
			frProp:SetVal( "texture", frProp.MatSelect:GetValue(), true )
			frProp:Close()
		end
		function frProp:PaintOver()
			draw.DrawText("Texture:","Default",10,frProp:GetTall() - 27,color_white,0)
		end
		frProp:SetSize( frProp:GetWide(), frProp:GetTall() + 35 )
		
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
			local str = "draw.TexturedQuad({ 0, texture=surface.GetTextureID(\"%s\"), color=%s, x=%s, y=%s, w=%s, h=%s })"
			local x,y = v:GetPos()
			local w,h = v:GetSize()
			local col = "Color( " .. tostring( v.Col.r ) .. ", " .. tostring( v.Col.g ) .. ", " .. tostring( v.Col.b ) .. ", " .. tostring( v.Col.a ) .. " )"
			if HUDD:SizeRelative() then
				x,y = HUDD:GetRelativeSize(x,y)
				w,h = HUDD:GetRelativeSize(w,h)
				x = tostring(x) .. " * ScrW()"
				y = tostring(y) .. " * ScrH()"
				w = tostring(w) .. " * ScrW()"
				h = tostring(h) .. " * ScrH()"
			end
			str = string.format( str, v.Texture, col, x, y, w, h )
			self.Code = self.Code .. str .. "\n"
		end
	end
	self.Code = string.Trim(self.Code):gsub("\n","")
	return self.Code
end

function PLUGIN:OnClick()
	local query = vgui.Create("HUDDQuery")
	query:SetQuestion("Enter the texture")
	query:SetHelpText("Make sure you include the path relative to the materials directory")
	
	query.OnSubmit = function( pan, str )
		self:Create( str )
	end
end

HUDD:RegisterPlugin(PLUGIN)
