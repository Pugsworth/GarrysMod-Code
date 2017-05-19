local PANEL = vgui.Register("lua_editor", {}, "Panel")

AccessorFunc(PANEL,"m_bReady","Ready",FORCE_BOOL)
AccessorFunc(PANEL,"m_bSaving","Saving",FORCE_BOOL)

PANEL.Themes = {"default","neat","night","elegant", "grey"}
function PANEL:Init()
	self.Content = ""
	self.filename = "lua_editor_save.txt"
	self.m_bSaving = true
	self.Error = vgui.Create( "DLabel", self )		
	self.Error:SetTextColor( Color( 199, 80, 77 ) )
	self.Error:SetFont("UIBold")
	self.Error:Dock( BOTTOM )
	self.Error:DockMargin(6,3,3,3)
	self.Error:SetVisible( false )
	
	self:SetCookieName("lua_editor")
	local theme = self:GetCookie("theme")
	self.theme = theme and theme!="" and theme or "default"
	
	-- TODO: How to remove if the panel gets removed?
	hook.Add( "ShutDown", self,function()
		if not ValidPanel(self) or not self.HTML then return end
		self:Save()
	end )
		
end
function PANEL:InitRest()
	
	self.HTML = vgui.Create( "HTML", self )
	self.HTML:OpenURL("http://matt-zone.com/leditor/index.html")
	self.HTML:Dock( FILL )

	self.HTML.OnKeyCodePressed = function()
		self.HTML:RunJavascript("GetContent()")
	end

	self.HTML.PageTitleChanged = function(HTML, title)
		if not self:GetReady() then
			self:OnReady()
			return
		end
		if title and title ~= self.LastTitle then
			local decoded = ""

			local i = 1

			while i < #title do
				decoded = decoded .. string.char(tonumber(title:sub(i,i+1), 16))
				i = i + 2
			end
		
			local var = CompileString(decoded, "lua_editor", false)
			if type(var) == "string" then
				self:SetError(var)
			else
				self:SetError(false)
			end
			
			timer.Create('save'..tostring(self.filename),2,1,function() 
				self:Save()
			end)
			
			self.LastTitle = title
			self.Content = decoded
			self:OnCodeChanged(decoded)
		end
	end
	self:InvalidateLayout()
	self:TellParentAboutSizeChanges()
	self.HTML:InvalidateLayout()
	self.HTML:TellParentAboutSizeChanges()
end
function PANEL:Paint() -- hacky delayed loading..
	if self.__loaded then return end
	self.__loaded = true
	self.Paint=nil
	self:InitRest()
end

function PANEL:Think()
	if not self.HTML then return end
	if input.IsKeyDown(KEY_TAB) then
		gui.InternalCursorMoved(self.HTML:LocalToScreen(self.HTML:GetWide()*0.5, self.HTML:GetTall()*0.5))
		gui.InternalMousePressed(MOUSE_RIGHT)
	end
end

function PANEL:OnCodeChanged(code)

end

function PANEL:GetCode()
	return self.Content
end

function PANEL:SetCode(content)
	if not self:GetReady() then
		self.__delayed_code = content
	end
	
	local encoded = ""
   
	for i=1, #content do
		encoded = encoded .. ("%02X"):format(content[i]:byte())
	end
   
	self.Content = content    
	if not self.HTML then return end	
	self.HTML:RunJavascript("SetContent(\"" .. encoded .. "\")")

	
end

function PANEL:OnReady()

	self:SetReady(true)
	if self.__delayed_code then
		self:SetCode(self.__delayed_code)
	else
		self:Load()
	end
	
	self:SetTheme( self.theme )
	
	self:InvalidateLayout()
	self:TellParentAboutSizeChanges()
	self.HTML:InvalidateLayout()
	self.HTML:TellParentAboutSizeChanges()
end

function PANEL:SetTheme( theme )
	if table.HasValue(self.Themes,theme) then
		self.theme = theme
		self:SetCookie("theme",theme)
		if not self:GetReady() then return true end
		if not self.HTML then return false end
		self.HTML:RunJavascript("SetTheme(\"" .. theme .. "\")") -- Add escaping if necessary..
		return true
	end
	return false
end

function PANEL:SetError( err )
	if err then
		if not self.Error:IsVisible() then
			self.Error:SetVisible( true )
			self:InvalidateLayout()
		end
		
		self.Error:SetText( err )
		self.Error:SizeToContents()
	else
		if self.Error:IsVisible() then
			self.Error:SetVisible( false )
			self:InvalidateLayout()
		end
	end
end


function PANEL:Save( )

	if self:GetReady() then
		local code=self:GetCode()
		self:Store( code )
	end
end

function PANEL:Store( code )

	if code and code:len()>0 then
		file.Write(self.filename,code)
		return true
	elseif file.Exists(self.filename) then
		file.Delete(self.filename)
		return false
	end		
	return false
	
end

function PANEL:Load()	

	local data = file.Read(self.filename)
	if data and #data>0 then
		self:SetCode( data )
	end
end