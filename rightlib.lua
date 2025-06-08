-- ModernUI.lua - Basit ve Modern bir Executor UI Kütüphanesi
-- Yazar: [Senin Adın]
-- Versiyon: 1.0

local ModernUI = {}
ModernUI.Windows = {}
ModernUI.ActiveElement = nil
ModernUI.Mouse = {x = 0, y = 0, down = false, clicked = false}

--[[
    TEMA AYARLARI
    Tüm renkleri ve yazı tiplerini buradan kolayca değiştirebilirsin.
]]
ModernUI.Theme = {
    -- --- DEĞİŞTİR --- Kendi executor'ının font objesi veya ID'si ile değiştir.
    Font = "Arial",
    TitleFont = "Arial",
    FontSize = 14,
    TitleFontSize = 16,

    Colors = {
        Background = {25, 25, 30, 255},      -- Pencere arkaplanı
        Primary = {40, 40, 45, 255},       -- Elemanların arkaplanı
        Accent = {0, 120, 215, 255},       -- Vurgu rengi (buton hover, slider dolgusu vb.)
        AccentHover = {20, 140, 235, 255},  -- Vurgu rengi (hover durumu)
        Text = {220, 220, 220, 255},        -- Normal yazı rengi
        TitleText = {255, 255, 255, 255},   -- Pencere başlığı yazı rengi
        Outline = {60, 60, 65, 255},       -- Kenarlık rengi
    }
}

--[[
    YARDIMCI FONKSİYONLAR
    Bunlar, executor API'sine köprü görevi görür.
    --- DEĞİŞTİR --- Bu fonksiyonların içini kendi executor'ının API'si ile doldur.
]]
local function DrawRect(x, y, w, h, color)
    -- Örnek: drawing.draw_rect_filled(x, y, w, h, color.r, color.g, color.b, color.a)
    -- Bu satırı kendi executor'ının fonksiyonuyla değiştir.
    -- Bu örnekte basit bir print bırakıyorum. Gerçek uygulamada çizim fonksiyonu olmalı.
    -- print(string.format("Drawing Rect at %d,%d of size %d,%d", x, y, w, h))
end

local function DrawText(text, x, y, font, size, color)
    -- Örnek: drawing.draw_text(text, x, y, font, size, color.r, color.g, color.b, color.a)
    -- Bu satırı kendi executor'ının fonksiyonuyla değiştir.
end

local function GetTextSize(text, font, size)
    -- Örnek: return drawing.get_text_size(text, font, size)
    -- Bu satırı kendi executor'ının fonksiyonuyla değiştir.
    return #text * 8, size -- Geçici bir tahmin
end

-- Mouse pozisyonunu ve tıklama durumunu güncelleyen ana fonksiyon
function ModernUI:UpdateInput()
    local lastDown = self.Mouse.down
    -- --- DEĞİŞTİR --- Bu iki satırı kendi executor'ının input fonksiyonlarıyla değiştir.
    self.Mouse.x, self.Mouse.y = 0, 0 -- Örnek: input.get_mouse_pos()
    self.Mouse.down = false           -- Örnek: input.is_mouse_down(1) -- 1: Sol tık

    self.Mouse.clicked = not lastDown and self.Mouse.down
end

-- Mouse'un belirli bir alanın içinde olup olmadığını kontrol eder
function ModernUI:IsMouseInArea(x, y, w, h)
    return self.Mouse.x >= x and self.Mouse.x <= x + w and self.Mouse.y >= y and self.Mouse.y <= y + h
end


--[[
    PENCERE NESNESİ
]]
local Window = {}
Window.__index = Window

function ModernUI:CreateWindow(title, x, y, w, h)
    local win = setmetatable({
        title = title,
        x = x, y = y, w = w, h = h,
        elements = {},
        visible = true,
        dragging = false,
        dragOffset = {x = 0, y = 0},
        contentY = 35 -- Başlık çubuğu için boşluk
    }, Window)
    table.insert(self.Windows, win)
    return win
end

function Window:Draw()
    if not self.visible then return end

    -- Arkaplan ve Başlık Çubuğu
    DrawRect(self.x, self.y, self.w, self.h, ModernUI.Theme.Colors.Background)
    DrawRect(self.x, self.y, self.w, 30, ModernUI.Theme.Colors.Primary)
    DrawRect(self.x, self.y + 30, self.w, 1, ModernUI.Theme.Colors.Outline) -- Ayırıcı çizgi

    -- Başlık
    local titleW, titleH = GetTextSize(self.title, ModernUI.Theme.TitleFont, ModernUI.Theme.TitleFontSize)
    DrawText(self.title, self.x + 10, self.y + (30 - titleH) / 2, ModernUI.Theme.TitleFont, ModernUI.Theme.TitleFontSize, ModernUI.Theme.Colors.TitleText)

    -- Elemanları çiz
    for _, element in ipairs(self.elements) do
        element:Draw()
    end
end

function Window:Update()
    if not self.visible then return end

    local titleBarHeight = 30
    local isMouseInTitleBar = ModernUI:IsMouseInArea(self.x, self.y, self.w, titleBarHeight)

    if ModernUI.Mouse.clicked and isMouseInTitleBar then
        self.dragging = true
        self.dragOffset.x = ModernUI.Mouse.x - self.x
        self.dragOffset.y = ModernUI.Mouse.y - self.y
    end

    if self.dragging then
        if ModernUI.Mouse.down then
            self.x = ModernUI.Mouse.x - self.dragOffset.x
            self.y = ModernUI.Mouse.y - self.dragOffset.y
        else
            self.dragging = false
        end
    end

    -- Sadece bu pencere sürüklenmiyorsa elemanları güncelle
    if not self.dragging then
        for _, element in ipairs(self.elements) do
            element:Update()
        end
    end
