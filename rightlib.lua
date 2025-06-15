local SimpleUI = {}

-- Helper function: create instance with properties and parent
local function newInstance(class, props, parent)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

-- Window constructor
function SimpleUI.new(title)
    local self = {}

    -- Ana ekran (ScreenGui)
    local screenGui = newInstance("ScreenGui", {
        ResetOnSpawn = false,
        Name = "SimpleUI_"..tostring(math.random(1,9999)),
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))

    -- Ana pencere Frame
    local mainFrame = newInstance("Frame", {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Active = true,
        Draggable = true, -- Klasik draggable ama daha modern çözüme geçilebilir
        ZIndex = 10,
        AnchorPoint = Vector2.new(0,0),
        Visible = true,
        Name = "MainWindow"
    }, screenGui)

    -- Başlık Bar
    local titleBar = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 60),
        BorderSizePixel = 0,
        Parent = mainFrame,
        ZIndex = 11,
        Name = "TitleBar"
    })

    local titleLabel = newInstance("TextLabel", {
        Text = title or "SimpleUI",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(220,220,220),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
        ZIndex = 12,
        Name = "TitleLabel"
    })

    local closeButton = newInstance("TextButton", {
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(220, 70, 70),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        AutoButtonColor = false,
        Parent = titleBar,
        ZIndex = 12,
        Name = "CloseButton"
    })

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Sekme çubuğu (Tab Bar)
    local tabBar = newInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 55),
        BorderSizePixel = 0,
        Parent = mainFrame,
        ZIndex = 11,
        Name = "TabBar"
    })

    local tabs = {}
    local selectedTab = nil

    -- İçerik alanı
    local contentFrame = newInstance("Frame", {
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame,
        ZIndex = 10,
        Name = "ContentFrame"
    })

    -- Sekme ekleme fonksiyonu
    function self:new_tab(name)
        local tabButton = newInstance("TextButton", {
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200,200,200),
            BackgroundColor3 = Color3.fromRGB(40, 40, 55),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 1, 0),
            Parent = tabBar,
            ZIndex = 12,
            Name = "Tab_"..name
        })

        local tabContent = newInstance("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = contentFrame,
            ZIndex = 10,
            Name = "TabContent_"..name
        })

        local sections = {}

        -- Butona basılınca sekmeyi göster
        tabButton.MouseButton1Click:Connect(function()
            -- Diğer tüm sekmeleri gizle
            for _, t in pairs(tabs) do
                t.content.Visible = false
                t.button.BackgroundColor3 = Color3.fromRGB(40,40,55)
                t.button.TextColor3 = Color3.fromRGB(200,200,200)
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 110)
            tabButton.TextColor3 = Color3.fromRGB(255,255,255)
            selectedTab = tabContent
        end)

        -- Otomatik olarak ilk sekmeyi seç (ilk sekme ise)
        if #tabs == 0 then
            tabButton.MouseButton1Click:Wait()
        end

        local tabData = {button = tabButton, content = tabContent, sections = sections}

        -- Bölüm ekleme fonksiyonu
        function tabData:new_section(name)
            local sectionFrame = newInstance("Frame", {
                Size = UDim2.new(1, -20, 0, 100),
                BackgroundColor3 = Color3.fromRGB(45, 45, 60),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, (#sections) * 110),
                Parent = tabContent,
                ZIndex = 10,
                Name = "Section_"..name
            })

            local sectionLabel = newInstance("TextLabel", {
                Text = name,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(210, 210, 230),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Position = UDim2.new(0, 10, 0, 10),
                Parent = sectionFrame,
                ZIndex = 11,
                Name = "SectionLabel"
            })

            local elements = {}
            local elementY = 40

            local function addElement(type_, text, default, callback)
                local el

                if type_ == "Button" then
                    el = newInstance("TextButton", {
                        Text = text,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundColor3 = Color3.fromRGB(70, 70, 110),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -20, 0, 30),
                        Position = UDim2.new(0, 10, 0, elementY),
                        Parent = sectionFrame,
                        ZIndex = 12,
                        Name = "Button_"..text,
                    })

                    el.MouseButton1Click:Connect(function()
                        if callback then callback() end
                    end)

                elseif type_ == "Toggle" then
                    local toggled = default or false

                    el = newInstance("Frame", {
                        Size = UDim2.new(1, -20, 0, 30),
                        Position = UDim2.new(0, 10, 0, elementY),
                        BackgroundTransparency = 1,
                        Parent = sectionFrame,
                        ZIndex = 12,
                        Name = "Toggle_"..text,
                    })

                    local label = newInstance("TextLabel", {
                        Text = text,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.8, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        Parent = el,
                        ZIndex = 13,
                    })

                    local box = newInstance("Frame", {
                        Size = UDim2.new(0, 24, 0, 24),
                        Position = UDim2.new(0.85, 0, 0.1, 0),
                        BackgroundColor3 = toggled and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(70, 70, 110),
                        BorderSizePixel = 0,
                        Parent = el,
                        ZIndex = 13,
                        Name = "ToggleBox"
                    })

                    local check = newInstance("TextLabel", {
                        Text = "✓",
                        Font = Enum.Font.GothamBold,
                        TextSize = 20,
                        TextColor3 = Color3.fromRGB(220,220,220),
                        BackgroundTransparency = 1,
                        Visible = toggled,
                        Size = UDim2.new(1, 0, 1, 0),
                        Parent = box,
                        ZIndex = 14,
                        Name = "Checkmark"
                    })

                    el.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            toggled = not toggled
                            box.BackgroundColor3 = toggled and Color3.fromRGB(100,150,255) or Color3.fromRGB(70,70,110)
                            check.Visible = toggled
                            if callback then callback({Toggle = toggled}) end
                        end
                    end)

                elseif type_ == "Dropdown" then
                    local options = default.options or {}
                    local currentIndex = 1
                    local isOpen = false

                    el = newInstance("Frame", {
                        Size = UDim2.new(1, -20, 0, 30),
                        Position = UDim2.new(0, 10, 0, elementY),
                        BackgroundColor3 = Color3.fromRGB(70, 70, 110),
                        BorderSizePixel = 0,
                        Parent = sectionFrame,
                        ZIndex = 20,
                        Name = "Dropdown_"..text,
                        ClipsDescendants = false
                    })

                    local label = newInstance("TextLabel", {
                        Text = text,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.7, 0, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        Parent = el,
                        ZIndex = 21,
                    })

                    local selectedLabel = newInstance("TextLabel", {
                        Text = options[currentIndex] or "Select",
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.2, 0, 1, 0),
                        Position = UDim2.new(0.75, 0, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = el,
                        ZIndex = 21,
                        Name = "SelectedLabel"
                    })

                    local arrow = newInstance("TextLabel", {
                        Text = "▼",
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 15, 1, 0),
                        Position = UDim2.new(1, -20, 0, 0),
                        Parent = el,
                        ZIndex = 21,
                    })

                    -- Dropdown liste container
                    local listContainer = newInstance("Frame", {
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(60, 60, 100),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Parent = el,
                        ZIndex = 25,
                        Name = "ListContainer"
                    })

                    -- Liste elemanlarını yarat
                    local itemHeight = 30
                    local itemFrames = {}

                    for i, option in ipairs(options) do
                        local item = newInstance("TextButton", {
                            Text = option,
                            Font = Enum.Font.Gotham,
                            TextSize = 14,
                            TextColor3 = Color3.fromRGB(230,230,230),
                            BackgroundColor3 = Color3.fromRGB(80, 80, 130),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, itemHeight),
                            Position = UDim2.new(0, 0, 0, (i-1) * itemHeight),
                            Parent = listContainer,
                            ZIndex = 26,
                            Name = "Item_"..option,
                        })

                        item.MouseEnter:Connect(function()
                            item.BackgroundColor3 = Color3.fromRGB(110, 110, 170)
                        end)
                        item.MouseLeave:Connect(function()
                            item.BackgroundColor3 = Color3.fromRGB(80, 80, 130)
                        end)

                        item.MouseButton1Click:Connect(function()
                            currentIndex = i
                            selectedLabel.Text = option
                            if callback then
                                callback({Dropdown = option})
                            end
                            -- Kapat
                            isOpen = false
                            listContainer:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
                        end)

                        table.insert(itemFrames, item)
                    end

                    -- Aç/kapa işlemi
                    el.MouseButton1Click:Connect(function()
                        if isOpen then
                            isOpen = false
                            listContainer:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
                        else
                            isOpen = true
                            listContainer:TweenSize(UDim2.new(1, 0, 0, #options * itemHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
                        end
                    end)

                    -- Alternatif aç/kapa için ok üzerine tıklama
                    arrow.MouseButton1Click:Connect(function()
                        el:MouseButton1Click()
                    end)

                elseif type_ == "Slider" then
                    local min = default.min or 0
                    local max = default.max or 100
                    local value = default.default or min
                    local dragging = false

                    el = newInstance("Frame", {
                        Size = UDim2.new(1, -20, 0, 30),
                        Position = UDim2.new(0, 10, 0, elementY),
                        BackgroundColor3 = Color3.fromRGB(70, 70, 110),
                        BorderSizePixel = 0,
                        Parent = sectionFrame,
                        ZIndex = 20,
                        Name = "Slider_"..text,
                    })

                    local label = newInstance("TextLabel", {
                        Text = text,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.6, 0, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        Parent = el,
                        ZIndex = 21,
                    })

                    local valueLabel = newInstance("TextLabel", {
                        Text = tostring(value),
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextColor3 = Color3.fromRGB(230,230,230),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.3, -10, 1, 0),
                        Position = UDim2.new(0.7, 0, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = el,
                        ZIndex = 21,
                    })

                    local sliderBar = newInstance("Frame", {
                        Size = UDim2.new(0.7, 0, 0, 6),
                        Position = UDim2.new(0.15, 0, 0.6, 0),
                        BackgroundColor3 = Color3.fromRGB(50, 50, 80),
                        BorderSizePixel = 0,
                        Parent = el,
                        ZIndex = 21,
                        Name = "SliderBar"
                    })

                    local sliderFill = newInstance("Frame", {
                        Size = UDim2.new((value-min)/(max-min) * 0.7, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                        BorderSizePixel = 0,
                        Parent = sliderBar,
                        ZIndex = 22,
                        Name = "SliderFill
