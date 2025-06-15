-- AxiomUI v1.0 | Üst Düzey Arayüz Kütüphanesi
-- Tasarım, işlevsellik ve kullanıcı deneyimi odaklı.

local AxiomUI = {}
AxiomUI.__index = AxiomUI

-- Servisler
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Yardımcı Fonksiyonlar
local function new(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, val in pairs(properties or {}) do
		inst[prop] = val
	end
	return inst
end

local function deepClone(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepClone(v)
        end
        copy[k] = v
    end
    return setmetatable(copy, getmetatable(original))
end

-- TEMA: Kütüphanenin tüm görünümünü buradan yönetin!
local THEME = {
	-- Boyutlar
	WindowSize = Vector2.new(650, 480),
	SidebarWidth = 180,
	ElementHeight = 36,
	SectionPadding = 25,
	-- Renkler
	Accent = Color3.fromRGB(90, 135, 255),
	Background = Color3.fromRGB(25, 26, 30),
	Primary = Color3.fromRGB(32, 33, 38),
	Secondary = Color3.fromRGB(45, 47, 54),
	Border = Color3.fromRGB(60, 62, 70),
	Text = Color3.fromRGB(230, 231, 235),
	TextSecondary = Color3.fromRGB(160, 162, 170),
	-- Fontlar
	Font = Enum.Font.GothamSemibold,
	FontBold = Enum.Font.GothamBold,
	-- Animasyon
	AnimationSpeed = 0.25,
	EasingStyle = Enum.EasingStyle.Quart,
	-- Diğer
	CornerRadius = UDim.new(0, 10),
	BlurSize = 20,
}

-- İKONLAR (Örnek ID'ler - Lucide Icon kütüphanesinden)
-- Kendi ikonlarınızı eklemek için: https://devforum.roblox.com/t/lucide-roblox-a-library-of-1000-icons/2402123
local ICONS = {
	sword = "rbxassetid://13423485039",
	eye = "rbxassetid://13423480339",
	sliders = "rbxassetid://13423497914",
	cog = "rbxassetid://13423476931",
    zap = "rbxassetid://13423506169",
}
local function createIcon(id, color)
	return new("ImageLabel", {
		Image = ICONS[id] or id,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 0, 20),
		ImageColor3 = color,
	})
end

-- Pencere Oluşturucu
function AxiomUI.new(title)
	local self, window = {}, {}
	local activeDropdown, activeColorPicker = nil, nil

	-- Arka Plan Bulanıklığı
	local blurContainer = new("Frame", { Name = "AxiomUI_Container", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = game.CoreGui })
	new("UIBlur", { Size = THEME.BlurSize, Parent = blurContainer })

	-- Ana Pencere
	local mainFrame = new("Frame", { Name = "MainWindow", Visible = false, ClipsDescendants = true,
		Size = UDim2.fromOffset(THEME.WindowSize.X, THEME.WindowSize.Y),
		Position = UDim2.fromScale(0.5, 0.45), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Background, BorderSizePixel = 0, Parent = blurContainer, BackgroundTransparency = 1,
	})
	new("UICorner", { CornerRadius = THEME.CornerRadius, Parent = mainFrame })
	new("UIStroke", { Color = THEME.Border, Thickness = 1, Parent = mainFrame })

	-- Sürükleme Çubuğu
	local dragBar = new("Frame", {Name="DragBar", Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, Parent=mainFrame, Active=true, ZIndex=100})
    local isDragging = false
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; local offset = mainFrame.AbsolutePosition - input.Position; RunService:BindToRenderStep("Drag", Enum.RenderPriority.Input.Value, function() if isDragging then mainFrame.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X + offset.X, UserInputService:GetMouseLocation().Y + offset.Y) end end) end
    end)
    dragBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false; RunService:UnbindFromRenderStep("Drag") end end)

	-- Yan Panel (Sidebar)
	local sidebar = new("Frame", { Name = "Sidebar", Size = UDim2.new(0, THEME.SidebarWidth, 1, 0), BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, Parent = mainFrame })
	local listLayout = new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebar })
	new("UIPadding", { PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), Parent = sidebar })
    
	new("TextLabel", { LayoutOrder = -2, Text = title, Font = THEME.FontBold, TextSize = 22, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 0, 40), TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar })

	-- İçerik Alanı
	local contentContainer = new("Frame", { Name = "ContentContainer", Size = UDim2.new(1, -THEME.SidebarWidth, 1, 0), Position = UDim2.new(0, THEME.SidebarWidth, 0, 0), BackgroundTransparency = 1, Parent = mainFrame })

	local tabs, tabButtons = {}, {}
	local selectedTabIndicator = new("Frame", { Name = "SelectedIndicator", Size = UDim2.new(0, 4, 0, 24), Position = UDim2.new(0, 0, 0.5, -12), BackgroundColor3 = THEME.Accent, ZIndex = 10, BorderSizePixel = 0, Parent = sidebar })
	new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = selectedTabIndicator })
	selectedTabIndicator.Visible = false

	-- SEKMELER
	function window:new_tab(name, icon)
		local content = new("ScrollingFrame", {
			Name = "Content_"..name, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
			BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
			ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.Accent, Parent = contentContainer
		})
		new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, THEME.SectionPadding), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = content })
		new("UIPadding", { PaddingLeft = UDim.new(0, 25), PaddingRight = UDim.new(0, 25), PaddingTop = UDim.new(0, 25), PaddingBottom = UDim.new(0, 25), Parent = content })
		
		local button = new("TextButton", { Name = "Tab_"..name, Size = UDim2.new(1, -20, 0, 40), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = sidebar })
		local iconLabel = createIcon(icon, THEME.TextSecondary)
		iconLabel.Parent = button
		iconLabel.Position = UDim2.fromScale(0.1, 0.5)
		iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		local textLabel = new("TextLabel", { Text = name, Font = THEME.Font, TextSize = 16, TextColor3 = THEME.TextSecondary, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = button })
		
		local tabData = { content = content, button = button, text = textLabel, icon = iconLabel }
		table.insert(tabs, tabData)
		table.insert(tabButtons, button)
		
		local function select()
			for _, t in pairs(tabs) do
				t.content.Visible = false
				TweenService:Create(t.text, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { TextColor3 = THEME.TextSecondary }):Play()
				TweenService:Create(t.icon, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { ImageColor3 = THEME.TextSecondary }):Play()
			end
			content.Visible = true
			TweenService:Create(textLabel, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { TextColor3 = THEME.Text }):Play()
			TweenService:Create(iconLabel, TweenInfo.new(THEME.AnimationSpeed, THEME.EasingStyle), { ImageColor3 = THEME.Text }):Play()
			selectedTabIndicator.Visible = true
			selectedTabIndicator:TweenPosition(UDim2.new(0, 0, 0, button.AbsolutePosition.Y - sidebar.AbsolutePosition.Y + 8), "Out", THEME.EasingStyle, THEME.AnimationSpeed, true)
		end
		
		button.MouseButton1Click:Connect(select)
		if #tabs == 1 then task.wait(); select() end

		-- BÖLÜMLER
		function tabData:new_section(name)
			local section = {}
			local sectionFrame = new("Frame", { Name = "Section_"..name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = content })
			new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 10), Parent = sectionFrame })
			new("TextLabel", { Text = name, Font = THEME.FontBold, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = sectionFrame })
			
			local elementContainer = new("Frame", { Name = "Container", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, ClipsDescendants = true, Parent = sectionFrame })
			new("UICorner", { CornerRadius = THEME.CornerRadius, Parent = elementContainer })
			new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Parent = elementContainer })
			
			-- ELEMANLAR
			function section:new_button(text, callback)
				local btn = new("TextButton", { Name = "Button", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Secondary, Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, Parent = elementContainer })
				new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
				btn.MouseButton1Click:Connect(callback or function() end)
				return btn
			end
            
			function section:new_toggle(text, default, callback)
				local toggled = default or false
				local frame = new("TextButton", { Name = "Toggle", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), Text = "", BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local switch = new("Frame", { Name = "Switch", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -55, 0.5, -10), BackgroundColor3 = toggled and THEME.Accent or THEME.Secondary, Parent = frame })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
				local knob = new("Frame", { Name = "Knob", Size = UDim2.new(0, 16, 0, 16), Position = UDim2.fromScale(toggled and 0.6 or 0.1, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = THEME.Text, Parent = switch })
				new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

				frame.MouseButton1Click:Connect(function()
					toggled = not toggled
					TweenService:Create(switch, TweenInfo.new(THEME.AnimationSpeed / 1.5, THEME.EasingStyle), { BackgroundColor3 = toggled and THEME.Accent or THEME.Secondary }):Play()
					knob:TweenPosition(UDim2.fromScale(toggled and 0.6 or 0.1, 0.5), "Out", THEME.EasingStyle, THEME.AnimationSpeed, true)
					if callback then callback(toggled) end
				end)
				return { IsToggled = function() return toggled end, Set = function(val) toggled = val; if callback then callback(toggled) end end }
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

				local function update(inputX)
					local percent = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					value = min + (max - min) * percent
					fill:TweenSize(UDim2.fromScale(percent, 1), "Out", "Quad", 0.05, true)
					handle.Position = UDim2.fromScale(percent, 0.5)
					valueLabel.Text = tostring(math.floor(value))
					if callback then callback(math.floor(value)) end
				end
				
				track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input.Position.X) end end)
				UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input.Position.X) end end)
				UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				return { SetValue = function(v) value = v; update(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v-min)/(max-min))) end }
			end

			function section:new_dropdown(text, options, defaultIndex, callback)
				-- Simplified dropdown for brevity, can be expanded.
				local isOpen = false
				local currentIndex = defaultIndex or 1

				local frame = new("TextButton", { Name = "Dropdown", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Secondary, Text = "", Parent = elementContainer })
				new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency=1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0,15,0,0), TextXAlignment=Enum.TextXAlignment.Left, Parent = frame })
				local selectedLabel = new("TextLabel", { Text = options[currentIndex], Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency=1, Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5,0,0,0), TextXAlignment=Enum.TextXAlignment.Right, Parent = frame })
				
				-- Dropdown list logic here...
				return {GetSelected = function() return options[currentIndex] end}
			end

			-- GELİŞMİŞ RENK SEÇİCİ
			function section:new_colorpicker(text, default, callback)
				local color, alpha = (type(default) == "table" and default.Color or default) or Color3.new(1,1,1), (type(default) == "table" and default.Alpha) or 1
				local frame = new("TextButton", { Name = "ColorPicker", Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text="", Parent = elementContainer })
				new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local preview = new("Frame", { Name = "Preview", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -35, 0.5, -10), BackgroundColor3 = color, BackgroundTransparency = 1-alpha, Parent = frame })
				new("UICorner", { CornerRadius = UDim.new(0, 4), Parent = preview })
				new("UIStroke", { Color = THEME.Border, Parent = preview })
				new("ImageLabel", { Parent = preview, Size = UDim2.fromScale(1,1), Image = "rbxassetid://2609200982", ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 5, 0, 5), ImageTransparency = 0.6, BackgroundTransparency = 1, ZIndex = preview.ZIndex-1 })

				frame.MouseButton1Click:Connect(function()
					if activeColorPicker then activeColorPicker:Destroy() end
					
					local picker, h, s, v = nil, 1, 1, 1
					h,s,v = Color3.toHSV(color)

					local function updateFromHSV()
						local rgb = Color3.fromHSV(h, s, v)
						preview.BackgroundColor3 = rgb
						if callback then callback({Color=rgb, Alpha=alpha}) end
						if picker then picker.Hue.UIGradient.Color = ColorSequence.new(Color3.fromHSV(h,1,1)) end
					end
					
					picker = new("Frame", { Name = "PickerWindow", Size = UDim2.new(0, 250, 0, 280), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = THEME.Primary, ZIndex = 100, Parent = mainFrame })
					new("UICorner", { CornerRadius = THEME.CornerRadius, Parent = picker }); new("UIStroke", { Color = THEME.Border, Parent = picker })
					activeColorPicker = picker
					
					local svBox = new("Frame", { Name = "SVBox", Size = UDim2.new(1, -20, 0, 160), Position = UDim2.new(0.5, 0, 0, 10), AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = Color3.new(1,1,1), ClipsDescendants = true, Parent = picker })
					new("UIGradient", { Rotation = 90, Color = ColorSequence.new({Color3.new(1,1,1), Color3.new(0,0,0)}), Parent = svBox })
					new("UIGradient", { Name = "Hue", Rotation = 0, Color = ColorSequence.new({Color3.new(1,1,1), Color3.fromHSV(h,1,1)}), Parent = svBox })
					local svHandle = new("Frame", { Size = UDim2.new(0,10,0,10), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel=2, BorderColor3=Color3.new(0,0,0), Parent = svBox, Position=UDim2.fromScale(s, 1-v) }); new("UICorner", { CornerRadius = UDim.new(1,0), Parent = svHandle })

					local hueSlider = new("Frame", { Name = "HueSlider", Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0.5, 0, 0, 180), AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = THEME.Secondary, Parent = picker })
					new("UIGradient", { Color = ColorSequence.new({Color3.new(1,0,0),Color3.new(1,1,0),Color3.new(0,1,0),Color3.new(0,1,1),Color3.new(0,0,1),Color3.new(1,0,1),Color3.new(1,0,0)}), Parent = hueSlider })
					local hueHandle = new("Frame", { Size = UDim2.new(0,8,1,4), Position = UDim2.fromScale(h,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=2, BorderColor3=Color3.new(0,0,0), Parent = hueSlider })
					
					local alphaSlider = new("Frame", { Name = "AlphaSlider", Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0.5, 0, 0, 210), AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = THEME.Secondary, Parent = picker })
					new("ImageLabel", {Parent=alphaSlider, Size=UDim2.fromScale(1,1), Image="rbxassetid://2609200982", ScaleType=Enum.ScaleType.Tile, TileSize=UDim2.new(0,5,0,5), ImageTransparency=0.6, BackgroundTransparency=1})
					new("UIGradient", {Color=ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}), Parent=alphaSlider})
					local alphaHandle = new("Frame", { Size = UDim2.new(0,8,1,4), Position = UDim2.fromScale(1-alpha,0.5), AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=2, BorderColor3=Color3.new(0,0,0), Parent = alphaSlider })
					
					local function updateSV(input) s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1); v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1); svHandle.Position = UDim2.fromScale(s, 1-v); updateFromHSV() end
					local function updateHue(input) h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1); hueHandle.Position = UDim2.fromScale(h, 0.5); updateFromHSV() end
					local function updateAlpha(input) alpha = 1 - math.clamp((input.Position.X - alphaSlider.AbsolutePosition.X) / alphaSlider.AbsoluteSize.X, 0, 1); alphaHandle.Position = UDim2.fromScale(1-alpha, 0.5); preview.BackgroundTransparency = 1-alpha; if callback then callback({Color=color, Alpha=alpha}) end end

					svBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then updateSV(i) end end)
					svBox.InputChanged:Connect(function(i) if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then updateSV(i) end end)
					hueSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then updateHue(i) end end)
					hueSlider.InputChanged:Connect(function(i) if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then updateHue(i) end end)
					alphaSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then updateAlpha(i) end end)
					alphaSlider.InputChanged:Connect(function(i) if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then updateAlpha(i) end end)

					new("TextButton", { Text = "X", Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-30,0,0), BackgroundTransparency=1, TextColor3=THEME.Text, Parent = picker, MouseButton1Click = function() picker:Destroy(); activeColorPicker = nil end })
					updateFromHSV()
				end)
				return { SetColor = function(c) color = c.Color or c; alpha = c.Alpha or alpha; preview.BackgroundColor3 = color; preview.BackgroundTransparency = 1-alpha; end, GetColor = function() return {Color=color, Alpha=alpha} end }
			end

			return section
		end
		
		return tabData
	end

	function window:Toggle()
		local visible = not mainFrame.Visible
		if visible then mainFrame.Visible = true end
		blurContainer.Visible = visible
		local goalPos = visible and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.45)
		local goalTrans = visible and 0 or 1
		mainFrame:TweenPosition(goalPos, "Out", THEME.EasingStyle, THEME.AnimationSpeed, true)
		TweenService:Create(mainFrame, TweenInfo.new(THEME.AnimationSpeed), { BackgroundTransparency = goalTrans }):Play()
		if not visible then task.delay(THEME.AnimationSpeed, function() mainFrame.Visible = false end) end
	end
	
	function window:Destroy() blurContainer:Destroy() end

	-- AÇILIŞ ANİMASYONU
	window:Toggle()

	return window
end

return AxiomUI
