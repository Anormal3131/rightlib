-- Simple UI Library
local SimpleUILibrary = {}

-- Services
local UserInputService = game:GetService("UserInputService")

-- Helper: Create Instance with properties shortcut
local function createInstance(className, props)
    local inst = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            inst[k] = v
        end
    end
    return inst
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    -- Create main ScreenGui
    self.gui = createInstance("ScreenGui", {
        Name = "SimpleUI",
        ResetOnSpawn = false,
        Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
    })

    -- Main Frame
    self.frame = createInstance("Frame", {
        Parent = self.gui,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
    })

    -- Title Label
    self.title = createInstance("TextLabel", {
        Parent = self.frame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = title or "Simple UI",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        BorderSizePixel = 0,
    })

    self.tabs = {}
    self.currentTab = nil

    -- Tab buttons frame
    self.tabButtonsFrame = createInstance("Frame", {
        Parent = self.frame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
    })

    -- Content frame (for sections)
    self.contentFrame = createInstance("Frame", {
        Parent = self.frame,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    return self
end

function Window:new_tab(name)
    local tab = {}
    tab.name = name
    tab.sections = {}
    tab.buttons = {}

    -- Tab button
    local index = #self.tabs + 1
    local button = createInstance("TextButton", {
        Parent = self.tabButtonsFrame,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 100 * (index - 1), 0, 0),
        Text = name,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.SourceSans,
        TextSize = 18,
        BorderSizePixel = 0,
    })

    button.MouseButton1Click:Connect(function()
        self:switch_tab(index)
    end)

    tab.button = button

    -- Create tab content frame
    tab.frame = createInstance("Frame", {
        Parent = self.contentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    })

    -- Add function to create section
    function tab.new_section(tabSelf, sectionName)
        local section = {}
        section.name = sectionName
        section.elements = {}

        -- Section frame
        section.frame = createInstance("Frame", {
            Parent = tabSelf.frame,
            Size = UDim2.new(1, -20, 0, 150),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Position = UDim2.new(0, 10, 0, (#tabSelf.sections * 160) + 10),
            BorderSizePixel = 0,
        })

        -- Section title
        section.title = createInstance("TextLabel", {
            Parent = section.frame,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = sectionName,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.SourceSansBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        -- Elements container
        section.elementsFrame = createInstance("Frame", {
            Parent = section.frame,
            Size = UDim2.new(1, 0, 1, -25),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        })

        -- Add elements function
        function section.element(sectionSelf, type_, name, default, callback)
            local elem = {}
            elem.type_ = type_
            elem.name = name
            elem.callback = callback
            local y = (#sectionSelf.elements * 30)

            if type_ == "Button" then
                elem.instance = createInstance("TextButton", {
                    Parent = sectionSelf.elementsFrame,
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, y),
                    Text = name,
                    BackgroundColor3 = Color3.fromRGB(70, 70, 70),
                    TextColor3 = Color3.new(1, 1, 1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 16,
                    BorderSizePixel = 0,
                })
                elem.instance.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)

            elseif type_ == "Toggle" then
                elem.value = default or false

                -- Container frame
                elem.instance = createInstance("Frame", {
                    Parent = sectionSelf.elementsFrame,
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, y),
                    BackgroundTransparency = 1,
                })

                -- Label
                local label = createInstance("TextLabel", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.8, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.new(1, 1, 1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                -- Toggle button
                local toggleBtn = createInstance("TextButton", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.2, -5, 1, 0),
                    Position = UDim2.new(0.8, 5, 0, 0),
                    Text = elem.value and "ON" or "OFF",
                    BackgroundColor3 = elem.value and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0),
                    TextColor3 = Color3.new(1, 1, 1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 14,
                    BorderSizePixel = 0,
                })

                toggleBtn.MouseButton1Click:Connect(function()
                    elem.value = not elem.value
                    toggleBtn.Text = elem.value and "ON" or "OFF"
                    toggleBtn.BackgroundColor3 = elem.value and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
                    if callback then
                        callback({Toggle = elem.value})
                    end
                end)

            elseif type_ == "Dropdown" then
                elem.options = default and default.options or {}
                elem.selected = elem.options[1]

                elem.instance = createInstance("Frame", {
                    Parent = sectionSelf.elementsFrame,
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, y),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 0,
                })

                local label = createInstance("TextLabel", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.new(1,1,1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local dropdownBtn = createInstance("TextButton", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.4, -10, 1, 0),
                    Position = UDim2.new(0.6, 5, 0, 0),
                    Text = elem.selected,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    TextColor3 = Color3.new(1,1,1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 14,
                    BorderSizePixel = 0,
                })

                local dropdownList = createInstance("Frame", {
                    Parent = elem.instance,
                    Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, #elem.options * 20),
                    Position = UDim2.new(0.6, 5, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Visible = false,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                })

                for i, option in ipairs(elem.options) do
                    local optionLabel = createInstance("TextButton", {
                        Parent = dropdownList,
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, (i-1)*20),
                        Text = option,
                        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                        TextColor3 = Color3.new(1,1,1),
                        Font = Enum.Font.SourceSans,
                        TextSize = 14,
                        BorderSizePixel = 0,
                    })
                    optionLabel.MouseButton1Click:Connect(function()
                        elem.selected = option
                        dropdownBtn.Text = option
                        dropdownList.Visible = false
                        if callback then
                            callback({Dropdown = option})
                        end
                    end)
                end

                dropdownBtn.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                end)

            elseif type_ == "Slider" then
                elem.min = default.min or 0
                elem.max = default.max or 100
                elem.value = default.default or elem.min

                elem.instance = createInstance("Frame", {
                    Parent = sectionSelf.elementsFrame,
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 5, 0, y),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BorderSizePixel = 0,
                })

                local label = createInstance("TextLabel", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Color3.new(1,1,1),
                    Font = Enum.Font.SourceSans,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local sliderBar = createInstance("Frame", {
                    Parent = elem.instance,
                    Size = UDim2.new(0.55, 0, 0, 20),
                    Position = UDim2.new(0.45, 0, 0, 5),
                    BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                    BorderSizePixel = 0,
                })

                local fill = createInstance("Frame", {
                    Parent = sliderBar,
                    Size = UDim2.new((elem.value - elem.min) / (elem.max - elem.min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 170, 255),
                    BorderSizePixel = 0,
                })

                local dragging = false
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                sliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                sliderBar.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                        local value = elem.min + (relativeX / sliderBar.AbsoluteSize.X) * (elem.max - elem.min)
                        elem.value = math.floor(value)
                        fill.Size = UDim2.new((elem.value - elem.min) / (elem.max - elem.min), 0, 1, 0)
                        if callback then
                            callback({Slider = elem.value})
                        end
                    end
                end)
            end

            table.insert(sectionSelf.elements, elem)
            return elem
        end

        table.insert(tabSelf.sections, section)
        return section
    end

    table.insert(self.tabs, tab)

    -- If first tab, switch to it automatically
    if #self.tabs == 1 then
        self:switch_tab(1)
    end

    return tab
end

function Window:switch_tab(index)
    for i, tab in ipairs(self.tabs) do
        tab.frame.Visible = (i == index)
        tab.button.BackgroundColor3 = (i == index) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
    end
    self.currentTab = index
end

function Window:Toggle()
    self.gui.Enabled = not self.gui.Enabled
end

SimpleUILibrary.new = Window.new

return SimpleUILibrary
