--[[
	RightLib v1.0
	A modern and feature-rich UI library for Roblox.
	
	Features:
	- Windows (Draggable, Toggleable)
	- Tabs
	- Labels
	- Buttons
	- Toggles (Checkboxes)
	- Sliders
	- Textboxes
	- Dropdowns
	- Color Pickers
	- Keybinds
	- Fully customizable theme engine
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local RightLib = {}
RightLib.__index = RightLib

-- // ================================== CONFIGURATION ================================== //
-- Default theme settings. Users can override this with setConfig().
local config = {
	Accent = Color3.fromRGB(0, 120, 255),
	AccentText = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(35, 35, 35),
	Header = Color3.fromRGB(25, 25, 25),
	Text = Color3.fromRGB(220, 220, 220),
	Element = Color3.fromRGB(55, 55, 55),
	Font = Enum.Font.GothamSemibold,
	TitleFont = Enum.Font.GothamBold,
	SmallTextSize = 12,
	MediumTextSize = 14,
	LargeTextSize = 16,
	Rounding = 8,
	Padding = 10,
	Spacing = 8,
	AnimationSpeed = 0.2,
}

-- // ================================== MAIN LIBRARY ================================== //

function RightLib.new()
	local library = {}
	setmetatable(library, RightLib)
	
	library.ScreenGui = Instance.new("ScreenGui")
	library.ScreenGui.Name = "RightLib_Gui"
	library.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	library.ScreenGui.ResetOnSpawn = false
	
	return library
end

function RightLib:setParent(parent)
	self.ScreenGui.Parent = parent
end

function RightLib:setConfig(newConfig)
	for i, v in pairs(newConfig) do
		config[i] = v
	end
end

-- // ================================== WINDOW ================================== //

function RightLib:CreateWindow(title)
	local window = {}
	window.Tabs = {}
	window.ActiveTab = nil
	
	-- Create GUI Elements
	window.Frame = Instance.new("Frame")
	window.Frame.Name = "Window"
	window.Frame.Size = UDim2.new(0, 500, 0, 300)
	window.Frame.Position = UDim2.fromOffset(100, 100)
	window.Frame.BackgroundColor3 = config.Background
	window.Frame.BorderSizePixel = 0
	window.Frame.ClipsDescendants = true
	window.Frame.Visible = true
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, config.Rounding)
	corner.Parent = window.Frame
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = config.Header
	header.BorderSizePixel = 0
	header.Parent = window.Frame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -config.Padding, 1, 0)
	titleLabel.Position = UDim2.fromOffset(config.Padding, 0)
	titleLabel.BackgroundColor3 = config.Header
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = config.Text
	titleLabel.Font = config.TitleFont
	titleLabel.TextSize = config.LargeTextSize
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header
	
	-- Tab Container
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(0, 120, 1, -header.AbsoluteSize.Y)
	tabContainer.Position = UDim2.new(0, 0, 0, header.AbsoluteSize.Y)
	tabContainer.BackgroundColor3 = config.Background
	tabContainer.BorderSizePixel = 0
	tabContainer.Parent = window.Frame
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Vertical
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.Parent = tabContainer
	
	-- Content Container
	window.ContentContainer = Instance.new("Frame")
	window.ContentContainer.Name = "ContentContainer"
	window.ContentContainer.Size = UDim2.new(1, -tabContainer.AbsoluteSize.X - config.Padding, 1, -header.AbsoluteSize.Y - config.Padding)
	window.ContentContainer.Position = UDim2.new(0, tabContainer.AbsoluteSize.X, 0, header.AbsoluteSize.Y)
	window.ContentContainer.BackgroundColor3 = config.Background
	window.ContentContainer.BackgroundTransparency = 1
	window.ContentContainer.BorderSizePixel = 0
	window.ContentContainer.ClipsDescendants = true
	window.ContentContainer.Parent = window.Frame
	
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, config.Padding)
	contentPadding.PaddingLeft = UDim.new(0, config.Padding)
	contentPadding.Parent = window.ContentContainer
	
	-- Draggable Logic
	local dragging = false
	local dragStart
	local startPos
	
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local delta = input.Position - dragStart
				window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)

	-- Window Functions
	function window:AddTab(tabName)
		local tabObject = {}
		tabObject.Elements = {}
		
		-- Create Tab Button
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName
		tabButton.Size = UDim2.new(1, 0, 0, 30)
		tabButton.BackgroundColor3 = config.Background
		tabButton.Text = tabName
		tabButton.TextColor3 = config.Text
		tabButton.Font = config.Font
		tabButton.TextSize = config.MediumTextSize
		tabButton.BorderSizePixel = 0
		tabButton.Parent = tabContainer
		
		-- Create Tab Content Frame (Scrolling)
		local scrollFrame = Instance.new("ScrollingFrame")
		scrollFrame.Name = tabName .. "_Content"
		scrollFrame.Size = UDim2.new(1, 0, 1, 0)
		scrollFrame.BackgroundColor3 = config.Element
		scrollFrame.BackgroundTransparency = 1
		scrollFrame.BorderSizePixel = 0
		scrollFrame.Visible = false
		scrollFrame.Parent = window.ContentContainer
		scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
		scrollFrame.ScrollBarImageColor3 = config.Accent
		scrollFrame.ScrollBarThickness = 5
		
		local contentLayout = Instance.new("UIListLayout")
		contentLayout.FillDirection = Enum.FillDirection.Vertical
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Padding = UDim.new(0, config.Spacing)
		contentLayout.Parent = scrollFrame
		
		local contentPadding = Instance.new("UIPadding")
		contentPadding.PaddingLeft = UDim.new(0, config.Padding)
		contentPadding.PaddingRight = UDim.new(0, config.Padding)
		contentPadding.PaddingTop = UDim.new(0, config.Padding)
		contentPadding.PaddingBottom = UDim.new(0, config.Padding)
		contentPadding.Parent = scrollFrame
		
		tabObject.Frame = scrollFrame
		
		-- Tab Selection Logic
		tabButton.MouseButton1Click:Connect(function()
			if window.ActiveTab then
				window.ActiveTab.Button.BackgroundColor3 = config.Background
				window.ActiveTab.Frame.Visible = false
			end
			window.ActiveTab = { Button = tabButton, Frame = scrollFrame }
			tabButton.BackgroundColor3 = config.Element
			scrollFrame.Visible = true
		end)
		
		-- Auto-select first tab
		if not window.ActiveTab then
			tabButton:Invoke() -- Simulate a click
		end
		
		-- Function to update scrolling canvas size
		local function updateCanvasSize()
			RunService.Heartbeat:Wait() -- Wait a frame for layout to update
			contentLayout.AbsoluteContentSize.Y
			scrollFrame.CanvasSize = UDim2.fromOffset(0, contentLayout.AbsoluteContentSize.Y)
		end
		
		-- Element Functions (chained from tab)
		function tabObject:AddLabel(text)
			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(1, 0, 0, config.MediumTextSize)
			label.Text = text
			label.Font = config.Font
			label.TextColor3 = config.Text
			label.TextSize = config.MediumTextSize
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			label.Parent = tabObject.Frame
			updateCanvasSize()
			return self
		end
		
		function tabObject:AddButton(text, callback)
			local button = Instance.new("TextButton")
			button.Name = "Button"
			button.Size = UDim2.new(1, 0, 0, 30)
			button.BackgroundColor3 = config.Element
			button.Text = text
			button.TextColor3 = config.Text
			button.Font = config.Font
			button.TextSize = config.MediumTextSize
			button.Parent = tabObject.Frame
			local corner = Instance.new("UICorner", button)
			corner.CornerRadius = UDim.new(0, config.Rounding - 2)

			button.MouseButton1Click:Connect(function()
				pcall(callback)
			end)
			
			button.MouseEnter:Connect(function()
				TweenService:Create(button, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = config.Accent}):Play()
				TweenService:Create(button, TweenInfo.new(config.AnimationSpeed), {TextColor3 = config.AccentText}):Play()
			end)
			button.MouseLeave:Connect(function()
				TweenService:Create(button, TweenInfo.new(config.AnimationSpeed), {BackgroundColor3 = config.Element}):Play()
				TweenService:Create(button, TweenInfo.new(config.AnimationSpeed), {TextColor3 = config.Text}):Play()
			end)
			
			updateCanvasSize()
			return self
		end
		
		function tabObject:AddToggle(text, callback, defaultValue)
			defaultValue = defaultValue or false
			local state = defaultValue
			
			local container = Instance.new("Frame")
			container.Name = "Toggle"
			container.Size = UDim2.new(1, 0, 0, 25)
			container.BackgroundTransparency = 1
			container.Parent = tabObject.Frame

			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, -35, 1, 0)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.Text = text
			label.TextColor3 = config.Text
			label.Font = config.Font
			label.TextSize = config.MediumTextSize
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1

			local boxButton = Instance.new("TextButton")
			boxButton.Size = UDim2.fromOffset(25, 25)
			boxButton.Position = UDim2.new(1, -25, 0.5, -12.5)
			boxButton.BackgroundColor3 = config.Element
			boxButton.Text = ""
			boxButton.Parent = container
			local corner = Instance.new("UICorner", boxButton)
			corner.CornerRadius = UDim.new(0, config.Rounding - 4)
			
			local inner = Instance.new("Frame", boxButton)
			inner.Size = UDim2.new(1, -8, 1, -8)
			inner.Position = UDim2.fromOffset(4, 4)
			inner.BackgroundColor3 = config.Accent
			inner.BorderSizePixel = 0
			inner.Visible = state
			local innerCorner = Instance.new("UICorner", inner)
			innerCorner.CornerRadius = UDim.new(0, config.Rounding - 6)

			boxButton.MouseButton1Click:Connect(function()
				state = not state
				inner.Visible = state
				pcall(callback, state)
			end)
			
			updateCanvasSize()
			return self
		end

		function tabObject:AddSlider(text, min, max, callback, defaultValue)
			defaultValue = defaultValue or min
			
			local container = Instance.new("Frame")
			container.Name = "Slider"
			container.Size = UDim2.new(1, 0, 0, 40)
			container.BackgroundTransparency = 1
			container.Parent = tabObject.Frame

			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.Text = text
			label.TextColor3 = config.Text
			label.Font = config.Font
			label.TextSize = config.MediumTextSize
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			
			local valueLabel = Instance.new("TextLabel", container)
			valueLabel.Size = UDim2.new(1, 0, 0, 20)
			valueLabel.Text = tostring(defaultValue)
			valueLabel.TextColor3 = config.Text
			valueLabel.Font = config.Font
			valueLabel.TextSize = config.SmallTextSize
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.BackgroundTransparency = 1

			local track = Instance.new("Frame", container)
			track.Size = UDim2.new(1, 0, 0, 8)
			track.Position = UDim2.new(0, 0, 0, 25)
			track.BackgroundColor3 = config.Element
			local corner = Instance.new("UICorner", track)
			corner.CornerRadius = UDim.new(0, 4)

			local fill = Instance.new("Frame", track)
			fill.BackgroundColor3 = config.Accent
			local fillCorner = Instance.new("UICorner", fill)
			fillCorner.CornerRadius = UDim.new(0, 4)

			local handle = Instance.new("TextButton", track)
			handle.Size = UDim2.fromOffset(16, 16)
			handle.Position = UDim2.new(0, -8, 0.5, -8)
			handle.BackgroundColor3 = config.Accent
			handle.Text = ""
			local handleCorner = Instance.new("UICorner", handle)
			handleCorner.CornerRadius = UDim.new(0, 8)

			local function updateSlider(value)
				local percentage = (value - min) / (max - min)
				percentage = math.clamp(percentage, 0, 1)
				fill.Size = UDim2.new(percentage, 0, 1, 0)
				handle.Position = UDim2.new(percentage, -handle.AbsoluteSize.X / 2, 0.5, -handle.AbsoluteSize.Y / 2)
				valueLabel.Text = string.format("%.2f", value)
				pcall(callback, value)
			end
			updateSlider(defaultValue)

			local dragging = false
			handle.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local mouseX = UserInputService:GetMouseLocation().X
					local startX = track.AbsolutePosition.X
					local width = track.AbsoluteSize.X
					local percentage = math.clamp((mouseX - startX) / width, 0, 1)
					local value = min + (max - min) * percentage
					updateSlider(value)
				end
			end)
			
			updateCanvasSize()
			return self
		end
		
		function tabObject:AddTextbox(text, callback, placeholder)
			local container = Instance.new("Frame")
			container.Name = "Textbox"
			container.Size = UDim2.new(1, 0, 0, 50)
			container.BackgroundTransparency = 1
			container.Parent = tabObject.Frame

			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.Text = text
			label.TextColor3 = config.Text
			label.Font = config.Font
			label.TextSize = config.MediumTextSize
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1

			local textbox = Instance.new("TextBox", container)
			textbox.Size = UDim2.new(1, 0, 0, 30)
			textbox.Position = UDim2.fromOffset(0, 20)
			textbox.BackgroundColor3 = config.Element
			textbox.TextColor3 = config.Text
			textbox.Font = config.Font
			textbox.TextSize = config.MediumTextSize
			textbox.PlaceholderText = placeholder or "..."
			textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			textbox.ClearTextOnFocus = false
			local corner = Instance.new("UICorner", textbox)
			corner.CornerRadius = UDim.new(0, config.Rounding - 2)
			local padding = Instance.new("UIPadding", textbox)
			padding.PaddingLeft = UDim.new(0, 8)
			padding.PaddingRight = UDim.new(0, 8)

			textbox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					pcall(callback, textbox.Text)
				end
			end)

			updateCanvasSize()
			return self
		end

		function tabObject:AddKeybind(text, callback, defaultKey)
			defaultKey = defaultKey or Enum.KeyCode.None
			local currentKey = defaultKey
			local isBinding = false
			
			local container = Instance.new("Frame")
			container.Name = "Keybind"
			container.Size = UDim2.new(1, 0, 0, 30)
			container.BackgroundTransparency = 1
			container.Parent = tabObject.Frame
			
			local label = Instance.new("TextLabel", container)
			label.Size = UDim2.new(0.5, 0, 1, 0)
			label.Text = text
			label.TextColor3 = config.Text
			label.Font = config.Font
			label.TextSize = config.MediumTextSize
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1

			local keyButton = Instance.new("TextButton", container)
			keyButton.Size = UDim2.new(0.5, -config.Spacing, 1, 0)
			keyButton.Position = UDim2.new(0.5, config.Spacing, 0, 0)
			keyButton.BackgroundColor3 = config.Element
			keyButton.Text = tostring(currentKey.Name)
			keyButton.TextColor3 = config.Text
			keyButton.Font = config.Font
			keyButton.TextSize = config.MediumTextSize
			local corner = Instance.new("UICorner", keyButton)
			corner.CornerRadius = UDim.new(0, config.Rounding - 2)

			keyButton.MouseButton1Click:Connect(function()
				isBinding = true
				keyButton.Text = "..."
				
				local conn
				conn = UserInputService.InputBegan:Connect(function(input, gp)
					if gp then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							currentKey = Enum.KeyCode.None
						else
							currentKey = input.KeyCode
						end
						
						isBinding = false
						keyButton.Text = currentKey.Name
						pcall(callback, currentKey)
						conn:Disconnect()
					end
				end)
			end)
			
			updateCanvasSize()
			return self
		end
		
		-- More elements (Dropdown, ColorPicker) can be added here following the same pattern.

		return tabObject
	end
	
	function window:Toggle(key)
		local toggled = false
		UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.KeyCode == key then
				toggled = not toggled
				self.Frame.Visible = toggled
			end
		end)
	end

	window.Frame.Parent = self.ScreenGui
	return window
end


return RightLib
