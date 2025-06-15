-- VexUI Kütüphanesi
-- Görüntü baz alınarak yeniden tasarlandı.

local VexUI = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Helper: Instance oluşturma
local function new(instanceType, properties)
	local inst = Instance.new(instanceType)
	for prop, val in pairs(properties or {}) do
		inst[prop] = val
	end
	return inst
end

-- Renkler ve Fontlar (Tasarımı buradan kolayca değiştirin)
local THEME = {
	Background = Color3.fromRGB(20, 20, 20),
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(45, 45, 45),
	Accent = Color3.fromRGB(80, 120, 255),
	Border = Color3.fromRGB(60, 60, 60),
	Text = Color3.fromRGB(220, 220, 220),
	TextSecondary = Color3.fromRGB(150, 150, 150),
	Font = Enum.Font.SourceSans,
	FontBold = Enum.Font.SourceSansBold,
}

-- Pencere Oluşturucu
function VexUI.new(title)
	local self = {}
	local activeDropdown = nil

	-- Ana Ekran
	local screenGui = new("ScreenGui", {
		Name = "VexUI_" .. tostring(math.random(1, 9999)),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Ana Pencere
	local mainFrame = new("Frame", {
		Name = "MainWindow",
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, -250, 0.5, -175),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		Active = true,
		Draggable = true,
		Parent = screenGui,
	})
	new("UIStroke", { Color = THEME.Border, Thickness = 1, Parent = mainFrame })

	-- Sekme Alanı
	local tabBar = new("Frame", {
		Name = "TabBar",
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = THEME.Primary,
		BorderSizePixel = 0,
		Parent = mainFrame
	})
	new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = THEME.Border, Thickness = 1, Parent = tabBar })
    
	local tabLayout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 15),
		Parent = tabBar
	})

	new("TextLabel", {
		Name = "Title",
		Text = title or "UI",
		Font = THEME.FontBold,
		TextSize = 16,
		TextColor3 = THEME.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
		Parent = tabBar
	})
    
	local tabSelectionLine = new("Frame", {
		Name = "SelectionLine",
		Size = UDim2.new(0, 50, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = tabBar
	})

	-- İçerik Alanı
	local contentFrame = new("ScrollingFrame", {
		Name = "Content",
		Size = UDim2.new(1, -20, 1, -45),
		Position = UDim2.new(0, 10, 0, 35),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = THEME.Accent,
		Parent = mainFrame
	})
	
	local contentLayout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
		Parent = contentFrame
	})

	local tabs = {}

	-- Sekme Ekleme
	function self:new_tab(name)
		local tabContent = new("Frame", {
			Name = "TabContent_"..name,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			Parent = contentFrame
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 15),
			Parent = tabContent,
		})
        
		local tabButton = new("TextButton", {
			Name = "TabButton_"..name,
			Text = name,
			Font = THEME.Font,
			TextSize = 14,
			TextColor3 = THEME.TextSecondary,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
			AutoButtonColor = false,
			Parent = tabBar,
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
					Size = UDim2.new(0, tabButton.AbsoluteSize.X, 0, 2),
					Position = UDim2.new(0, tabButton.AbsolutePosition.X - tabBar.AbsolutePosition.X, 1, -2)
				}):Play()
			end)
		end

		tabButton.MouseButton1Click:Connect(selectTab)

		if #tabs == 1 then
			task.wait()
			selectTab()
		end
		
		-- Bölüm Ekleme
		function tabData:new_section(name)
			local sectionFrame = new("Frame", {
                Name = "Section_"..name,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = tabContent
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 8),
                Parent = sectionFrame
            })
            
            new("TextLabel", {
                Text = name,
                Font = THEME.FontBold,
                TextSize = 14,
                TextColor3 = THEME.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
			local elementContainer = new("Frame", {
				Name = "ElementContainer",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = THEME.Primary,
				BorderSizePixel = 0,
				Parent = sectionFrame
			})
			new("UIStroke", {Color = THEME.Border, Parent = elementContainer})
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 1), -- To create separator lines
				Parent = elementContainer
			})
			
			local sectionAPI = {}

			local function addSeparator(parent)
				new("Frame", {
					Name = "Separator",
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = THEME.Border,
					BorderSizePixel = 0,
					Parent = parent
				})
			end

            --[[ ELEMENTLER ]]--
            
			function sectionAPI:new_button(text, callback)
				local btnFrame = new("TextButton", {
					Name = "Button_"..text,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = THEME.Primary,
					Text = "", AutoButtonColor = false,
					Parent = elementContainer
				})
				
				local label = new("TextLabel", {
					Text = text, Font = THEME.Font, TextSize = 14,
					TextColor3 = THEME.Text, BackgroundTransparency = 1,
					Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left, Parent = btnFrame
				})
				
				btnFrame.MouseEnter:Connect(function() btnFrame.BackgroundColor3 = THEME.Secondary end)
				btnFrame.MouseLeave:Connect(function() btnFrame.BackgroundColor3 = THEME.Primary end)
				btnFrame.MouseButton1Click:Connect(callback or function() end)

				addSeparator(elementContainer)
				return btnFrame
			end

			function sectionAPI:new_toggle(text, default, callback)
				local toggled = default or false
				local toggleFrame = new("TextButton", {
					Name = "Toggle_"..text, Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false,
					Parent = elementContainer
				})
				
				local label = new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame })
				local check = new("TextLabel", { Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -50, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, Parent = toggleFrame })
				
				local function updateVisual() check.Text = toggled and "[X]" or "[ ]" end
				updateVisual()

				toggleFrame.MouseEnter:Connect(function() toggleFrame.BackgroundColor3 = THEME.Secondary end)
				toggleFrame.MouseLeave:Connect(function() toggleFrame.BackgroundColor3 = THEME.Primary end)
				toggleFrame.MouseButton1Click:Connect(function()
					toggled = not toggled
					updateVisual()
					if callback then callback(toggled) end
				end)

				addSeparator(elementContainer)
				return { IsToggled = function() return toggled end }
			end

			function sectionAPI:new_slider(text, min, max, default, step, callback)
				local value = default or min
				local sliderFrame = new("Frame", {
					Name = "Slider_"..text, Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = THEME.Primary, Parent = elementContainer
				})
				
				local label = new("TextLabel", { Text = text .. ": " .. tostring(value), Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = sliderFrame })
				
				local function updateSlider(newValue)
					value = math.clamp(newValue, min, max)
					label.Text = text .. ": " .. tostring(value)
					if callback then callback(value) end
				end
				
				local minus = new("TextButton", { Text = "-", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundColor3 = THEME.Secondary, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), Parent = sliderFrame})
				new("UIStroke", {Color = THEME.Border, Parent = minus})
				minus.MouseButton1Click:Connect(function() updateSlider(value - (step or 1)) end)
				
				local plus = new("TextButton", { Text = "+", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundColor3 = THEME.Secondary, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -35, 0.5, -10), Parent = sliderFrame})
				new("UIStroke", {Color = THEME.Border, Parent = plus})
				plus.MouseButton1Click:Connect(function() updateSlider(value + (step or 1)) end)
				
				addSeparator(elementContainer)
				return { SetValue = updateSlider }
			end

			function sectionAPI:new_keybind(text, default, callback)
				local currentKey = default or "NONE"
				local listening = false

				local keybindFrame = new("TextButton", {
					Name = "Keybind_"..text, Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false,
					Parent = elementContainer
				})
				
				local label = new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = keybindFrame })
				local keyLabel = new("TextLabel", { Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -100, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, Parent = keybindFrame })
				
				local function updateVisual() keyLabel.Text = "[" .. (listening and "..." or currentKey) .. "]" end
				updateVisual()

				keybindFrame.MouseEnter:Connect(function() keybindFrame.BackgroundColor3 = THEME.Secondary end)
				keybindFrame.MouseLeave:Connect(function() if not listening then keybindFrame.BackgroundColor3 = THEME.Primary end end)
				
				local connection
				keybindFrame.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					keybindFrame.BackgroundColor3 = THEME.Accent
					updateVisual()
					
					connection = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							currentKey = input.KeyCode.Name
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							currentKey = "Mouse1"
						elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
							currentKey = "Mouse2"
						end
						listening = false
						updateVisual()
						if callback then callback(currentKey) end
						keybindFrame.BackgroundColor3 = THEME.Primary
						connection:Disconnect()
					end)
				end)

				addSeparator(elementContainer)
				return { GetKey = function() return currentKey end }
			end

			function sectionAPI:new_dropdown(text, options, defaultIndex, callback)
				local isOpen = false
				local currentIndex = defaultIndex or 1

				local dropdownFrame = new("TextButton", {
					Name = "Dropdown_"..text, Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false,
					ZIndex = 20, Parent = elementContainer
				})
				
				local label = new("TextLabel", { Text = text, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = dropdownFrame })
				local selectedLabel = new("TextLabel", { Text = options[currentIndex], Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0.5, -20, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = dropdownFrame })
				local arrow = new("TextLabel", { Text = "+", Font = THEME.Font, TextSize = 16, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), TextXAlignment = Enum.TextXAlignment.Center, Parent = dropdownFrame })
				
				local listContainer = new("Frame", {
					Name = "ListContainer", Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 1, 2), BackgroundColor3 = THEME.Primary,
					BorderSizePixel = 0, ClipsDescendants = true, Visible = false,
					ZIndex = 25, Parent = dropdownFrame
				})
				new("UIStroke", {Color = THEME.Border, Parent = listContainer})
				new("UIListLayout", {Padding = UDim.new(0, 1), Parent = listContainer})

				dropdownFrame.MouseEnter:Connect(function() if not isOpen then dropdownFrame.BackgroundColor3 = THEME.Secondary end end)
				dropdownFrame.MouseLeave:Connect(function() if not isOpen then dropdownFrame.BackgroundColor3 = THEME.Primary end end)

				dropdownFrame.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					
					if activeDropdown and activeDropdown ~= dropdownFrame then
						activeDropdown.ListContainer.Visible = false
						activeDropdown.Arrow.Text = "+"
						activeDropdown.BackgroundColor3 = THEME.Primary
						activeDropdown.isOpen = false
					end
					
					listContainer.Visible = isOpen
					arrow.Text = isOpen and "-" or "+"
					dropdownFrame.BackgroundColor3 = isOpen and THEME.Secondary or THEME.Primary
					elementContainer.LayoutOrder = isOpen and 1 or 0 -- Ensure it renders on top
					
					if isOpen then activeDropdown = dropdownFrame; activeDropdown.isOpen = true else activeDropdown = nil end
				end)

				for i, optionText in ipairs(options) do
					local itemBtn = new("TextButton", {
						Name = optionText, Size = UDim2.new(1, 0, 0, 28),
						BackgroundColor3 = THEME.Primary, Text = "", AutoButtonColor = false,
						Parent = listContainer
					})
					new("TextLabel", { Text = optionText, Font = THEME.Font, TextSize = 14, TextColor3 = THEME.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = itemBtn })
					
					itemBtn.MouseEnter:Connect(function() itemBtn.BackgroundColor3 = THEME.Accent end)
					itemBtn.MouseLeave:Connect(function() itemBtn.BackgroundColor3 = THEME.Primary end)
					itemBtn.MouseButton1Click:Connect(function()
						currentIndex = i
						selectedLabel.Text = options[currentIndex]
						if callback then callback(options[currentIndex], currentIndex) end
						-- Close
						dropdownFrame.MouseButton1Click:Fire()
					end)

					if i < #options then addSeparator(listContainer) end
				end
				
				addSeparator(elementContainer)
				return { GetSelected = function() return options[currentIndex] end }
			end

			return sectionAPI
		end
		
		return tabData
	end

	function self:Toggle()
		mainFrame.Visible = not mainFrame.Visible
	end
	
	function self:Destroy()
		screenGui:Destroy()
	end

	return self
end

return VexUI
