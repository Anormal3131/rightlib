-- VanguardUI.lua - Kapsamlı ve Modern bir Executor UI Framework'ü
-- Özellikler: Genişletilebilir, Tema Desteği, Animasyonlar, Durum Yönetimi ve daha fazlası.

local VanguardUI = {
    _version = "1.0.0",
    Windows = {},
    Active = {},
    Input = {},
    Theme = {},
    Tweens = {},
    Notifications = {},
    ConfigVars = {},
    Visible = true,
    Scale = 1.0,
    ToggleKey = 212 -- Örnek: F11 (Executor'ının tuş kodunu kullan)
}

--[[=============================================================================
    EXECUTOR AYARI: SOYUTLAMA KATMANI (BURAYI DÜZENLE)
    Bu fonksiyonları kendi executor'ının API'si ile doldurmalısın.
==============================================================================]]

local Draw = {
    -- Örnek: screen_size() -> w, h
    GetScreenSize = function() return 1920, 1080 end,
    -- Örnek: draw.text(font_id, text, x, y, r, g, b, a)
    Text = function(text, x, y, font, size, color) end,
    -- Örnek: draw.get_text_size(font_id, text) -> w, h
    GetTextSize = function(text, font, size) return #text * 8 * VanguardUI.Scale, size * VanguardUI.Scale end,
    -- Örnek: draw.rect_filled(x, y, w, h, r, g, b, a)
    Rect = function(x, y, w, h, color) end,
    -- Örnek: draw.rect_rounded(x, y, w, h, radius, r, g, b, a)
    RoundedRect = function(x, y, w, h, rounding, color) Draw.Rect(x, y, w, h, color) end, -- Fallback
    -- Örnek: draw.shadow(x, y, w, h, blur, alpha)
    Shadow = function(x, y, w, h, blur, alpha) Draw.Rect(x, y, w, h, {0,0,0,alpha}) end, -- Fallback
    -- Örnek: draw.image(image_id, x, y, w, h)
    Image = function(id, x, y, w, h, color) end,
    -- ... Diğer çizim fonksiyonları (daire, üçgen vs.)
}

local Input = {
    -- Örnek: input.get_mouse_pos() -> x, y
    GetMousePos = function() return 0, 0 end,
    -- Örnek: input.is_mouse_down(1) -> boolean
    IsMouseDown = function() return false end,
    -- Örnek: input.was_mouse_clicked(1) -> boolean
    WasMouseClicked = function() return false end,
    -- Örnek: input.was_key_pressed(key_code) -> boolean
    WasKeyPressed = function(key) return false end,
}

--[[=============================================================================
    TEMA MOTORU
    Tüm görünüm buradan yönetilir. Yeni temalar ekleyebilirsin.
==============================================================================]]

VanguardUI.Themes = {
    Dark = {
        WindowBg = {25, 25, 30, 240},
        SectionBg = {35, 35, 40, 255},
        Primary = {50, 50, 55, 255},
        Accent = {0, 120, 215, 255},
        AccentHover = {20, 140, 235, 255},
        Text = {220, 220, 220, 255},
        TextDisabled = {120, 120, 120, 255},
        Outline = {60, 60, 65, 255},
        Shadow = {0, 0, 0, 100},
        Font = "Arial",
        Rounding = 6,
        ShadowBlur = 12,
    },
    Light = {
        WindowBg = {240, 240, 240, 240},
        SectionBg = {255, 255, 255, 255},
        Primary = {220, 220, 225, 255},
        Accent = {0, 120, 215, 255},
        AccentHover = {20, 140, 235, 255},
        Text = {20, 20, 20, 255},
        TextDisabled = {140, 140, 140, 255},
        Outline = {190, 190, 190, 255},
        Shadow = {0, 0, 0, 50},
        Font = "Arial",
        Rounding = 6,
        ShadowBlur = 12,
    }
}
VanguardUI.Theme = VanguardUI.Themes.Dark -- Varsayılan tema
function VanguardUI:SetTheme(themeName)
    if self.Themes[themeName] then
        self.Theme = self.Themes[themeName]
    end
end

--[[=============================================================================
    TWEEN ANİMASYON MOTORU
    Pürüzsüz animasyonlar için.
==============================================================================]]
-- Basit bir Easing fonksiyonu
local function easeOutCubic(t) return 1 - (1 - t) ^ 3 end

function VanguardUI:CreateTween(object, property, targetValue, duration)
    local tween = {
        object = object,
        property = property,
        startValue = object[property],
        change = targetValue - object[property],
        startTime = os.clock(),
        duration = duration
    }
    self.Tweens[object] = self.Tweens[object] or {}
    self.Tweens[object][property] = tween
end

function VanguardUI:UpdateTweens()
    local currentTime = os.clock()
    for obj, props in pairs(self.Tweens) do
        for prop, tween in pairs(props) do
            local elapsed = currentTime - tween.startTime
            if elapsed >= tween.duration then
                obj[prop] = tween.startValue + tween.change
                self.Tweens[obj][prop] = nil
            else
                local progress = elapsed / tween.duration
                obj[prop] = tween.startValue + tween.change * easeOutCubic(progress)
            end
        end
    end
end

--[[=============================================================================
    YARDIMCI FONKSİYONLAR
==============================================================================]]

function VanguardUI:IsMouseInArea(x, y, w, h)
    return self.Input.x >= x and self.Input.x <= x + w and self.Input.y >= y and self.Input.y <= y + h
end

--[[=============================================================================
    ANA YAPI: PENCERE (WINDOW)
==============================================================================]]
local Window = {}
Window.__index = Window

function VanguardUI:CreateWindow(title, x, y, w, h)
    local win = setmetatable({
        id = title,
        title = title,
        x = x, y = y, w = w, h = h,
        _w = w, _h = h, -- Animasyon için hedef değerler
        alpha = 0, -- Başlangıçta görünmez
        tabs = {},
        activeTab = nil,
        dragging = false,
        resizing = false,
        dragOffset = {x = 0, y = 0},
    }, Window)
    VanguardUI:CreateTween(win, "alpha", 1, 0.3) -- Açılış animasyonu
    table.insert(self.Windows, win)
    return win
end

function Window:AddTab(title)
    local tab = {
        title = title,
        parent = self,
        pages = {},
        activePage = nil
    }
    -- ... Tab oluşturma mantığı
    -- Bu örnekte basitleştirilmiştir: tüm elemanlar direkt pencereye eklenir.
    -- Gerçek bir Tab sistemi için, her Tab'ın kendi eleman listesi olurdu.
    return self
end

-- Örnek eleman ekleme fonksiyonu (gerçekte her widget için ayrı fonksiyon olacak)
function Window:AddButton(label, callback)
    local element = {
        type = "Button",
        label = label,
        callback = callback,
        -- ... diğer özellikler
    }
    -- ... Elemanı pencerenin eleman listesine ekle
    return element
end

function Window:Draw()
    local T = VanguardUI.Theme
    local S = VanguardUI.Scale
    
    -- Gölgeler
    Draw.Shadow(self.x, self.y, self.w * S, self.h * S, T.ShadowBlur, T.Shadow[4] * self.alpha)

    -- Ana Pencere
    Draw.RoundedRect(self.x, self.y, self.w * S, self.h * S, T.Rounding, T.WindowBg)
    
    -- Başlık Çubuğu
    Draw.Text(self.title, self.x + 15 * S, self.y + 15 * S, T.Font, 16 * S, T.Text)
    
    -- ... Diğer elemanların çizimi
end

function Window:Update()
    -- Input ve Sürükleme/Yeniden Boyutlandırma Mantığı
    -- ...
end


--[[=============================================================================
    CONFIG SİSTEMİ
==============================================================================]]

function VanguardUI:RegisterConfig(element)
    if element.id then
        self.ConfigVars[element.id] = element
    end
end

function VanguardUI:SaveConfig(profileName)
    local configData = {}
    for id, element in pairs(self.ConfigVars) do
        configData[id] = element:GetValue() -- Her elemanın bir GetValue metodu olmalı
    end
    -- 'configData' tablosunu JSON'a çevirip dosyaya yaz
    -- Örnek: local json = require("json"); file.write(profileName .. ".json", json.encode(configData))
    print(profileName .. " profili kaydedildi.")
end

function VanguardUI:LoadConfig(profileName)
    -- Dosyadan JSON'u oku ve 'configData'ya çevir
    -- Örnek: local json = require("json"); local data = json.decode(file.read(profileName .. ".json"))
    local data = {} -- Bu satırı dosya okuma ile değiştir
    for id, value in pairs(data) do
        if self.ConfigVars[id] then
            self.ConfigVars[id]:SetValue(value) -- Her elemanın bir SetValue metodu olmalı
        end
    end
    print(profileName .. " profili yüklendi.")
end


--[[=============================================================================
    ANA DÖNGÜ FONKSİYONLARI
==============================================================================]]

function VanguardUI:Update()
    -- Inputları güncelle
    self.Input.x, self.Input.y = Input.GetMousePos()
    self.Input.down = Input.IsMouseDown()
    self.Input.clicked = Input.WasMouseClicked()

    -- Aç/Kapat tuşu
    if Input.WasKeyPressed(self.ToggleKey) then
        self.Visible = not self.Visible
    end
    
    if not self.Visible then return end

    -- Animasyonları güncelle
    self:UpdateTweens()

    -- Pencereleri güncelle
    for _, win in ipairs(self.Windows) do
        win:Update()
    end
    
    -- ... Diğer sistemleri güncelle (Bildirimler, Tooltipler)
end

function VanguardUI:Draw()
    if not self.Visible then return end

    -- Pencereleri çiz
    for _, win in ipairs(self.Windows) do
        win:Draw()
    end

    -- ... Diğer sistemleri çiz (Bildirimler, Tooltipler)
end

-- Hafıza sızıntılarını önlemek için temizlik fonksiyonu
function VanguardUI:Destroy()
    for i = #self.Windows, 1, -1 do
        -- Her pencere ve eleman için bir :Destroy() metodu olmalı
        -- self.Windows[i]:Destroy() 
        table.remove(self.Windows, i)
    end
    self.ConfigVars = {}
    self.Tweens = {}
    print("VanguardUI temizlendi.")
end


return VanguardUI
