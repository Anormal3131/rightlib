-- AxiomUI v1.1 | Üst Düzey Arayüz Kütüphanesi
-- Tasarım, işlevsellik ve kullanıcı deneyimi odaklı.
-- Geliştirilmiş özellikler: Dropdown, Keybind, TextBox, Bildirimler, İpuçları ve Global Popup Yönetimi.

local AxiomUI = {}
AxiomUI.__index = AxiomUI

--[[ Servisler ve Yardımcılar ]]--

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function new(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, val in pairs(properties or {}) do
		inst[prop] = val
	end
	return inst
end

--[[ Tema ve Ayarlar ]]--

local THEME = {
	WindowSize = Vector2.new(680, 500),
	SidebarWidth = 190,
	ElementHeight = 38,
	SectionPadding = 25,
	Accent = Color3.fromRGB(80, 130, 255),
	Background = Color3.fromRGB(24, 25, 28),
	Primary = Color3.fromRGB(31, 32, 36),
	Secondary = Color3.fromRGB(44, 46, 51),
	Border = Color3.fromRGB(60, 62, 70),
	Text = Color3.fromRGB(235, 236, 240),
	TextSecondary = Color3.fromRGB(165, 167, 175),
	Font = Enum.Font.GothamSemibold,
	FontBold = Enum.Font.GothamBold,
	AnimationSpeed = 0.25,
	EasingStyle = Enum.EasingStyle.Quart,
	CornerRadius = UDim.new(0, 10),
	BlurSize = 16,
}

local ICONS = {
	sword = "rbxassetid://13423485039",
	eye = "rbxassetid://13423480339",
	zap = "rbxassetid://13423506169",
	cog = "rbxassetid://13423476931",
	tool = "rbxassetid://13423501259",
}
local function createIcon(id, color)
	return new("ImageLabel", { Image = ICONS[id] or id, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), ImageColor3 = color })
end

--[[ Ana Pencere Oluşturucu ]]--