end

function Window:AddElement(element)
    element.parent = self
    element.y = self.contentY -- Elemanın başlangıç Y pozisyonunu ayarla
    self.contentY = self.contentY + element.h + 10 -- Bir sonraki eleman için boşluk bırak
    table.insert(self.elements, element)
    return element
end


--[[
    BİLEŞENLER (Düğme, Checkbox, Slider)
]]

-- DÜĞME
local Button = {}
Button.__index = Button

function Window:AddButton(label, callback)
    local btn = setmetatable({
        label = label,
        callback = callback or function() end,
        h = 25 -- Yükseklik
    }, Button)
    return self:AddElement(btn)
end

function Button:Draw()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local w = self.parent.w - 30

    local color = ModernUI.Theme.Colors.Primary
    if ModernUI:IsMouseInArea(x, y, w, self.h) then
        color = ModernUI.Theme.Colors.Accent
    end

    DrawRect(x, y, w, self.h, color)
    local textW, textH = GetTextSize(self.label, ModernUI.Theme.Font, ModernUI.Theme.FontSize)
    DrawText(self.label, x + (w - textW) / 2, y + (self.h - textH) / 2, ModernUI.Theme.Font, ModernUI.Theme.FontSize, ModernUI.Theme.Colors.Text)
end

function Button:Update()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local w = self.parent.w - 30

    if ModernUI:IsMouseInArea(x, y, w, self.h) and ModernUI.Mouse.clicked then
        self.callback()
    end
end

-- CHECKBOX
local Checkbox = {}
Checkbox.__index = Checkbox

function Window:AddCheckbox(label, initialValue, callback)
    local chk = setmetatable({
        label = label,
        checked = initialValue or false,
        callback = callback or function() end,
        h = 20 -- Yükseklik
    }, Checkbox)
    return self:AddElement(chk)
end

function Checkbox:Draw()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local boxSize = 16

    DrawRect(x, y, boxSize, boxSize, ModernUI.Theme.Colors.Primary)
    if self.checked then
        DrawRect(x + 3, y + 3, boxSize - 6, boxSize - 6, ModernUI.Theme.Colors.Accent)
    end
    
    local textH = GetTextSize(self.label, ModernUI.Theme.Font, ModernUI.Theme.FontSize)
    DrawText(self.label, x + boxSize + 10, y + (self.h - textH)/2, ModernUI.Theme.Font, ModernUI.Theme.FontSize, ModernUI.Theme.Colors.Text)
end

function Checkbox:Update()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local w = self.parent.w - 30

    if ModernUI:IsMouseInArea(x, y, w, self.h) and ModernUI.Mouse.clicked then
        self.checked = not self.checked
        self.callback(self.checked)
    end
end

-- SLIDER
local Slider = {}
Slider.__index = Slider

function Window:AddSlider(label, min, max, initialValue, callback)
    local sld = setmetatable({
        label = label,
        min = min,
        max = max,
        value = initialValue or min,
        callback = callback or function() end,
        dragging = false,
        h = 25 -- Yükseklik
    }, Slider)
    return self:AddElement(sld)
end

function Slider:Draw()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local w = self.parent.w - 30
    local sliderY = y + 15
    local sliderHeight = 5

    -- Etiket ve değer
    local valText = string.format("%.2f", self.value)
    DrawText(self.label, x, y - 2, ModernUI.Theme.Font, ModernUI.Theme.FontSize, ModernUI.Theme.Colors.Text)
    local valW, _ = GetTextSize(valText, ModernUI.Theme.Font, ModernUI.Theme.FontSize)
    DrawText(valText, x + w - valW, y - 2, ModernUI.Theme.Font, ModernUI.Theme.FontSize, ModernUI.Theme.Colors.Text)

    -- Slider çubuğu
    local percent = (self.value - self.min) / (self.max - self.min)
    DrawRect(x, sliderY, w, sliderHeight, ModernUI.Theme.Colors.Primary)
    DrawRect(x, sliderY, w * percent, sliderHeight, ModernUI.Theme.Colors.Accent)
end

function Slider:Update()
    local x, y = self.parent.x + 15, self.parent.y + self.y
    local w = self.parent.w - 30
    local sliderY = y + 15
    
    local isMouseInArea = ModernUI:IsMouseInArea(x, sliderY - 5, w, 15)

    if isMouseInArea and ModernUI.Mouse.clicked then
        self.dragging = true
    end

    if self.dragging then
        if ModernUI.Mouse.down then
            local mouseX = ModernUI.Mouse.x - x
            local percent = math.max(0, math.min(1, mouseX / w))
            self.value = self.min + (self.max - self.min) * percent
            self.callback(self.value)
        else
            self.dragging = false
        end
    end
end


--[[
    ANA ÇİZİM VE GÜNCELLEME DÖNGÜSÜ
    Bu fonksiyonları executor'ının ana döngüsünden çağırmalısın.
]]
function ModernUI:Draw()
    for _, win in ipairs(self.Windows) do
        win:Draw()
    end
end

function ModernUI:Update()
    self:UpdateInput()
    for _, win in ipairs(self.Windows) do
        win:Update()
    end
end

return ModernUI
