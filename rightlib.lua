-- DarkUI Kütüphanesi
-- Sağlanan görüntüye göre sıfırdan tasarlandı.

local DarkUI = {}

-- Servisler
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Helper: Instance oluşturma ve özellik atama
local function new(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, val in pairs(properties or {}) do
		inst[prop] = val
	end
	return inst
end

-- Tema: Tüm renkler, fontlar ve ayarlar burada. Değiştirmek çok kolay.
local THEME = {
	Background = Color3.fromRGB(22, 22, 22),
	Primary = Color3.fromRGB(28, 28, 28),
	Secondary = Color3.fromRGB(40, 40, 40),
	Accent = Color3.fromRGB(0, 122, 204),
	Border = Color3.fromRGB(50, 50, 50),
	Text = Color3.fromRGB(225, 225, 225),
	TextSecondary = Color3.fromRGB(160, 160, 160),
	Font = Enum.Font.Gotham, -- Daha keskin bir font için Gotham veya SourceSans
	FontBold = Enum.Font.GothamBold,
	ElementHeight = 28,
	BorderSize = 1,
}

-- Pencere Oluşturucu
function DarkUI.new(title)
	local self = {}
	local activeDropdown = nil -- Aynı anda sadece bir dropdown açık olabilir

	-- Ana Ekran
	local screenGui = new("ScreenGui", {
		Name = "DarkUI_" .. tostring(math.random(1, 9999)),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Ana Pencere
	local mainFrame = new("Frame", {
		Name = "MainWindow",
		Size = UDim2.new(0, 450, 0, 380),
		Position = UDim2.new(0.5, -225, 0.5, -190),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		Active = true,
		Draggable = true,
		Parent = screenGui,
	})
	new("UIStroke", { Color = THEME.Border, Thickness = THEME.BorderSize, Parent = mainFrame })

	-- Sekme Alanı
	local tabBar = new("Frame", {
		Name = "TabBar",
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = THEME.Primary,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = THEME.Border, Thickness = THEME.BorderSize, Parent = tabBar })
    
	local tabLayout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 15),
		Parent = tabBar
	})

	new("TextLabel", {
		Name = "Title", Text = title or "UI", Font = THEME.FontBold,
		TextSize = 16, TextColor3 = THEME.Text, BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
		Parent = tabBar
	})
    
	local tabSelectionLine = new("Frame", {
		Name = "SelectionLine", Size = UDim2.new(0, 50, 0, 2), Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0, ZIndex = 3, Parent = tabBar
	})

	-- İçerik Alanı
	local contentFrame = new("ScrollingFrame", {
		Name = "Content", Size = UDim2.new(1, -20, 1, -45), Position = UDim2.new(0, 10, 0, 35),
		BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
		ScrollBarThickness = 4, ScrollBarImageColor3 = THEME.Accent, Parent = mainFrame
	})
	
	new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 10), Parent = contentFrame })

	local tabs = {}

	-- Sekme Ekleme
	function self:new_tab(name)
		local tabContent = new("Frame", {
			Name = "TabContent_"..name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Visible = false, Parent = contentFrame
		})
		new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 15), Parent = tabContent })
        
		local tabButton = new("TextButton", {
			Name = "TabButton_"..name, Text = name, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.TextSecondary,
			BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
			AutoButtonColor = false, Parent = tabBar,
		})

		local tabData = { button = tabButton, content = tabContent }
		table.insert(tabs, tabData)

		local function selectTab()
			for _, t in pairs(tabs) do
				t.content.Visible = false
				TweenService:Create(t.button, TweenInfo.new(0.2), { TextColor3 = THEME.TextSecondary }):Play()
			end
			tabContent.Visible = true
			TweenService:Create(tabButton, TweenInfo.new(0.2), { TextColor3 = THEME.Text }):Play()
			
			task.defer(function()
				TweenService:Create(tabSelectionLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, tabButton.AbsoluteSize.X, 0, tabSelectionLine.Size.Y.Offset),
					Position = UDim2.new(0, tabButton.AbsolutePosition.X - tabBar.AbsolutePosition.X, 1, 0)
				}):Play()
			end)
		end

		tabButton.MouseButton1Click:Connect(selectTab)
		if #tabs == 1 then task.wait(); selectTab() end
		
		function tabData:new_section(name)
			local sectionFrame = new("Frame", {
                Name = "Section_"..name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, Parent = tabContent
            })
            new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = sectionFrame })
            
            new("TextLabel", {
                Text = name, Font = THEME.FontBold, TextSize = 14, TextColor3 = THEME.Text,
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = sectionFrame
            })
            
			local elementContainer = new("Frame", {
				Name = "ElementContainer", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, Parent = sectionFrame
			})
			new("UIStroke", {Color = THEME.Border, Thickness = THEME.BorderSize, Parent = elementContainer})
			new("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Parent = elementContainer })
			
			local sectionAPI = {}
			local isFirstElement = true

			local function addSeparator()
				new("Frame", { Name = "Separator", Size = UDim2.new(1, 0, 0, THEME.BorderSize), BackgroundColor3 = THEME.Border, BorderSizePixel = 0, Parent = elementContainer })
			end
            
			local function prepareElement()
				if not isFirstElement then addSeparator() else isFirstElement = false end
			end

            --[[ ELEMENTLER ]]--
            
            function sectionAPI:new_button(text, callback)
                prepareElement()
                local btn = new("TextButton", { Name = "Button_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text = " " .. text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = elementContainer })
                btn.MouseEnter:Connect(function() btn.BackgroundColor3 = THEME.Secondary end)
                btn.MouseLeave:Connect(function() btn.BackgroundColor3 = THEME.Primary end)
                btn.MouseButton1Click:Connect(callback or function() end)
                return btn
            end

			function sectionAPI:new_toggle(text, default, callback)
                prepareElement()
				local toggled = default or false
				local frame = new("TextButton", { Name = "Toggle_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false, Parent = elementContainer })
				local label = new("TextLabel", { Text = " " .. text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local checkBg = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -25, 0.5, -7), BackgroundColor3 = THEME.Secondary, Parent = frame })
                new("UIStroke", {Color = THEME.Border, Parent = checkBg})
                local check = new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = THEME.Accent, Visible = toggled, Parent = checkBg })

				frame.MouseEnter:Connect(function() frame.BackgroundColor3 = THEME.Secondary end)
				frame.MouseLeave:Connect(function() frame.BackgroundColor3 = THEME.Primary end)
				frame.MouseButton1Click:Connect(function()
					toggled = not toggled
					check.Visible = toggled
					if callback then callback(toggled) end
				end)
				return { IsToggled = function() return toggled end, Set = function(val) toggled = val; check.Visible = val end }
			end

			function sectionAPI:new_slider(text, min, max, default, step, callback)
                prepareElement()
				local value = default or min
				local frame = new("Frame", { Name = "Slider_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				local label = new("TextLabel", { Text = " " .. text .. ": " .. tostring(value), Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				
				local function update(newValue)
					value = math.clamp(newValue, min, max)
					label.Text = " " .. text .. ": " .. tostring(value)
					if callback then callback(value) end
				end
				
				local minus = new("TextButton", { Text = "-", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundColor3 = THEME.Secondary, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), Parent = frame})
				minus.MouseButton1Click:Connect(function() update(value - (step or 1)) end)
				
				local plus = new("TextButton", { Text = "+", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundColor3 = THEME.Secondary, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -35, 0.5, -10), Parent = frame})
				plus.MouseButton1Click:Connect(function() update(value + (step or 1)) end)
				return { SetValue = update }
			end

			function sectionAPI:new_keybind(text, default, callback)
                prepareElement()
				local currentKey = default or "NONE"
				local listening = false
				local frame = new("TextButton", { Name = "Keybind_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false, Parent = elementContainer })
				local label = new("TextLabel", { Text = " " .. text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local keyLabel = new("TextLabel", { Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -95, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, Parent = frame })
				
				local function updateVisual() keyLabel.Text = "[" .. (listening and "..." or currentKey) .. "]" end
				updateVisual()

				frame.MouseEnter:Connect(function() frame.BackgroundColor3 = THEME.Secondary end)
				frame.MouseLeave:Connect(function() if not listening then frame.BackgroundColor3 = THEME.Primary end end)
				
				local connection
				frame.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					keyLabel.TextColor3 = THEME.Accent
					updateVisual()
					
					connection = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end; currentKey = input.KeyCode.Name
						if input.UserInputType == Enum.UserInputType.MouseButton1 then currentKey = "Mouse1"
						elseif input.UserInputType == Enum.UserInputType.MouseButton2 then currentKey = "Mouse2" end
						
						listening = false
						keyLabel.TextColor3 = THEME.Text
						updateVisual()
						if callback then callback(currentKey) end
						connection:Disconnect()
					end)
				end)
				return { GetKey = function() return currentKey end }
			end

			function sectionAPI:new_dropdown(text, options, defaultIndex, callback)
                prepareElement()
				local isOpen = false
				local currentIndex = defaultIndex or 1

				local frame = new("TextButton", { Name = "Dropdown_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false, ZIndex = 20, Parent = elementContainer })
				local label = new("TextLabel", { Text = " " .. text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
				local selectedLabel = new("TextLabel", { Text = options[currentIndex], Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.5, -20, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = frame })
				local arrow = new("TextLabel", { Text = "+", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, Parent = frame })
				
				local listContainer = new("Frame", { Name = "ListContainer", Size = UDim2.new(1, 0, 0, #options * THEME.ElementHeight + (#options - 1)), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = THEME.Primary, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 25, Parent = frame })
				new("UIStroke", {Color = THEME.Border, Thickness = THEME.BorderSize, Parent = listContainer})
				new("UIListLayout", {Parent = listContainer})

				frame.MouseEnter:Connect(function() if not isOpen then frame.BackgroundColor3 = THEME.Secondary end end)
				frame.MouseLeave:Connect(function() if not isOpen then frame.BackgroundColor3 = THEME.Primary end end)

				frame.MouseButton1Click:Connect(function()
					isOpen = not isOpen; arrow.Text = isOpen and "-" or "+"
                    frame.ZIndex = isOpen and 21 or 20
					TweenService:Create(listContainer, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, isOpen and listContainer.AbsoluteContentSize.Y or 0)}):Play()
                    listContainer.Visible = true
				end)

				for i, optionText in ipairs(options) do
					local itemBtn = sectionAPI:new_button(optionText, function()
						currentIndex = i; selectedLabel.Text = options[currentIndex]
						if callback then callback(options[currentIndex], currentIndex) end
						isOpen = false; arrow.Text = "+"; frame.ZIndex = 20
                        TweenService:Create(listContainer, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 0)}):Play()
					end)
                    itemBtn.Parent = listContainer
				end
				return { GetSelected = function() return options[currentIndex] end }
			end
            
            function sectionAPI:new_colorpicker(text, defaultColor, callback)
                prepareElement()
                local color = defaultColor or Color3.new(1,1,1)
                local frame = new("Frame", { Name = "Color_"..text, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
				local label = new("TextLabel", { Text = " " .. text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
                local preview = new("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1,-30,0.5,-9), BackgroundColor3 = color, Parent = frame })
                new("UIStroke", {Color = THEME.Border, Parent = preview})
                -- Gelişmiş bir renk seçici burada açılabilir.
                return { SetColor = function(c) color = c; preview.BackgroundColor3 = c end, GetColor = function() return color end }
            end
            
            function sectionAPI:new_textbox(placeholder, callback)
                prepareElement()
                local frame = new("Frame", { Name = "TextBox_"..placeholder, Size = UDim2.new(1, 0, 0, THEME.ElementHeight), BackgroundColor3 = THEME.Primary, Parent = elementContainer })
                local box = new("TextBox", {
                    Size = UDim2.new(1, -20, 1, -10), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = THEME.Secondary, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text,
                    PlaceholderText = placeholder, PlaceholderColor3 = THEME.TextSecondary,
                    ClearTextOnFocus = false, Parent = frame
                })
                new("UIStroke", {Color = THEME.Border, Parent = box})
                box.FocusLost:Connect(function(enterPressed)
                    if enterPressed and callback then callback(box.Text) end
                end)
                return { GetText = function() return box.Text end, SetText = function(t) box.Text = t end }
            end

			return sectionAPI
		end
		return tabData
	end

	function self:Toggle() mainFrame.Visible = not mainFrame.Visible end
	function self:Destroy() screenGui:Destroy() end

	return self
end

return DarkUI
