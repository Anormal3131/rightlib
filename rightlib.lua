-- SimpleUI Kütüphanesi
-- Yazar: (Orijinal + Geliştirmeler)
-- Sürüm: 2.0

local SimpleUI = {}
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

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
    }, Players.LocalPlayer:WaitForChild("PlayerGui"))

    -- Ana pencere Frame
    local mainFrame = newInstance("Frame", {
        Size = UDim2.new(0, 450, 0, 350), -- Biraz daha geniş
        Position = UDim2.new(0.5, -225, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        BorderSizePixel = 0,
        ClipsDescendants = true, -- Köşeleri yuvarlatmak için
        Active = true,
        Draggable = true,
        ZIndex = 10,
        Visible = true,
        Name = "MainWindow"
    }, screenGui)
    newInstance("UICorner", { CornerRadius = UDim.new(0, 8) }, mainFrame) -- Köşeleri yuvarlatma

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
        TextSize = 16,
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
        TextSize = 16,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        AutoButtonColor = false,
        Parent = titleBar,
        ZIndex = 12,
        Name = "CloseButton"
    })

    closeButton.MouseEnter:Connect(function() closeButton.TextColor3 = Color3.fromRGB(255, 80, 80) end)
    closeButton.MouseLeave:Connect(function() closeButton.TextColor3 = Color3.fromRGB(220, 220, 220) end)
    closeButton.MouseButton1Click:Connect(function()
        mainFrame:TweenSize(UDim2.new(0, 450, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
            screenGui:Destroy()
        end)
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
    newInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    }, tabBar)

    local tabs = {}
    local selectedTab = nil

    -- İçerik alanı
    local contentFrame = newInstance("ScrollingFrame", { -- ScrollingFrame olarak değiştirildi
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        BorderSizePixel = 0,
        Parent = mainFrame,
        ZIndex = 10,
        Name = "ContentFrame",
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255),
        ScrollBarThickness = 5,
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
            Name = "Tab_"..name,
            AutoButtonColor = false,
        })

        local tabContent = newInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 0), -- Boyut otomatik ayarlanacak
            AutomaticSize = Enum.AutomaticSize.Y, -- Otomatik boyutlandırma
            BackgroundTransparency = 1,
            Visible = false,
            Parent = contentFrame,
            ZIndex = 10,
            Name = "TabContent_"..name
        })
        newInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        }, tabContent)
        newInstance("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }, tabContent)


        local tabData = {button = tabButton, content = tabContent, sections = {}}
        
        local function selectTab()
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
            -- ScrollingFrame'in boyutunu güncelle
            task.wait() -- UIListLayout'un hesaplama yapması için kısa bir bekleme
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, tabContent.AbsoluteSize.Y)
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)

        table.insert(tabs, tabData)
        
        -- Otomatik olarak ilk sekmeyi seç
        if #tabs == 1 then
            selectTab()
        end

        -- Bölüm ekleme fonksiyonu
        function tabData:new_section(name)
            local sectionFrame = newInstance("Frame", {
                Size = UDim2.new(1, -20, 0, 0), -- Yükseklik otomatik olacak
                AutomaticSize = Enum.AutomaticSize.Y, -- Otomatik yükseklik
                BackgroundColor3 = Color3.fromRGB(45, 45, 60),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                Parent = tabContent,
                ZIndex = 10,
                Name = "Section_"..name
            })
            newInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, sectionFrame)
            newInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            }, sectionFrame)
            newInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            }, sectionFrame)

            local sectionLabel = newInstance("TextLabel", {
                Text = name,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Color3.fromRGB(210, 210, 230),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame,
                ZIndex = 11,
                Name = "SectionLabel"
            })
            
            local sectionData = {}
            
            --[[ ELEMENT EKLEME FONKSİYONLARI ]]--

            function sectionData:new_button(text, callback)
                local button = newInstance("TextButton", {
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(230,230,230),
                    BackgroundColor3 = Color3.fromRGB(70, 70, 110),
                    Size = UDim2.new(1, 0, 0, 30),
                    Parent = sectionFrame,
                    ZIndex = 12,
                    Name = "Button_"..text,
                    AutoButtonColor = false,
                })
                newInstance("UICorner", { CornerRadius = UDim.new(0, 4) }, button)
                
                button.MouseEnter:Connect(function() button.BackgroundColor3 = Color3.fromRGB(85, 85, 130) end)
                button.MouseLeave:Connect(function() button.BackgroundColor3 = Color3.fromRGB(70, 70, 110) end)
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                return button
            end
            
            function sectionData:new_toggle(text, default, callback)
                local toggled = default or false
                
                local toggleButton = newInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
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
                    Size = UDim2.new(1, -34, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleButton,
                    ZIndex = 13,
                })

                local box = newInstance("Frame", {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundColor3 = toggled and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(70, 70, 110),
                    BorderSizePixel = 0,
                    Parent = toggleButton,
                    ZIndex = 13,
                    Name = "ToggleBox"
                })
                newInstance("UICorner", { CornerRadius = UDim.new(0, 4) }, box)

                local check = newInstance("TextLabel", {
                    Text = "✓", Font = Enum.Font.GothamBold, TextSize = 20,
                    TextColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
                    Visible = toggled, Size = UDim2.new(1, 0, 1, 0), Parent = box, ZIndex = 14, Name = "Checkmark"
                })

                toggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    box:TweenSize(UDim2.new(0, 24, 0, 24), "Out", "Quad", 0.1, true)
                    box.BackgroundColor3 = toggled and Color3.fromRGB(100,150,255) or Color3.fromRGB(70,70,110)
                    check.Visible = toggled
                    if callback then callback(toggled) end
                end)
                return {IsToggled = function() return toggled end}
            end

            function sectionData:new_slider(text, min, max, default, callback)
                min, max = min or 0, max or 100
                local value = default or min
                local dragging = false

                local el = newInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Parent = sectionFrame,
                    ZIndex = 20,
                    Name = "Slider_"..text,
                })

                local label = newInstance("TextLabel", {
                    Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230),
                    BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = el, ZIndex = 21,
                })

                local valueLabel = newInstance("TextLabel", {
                    Text = tostring(math.floor(value)), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230),
                    BackgroundTransparency = 1, Size = UDim2.new(0.3, 0, 0, 20), Position = UDim2.new(0.7, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right, Parent = el, ZIndex = 21,
                })
                
                local sliderBase = newInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 80), BorderSizePixel = 0, Parent = el, ZIndex = 21, Name = "SliderBase"
                })
                newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderBase)

                local sliderFill = newInstance("Frame", {
                    Size = UDim2.new((value-min)/(max-min), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                    BorderSizePixel = 0, Parent = sliderBase, ZIndex = 22, Name = "SliderFill"
                })
                newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderFill)

                local sliderHandle = newInstance("Frame", {
                    Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value-min)/(max-min), 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
                    Parent = sliderBase, ZIndex = 23, Name = "SliderHandle"
                })
                newInstance("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderHandle)

                local function updateSlider(input)
                    local railAbsX = sliderBase.AbsolutePosition.X
                    local railAbsWidth = sliderBase.AbsoluteSize.X
                    local mouseX = input.Position.X
                    
                    local percent = math.clamp((mouseX - railAbsX) / railAbsWidth, 0, 1)
                    value = min + (max - min) * percent
                    
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueLabel.Text = tostring(math.floor(value))
                    
                    if callback then callback(math.floor(value)) end
                end
                
                sliderBase.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                return { SetValue = function(v) 
                    value = math.clamp(v, min, max)
                    local percent = (value-min)/(max-min)
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueLabel.Text = tostring(math.floor(value))
                end }
            end
            
            function sectionData:new_textbox(text, default, callback)
                local el = newInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionFrame,
                    ZIndex = 12,
                    Name = "TextBox_"..text,
                })
                
                local label = newInstance("TextLabel", {
                    Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230),
                    BackgroundTransparency = 1, Size = UDim2.new(0.4, -5, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = el, ZIndex = 13,
                })
                
                local box = newInstance("TextBox", {
                    Text = default or "", Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(220,220,220),
                    BackgroundColor3 = Color3.fromRGB(70, 70, 110), BorderSizePixel = 0,
                    Size = UDim2.new(0.6, -5, 1, 0), Position = UDim2.new(0.4, 5, 0, 0),
                    ClearTextOnFocus = false, Parent = el, ZIndex = 13, Name = "InputBox"
                })
                newInstance("UICorner", { CornerRadius = UDim.new(0, 4) }, box)
                
                box.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        if callback then callback(box.Text) end
                    end
                end)

                return { GetText = function() return box.Text end, SetText = function(t) box.Text = t end }
            end

            return sectionData
        end
        return tabData
    end

    function self:Toggle()
        mainFrame.Visible = not mainFrame.Visible
    end

    return self
end

return SimpleUI