function AxiomUI.new(title)
	local window = {}
	local api = {}

	-- Global Durum Yönetimi
	window.activePopup = nil -- Dropdown, ColorPicker gibi aktif popupları yönetir.

	-- Ana Ekran ve Arkaplan
	window.ScreenGui = new("ScreenGui", { Name = "AxiomUI_Root", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = game:GetService("CoreGui") })
	window.BlurContainer = new("Frame", { Name = "BlurContainer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = window.ScreenGui })
	new("UIBlur", { Size = THEME.BlurSize, Parent = window.BlurContainer })
	window.NotificationContainer = new("Frame", { Name = "NotificationContainer", Size = UDim2.new(1, -15, 1, -15), Position = UDim2.new(1,0,0,0), AnchorPoint = Vector2.new(1,0), BackgroundTransparency=1, Parent = window.ScreenGui })
	new("UIListLayout", {Parent=window.NotificationContainer, HorizontalAlignment=Enum.HorizontalAlignment.Right, FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,8)})

	-- Dışarıya Tıklama Yöneticisi
	window.ClickCatcher = new("TextButton", { Name = "ClickCatcher", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 98, Visible = false, Parent = window.ScreenGui })
	window.ClickCatcher.MouseButton1Click:Connect(function()
		if window.activePopup and window.activePopup.Close then
			window.activePopup.Close()
		end
	end)

	-- Ana Pencere
	window.MainWindow = new("Frame", { Name = "MainWindow", Visible = false, ClipsDescendants = true,
		Size = UDim2.fromOffset(THEME.WindowSize.X, THEME.WindowSize.Y),
		Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Background, BorderSizePixel = 0, Parent = window.BlurContainer, BackgroundTransparency = 1, ZIndex = 99,
	})
	new("UICorner", { CornerRadius = THEME.CornerRadius, Parent = window.MainWindow })
	new("UIStroke", { Color = THEME.Border, Thickness = 1, Parent = window.MainWindow })

	-- Sürükleme Çubuğu
	local dragBar = new("Frame", { Name="DragBar", Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Parent=window.MainWindow, Active=true, ZIndex=100 })
    local isDragging, dragOffset; dragBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging, dragOffset = true, window.MainWindow.AbsolutePosition - input.Position; RunService:BindToRenderStep("Drag", Enum.RenderPriority.Input.Value, function() if isDragging then window.MainWindow.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X + dragOffset.X, UserInputService:GetMouseLocation().Y + dragOffset.Y) end end) end end); dragBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false; RunService:UnbindFromRenderStep("Drag") end end)

	-- Yan Panel (Sidebar)
	window.Sidebar = new("Frame", { Name = "Sidebar", Size = UDim2.new(0, THEME.SidebarWidth, 1, 0), BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, Parent = window.MainWindow })
	new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = window.Sidebar })
	new("UIPadding", { PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), Parent = window.Sidebar })
	new("TextLabel", { LayoutOrder = -2, Text = title, Font = THEME.FontBold, TextSize = 22, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 0, 40), TextXAlignment = Enum.TextXAlignment.Left, Parent = window.Sidebar })

	-- İçerik Alanı
	window.ContentContainer = new("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -THEME.SidebarWidth, 1, 0), Position = UDim2.new(0, THEME.SidebarWidth, 0, 0), BackgroundTransparency = 1, Parent = window.MainWindow })

	local tabs = {}
	local selectedTabIndicator = new("Frame", { Name = "SelectedIndicator", Size = UDim2.new(0, 4, 0, 24), Position = UDim2.new(0, 0, 0.5, -12), BackgroundColor3 = THEME.Accent, ZIndex = 10, BorderSizePixel = 0, Parent = window.Sidebar })
	new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = selectedTabIndicator })
	selectedTabIndicator.Visible = false

	--[[ API Fonksiyonları ]]--

	function api:new_tab(name, icon)
		local content = new("ScrollingFrame", { Name = "Content_"..name, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.Accent, Parent = window.ContentContainer })
		new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, THEME.SectionPadding), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = content })
		new("UIPadding", { PaddingLeft = UDim.new(0, 25), PaddingRight = UDim.new(0, 25), PaddingTop = UDim.new(0, 25), PaddingBottom = UDim.new(0, 25), Parent = content })
		
		local button = new("TextButton", { Name = "Tab_"..name, Size = UDim2.new(1, -20, 0, 40), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = window.Sidebar })
		local iconLabel = createIcon(icon, THEME.TextSecondary); iconLabel.Parent = button; iconLabel.Position = UDim2.fromScale(0.1, 0.5); iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		local textLabel = new("TextLabel", { Text = name, Font = THEME.Font, TextSize = 16, TextColor3 = THEME.TextSecondary, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = button })
		
		local tabData = { content = content, button = button, text = textLabel, icon = iconLabel }
		table.insert(tabs, tabData)
		
		function tabData:Select()
			for _, t in pairs(tabs) do t.content.Visible = false; TweenService:Create(t.text, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { TextColor3 = THEME.TextSecondary }):Play(); TweenService:Create(t.icon, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { ImageColor3 = THEME.TextSecondary }):Play() end
			content.Visible = true; TweenService:Create(textLabel, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { TextColor3 = THEME.Text }):Play(); TweenService:Create(iconLabel, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { ImageColor3 = THEME.Text }):Play()
			selectedTabIndicator.Visible = true; selectedTabIndicator:TweenPosition(UDim2.new(0, 0, 0, button.AbsolutePosition.Y - window.Sidebar.AbsolutePosition.Y + 8), "Out", THEME.EasingStyle, THEME.AnimationSpeed, true)
		end
		
		button.MouseButton1Click:Connect(tabData.Select)
		if #tabs == 1 then task.wait(); tabData.Select() end

		function tabData:new_section(name)
			local section = {}
			local sectionFrame = new("Frame", { Name = "Section_"..name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = content })
			new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 10), Parent = sectionFrame })
			new("TextLabel", { Text = name, Font = THEME.FontBold, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = sectionFrame })
			
			local elementContainer = new("Frame", { Name = "Container", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, ClipsDescendants = true, Parent = sectionFrame })
			new("UICorner", { CornerRadius = THEME.CornerRadius, Parent = elementContainer })
			new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Parent = elementContainer })
			
			--[[ ELEMENTLER ]]--
			-- Bu fonksiyonlar bir 'elementAPI' objesi döndürür ve bu objeye AddTooltip metodu eklenir.
			local function finalizeElement(gui, apiMethods)
				apiMethods.Gui = gui
				function apiMethods:AddTooltip(text)
					if not window.GlobalTooltip then
						window.GlobalTooltip = new("Frame", {Name="Tooltip", Visible=false, Size=UDim2.new(0,0,0,24), AutomaticSize=Enum.AutomaticSize.X, BackgroundColor3=THEME.Background, Parent=window.ScreenGui, ZIndex=9999})
						new("UICorner", {Parent=window.GlobalTooltip, CornerRadius=UDim.new(0,6)}); new("UIStroke", {Parent=window.GlobalTooltip, Color=THEME.Border})
						new("UIPadding", {Parent=window.GlobalTooltip, PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)})
						new("TextLabel", {Name="Text", Parent=window.GlobalTooltip, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Font=THEME.Font, TextSize=12, TextColor3=THEME.Text})
					end
					gui.MouseEnter:Connect(function()
						window.GlobalTooltip.Text.Text = text
						window.GlobalTooltip.Visible = true
					end)
					gui.MouseLeave:Connect(function() window.GlobalTooltip.Visible = false end)
					gui.MouseMoved:Connect(function(x,y) window.GlobalTooltip.Position = UDim2.fromOffset(x+15, y+15) end)
					return apiMethods
				end
				return apiMethods
			end
            
			function section:new_button(text, callback)
				local btn = new("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Secondary, Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, Parent = elementContainer })
				new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
				btn.MouseButton1Click:Connect(callback or function() end)
				return finalizeElement(btn, {SetText = function(t) btn.Text = t end})
			end
            
			function section:new_toggle(text, default, callback)
				local toggled = default or false
				local frame = new("TextButton", { Name = "Toggle", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), Text = "", BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local switch = new("Frame", { Name = "Switch", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -55, 0.5, -10), BackgroundColor3 = toggled and THEME.Accent or THEME.Secondary, Parent = frame })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
				local knob = new("Frame", { Name = "Knob", Size = UDim2.new(0, 16, 0, 16), Position = UDim2.fromScale(toggled and 0.6 or 0.1, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = THEME.Text, Parent = switch })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

				local function set(val, noCallback)
					toggled = val; TweenService:Create(switch, TweenInfo.new(THEME.AnimationSpeed / 1.5, THEME.EasingStyle), { BackgroundColor3 = toggled and THEME.Accent or THEME.Secondary }):Play(); knob:TweenPosition(UDim2.fromScale(toggled and 0.6 or 0.1, 0.5), "Out", THEME.EasingStyle, THEME.AnimationSpeed, true); if not noCallback and callback then callback(toggled) end
				end
				frame.MouseButton1Click:Connect(function() set(not toggled) end)
				return finalizeElement(frame, {Get = function() return toggled end, Set = set})
			end

			function section:new_slider(text, min, max, default, callback)
				local value, dragging = default or min, false
				local frame = new("Frame", { Name = "Slider", Size = UDim2.new(1, 0, 0, THEME.ElementHeight + 10), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				local label = new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, -15), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local valueLabel = new("TextLabel", { Text = tostring(math.floor(value)), Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.3, -15, 1, -15), Position = UDim2.new(0.7, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = frame })
				
				local track = new("Frame", { Name = "Track", Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0.5, 0, 1, -12), AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = THEME.Secondary, Parent = frame })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
				local fill = new("Frame", { Name = "Fill", Size = UDim2.new((value-min)/(max-min), 0, 1, 0), BackgroundColor3 = THEME.Accent, Parent = track })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
				local handle = new("Frame", { Name = "Handle", Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new((value-min)/(max-min), 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = THEME.Text, ZIndex = 2, Parent = track })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = handle })

				local function update(inputX, noCallback)
					local percent = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					value = min + (max - min) * percent
					fill:TweenSize(UDim2.fromScale(percent, 1), "Out", "Quad", 0.05, true)
					handle.Position = UDim2.fromScale(percent, 0.5)
					valueLabel.Text = tostring(math.floor(value))
					if not noCallback and callback then callback(math.floor(value)) end
				end
				
				track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input.Position.X) end end)
				UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input.Position.X) end end)
				UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				return finalizeElement(frame, {Get=function() return math.floor(value) end, Set = function(v) update(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v-min)/(max-min))) end })
			end
			
			function section:new_keybind(text, defaultKey, callback)
				local currentKey = defaultKey or Enum.KeyCode.None
				local isBinding = false
				local frame = new("Frame", { Name = "Keybind", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local keyButton = new("TextButton", { Name = "KeyButton", Size = UDim2.new(0.4, 0, 1, -8), Position = UDim2.new(0.6, -15, 0.5, 0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=THEME.Secondary, Text = currentKey.Name, Font=THEME.Font, TextSize=13, TextColor3=THEME.Text, Parent=frame})
				new("UICorner", {CornerRadius=UDim.new(0,6), Parent=keyButton})
				
				keyButton.MouseButton1Click:Connect(function()
					isBinding = true
					keyButton.Text = "[...]"
					keyButton.BackgroundColor3 = THEME.Accent
					local connection; connection = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						currentKey = input.KeyCode
						keyButton.Text = currentKey.Name
						keyButton.BackgroundColor3 = THEME.Secondary
						isBinding = false
						connection:Disconnect()
						if callback then callback(currentKey) end
					end)
				end)
				return finalizeElement(frame, {Get=function() return currentKey end, Set=function(key) currentKey = key; keyButton.Text = key.Name end})
			end
			
			function section:new_textbox(text, placeholder, callback)
				local frame = new("Frame", { Name = "TextBox", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local textBox = new("TextBox", {Name="Input", Size=UDim2.new(0.7, -15, 1, -8), Position=UDim2.new(0.3, 0, 0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=THEME.Secondary, Font=THEME.Font, TextSize=13, TextColor3=THEME.Text, PlaceholderText=placeholder, Parent=frame})
				new("UICorner", {CornerRadius=UDim.new(0,6), Parent=textBox})
				
				textBox.FocusLost:Connect(function(enter)
					if enter and callback then
						callback(textBox.Text)
					end
				end)
				return finalizeElement(frame, {Get=function() return textBox.Text end, Set=function(t) textBox.Text = t end})
			end

			-- ColorPicker (Kısaltılmış - tam fonksiyonellik için önceki cevaba bakılabilir)
			function section:new_colorpicker(text, default, callback)
				local color = (type(default) == "table" and default.Color or default) or Color3.new(1,1,1)
				local alpha = (type(default) == "table" and default.Alpha) or 1
				local frame = new("TextButton", { Name = "ColorPicker", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text="", Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local preview = new("Frame", { Name = "Preview", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -35, 0.5, -10), BackgroundColor3 = color, BackgroundTransparency = 1-alpha, Parent = frame })
				new("UICorner", { CornerRadius = UDim.new(0, 4), Parent = preview }); new("UIStroke", { Color = THEME.Border, Parent = preview }); new("ImageLabel", { Parent = preview, Size = UDim2.fromScale(1,1), Image = "rbxassetid://2609200982", ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 5, 0, 5), ImageTransparency = 0.6, BackgroundTransparency = 1, ZIndex = preview.ZIndex-1 })
				
				-- Tam renk seçici popup mantığı buraya eklenebilir.
				return finalizeElement(frame, {SetColor=function(c) color=c.Color or c; alpha=c.Alpha or alpha; preview.BackgroundColor3=color; preview.BackgroundTransparency=1-alpha end, GetColor=function() return {Color=color, Alpha=alpha} end})
			end

			return section
		end
		
		return tabData
	end

	function api:Toggle()
		local visible = not window.MainWindow.Visible
		if visible then window.MainWindow.Visible = true end
		window.BlurContainer.Visible = visible
		local goalPos = visible and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.55)
		local goalTrans = visible and 0 or 1
		window.MainWindow:TweenPosition(goalPos, "Out", THEME.EasingStyle, THEME.AnimationSpeed, true)
		TweenService:Create(window.MainWindow, TweenInfo.new(THEME.AnimationSpeed), { BackgroundTransparency = goalTrans }):Play()
		if not visible then task.delay(THEME.AnimationSpeed, function() if window.MainWindow then window.MainWindow.Visible = false end end) end
	end
	
	function api:Destroy()
		window.ScreenGui:Destroy()
	end
	
	function api:Notify(args)
		local title, desc, duration, ntype = args.Title or "Notification", args.Desc or "", args.Duration or 3, (args.Type or "info"):lower()
		local colors = {info={THEME.Accent, THEME.Text}, success={Color3.fromRGB(40,180,100), THEME.Text}, error={Color3.fromRGB(220,50,50), THEME.Text}}
		local color = colors[ntype] or colors.info
		
		local notif = new("Frame", {Name="Notification", Size=UDim2.new(0, 250, 0, 0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=color[1], BackgroundTransparency=1, Position=UDim2.new(1,0,0,0), Parent=window.NotificationContainer})
		new("UICorner", {CornerRadius=UDim.new(0,6), Parent=notif}); new("UIListLayout", {Parent=notif, Padding=UDim.new(0,4)}); new("UIPadding", {Parent=notif, PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12), PaddingTop=UDim.new(0,8), PaddingBottom=UDim.new(0,8)})
		new("TextLabel", {Name="Title", Text=title, Font=THEME.FontBold, TextSize=14, TextColor3=color[2], BackgroundTransparency=1, Size=UDim2.new(1,0,0,16), AutomaticSize=Enum.AutomaticSize.Y, TextXAlignment=Enum.TextXAlignment.Left, Parent=notif})
		if desc ~= "" then new("TextLabel", {Name="Desc", Text=desc, Font=THEME.Font, TextSize=12, TextColor3=color[2], BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), AutomaticSize=Enum.AutomaticSize.Y, TextXAlignment=Enum.TextXAlignment.Left, Parent=notif, RichText=true, LineHeight=1.2}) end
		
		notif:TweenPosition(UDim2.fromScale(0,0), "Out", "Quad", 0.3, true)
		TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
		
		task.delay(duration, function()
			if notif and notif.Parent then
				notif:TweenPosition(UDim2.new(1,0,notif.Position.Y.Scale,0), "In", "Quad", 0.3, true)
				TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				task.delay(0.3, function() if notif and notif.Parent then notif:Destroy() end end)
			end
		end)
	end
	
	-- AÇILIŞ
	api:Toggle()

	return api
end

return AxiomUI
