--[[
    NNVN Lib - Modern Roblox UI Library
    Version: 1.4.0
    Compact · Themes · ProgressBar · Colorpicker · Tooltip · Tag · Acrylic

    Features:
    - Compact size + auto smaller on Mobile
    - Pure Black theme (default)
    - Multi-language (EN / VI + custom)
    - Dropdown with Search
    - Background Image (Asset ID → rbxassetid://)
    - Config auto-save (theme, language, size, bg)
    - Themes, Flags, Notifications, Dialogs
]]

local cloneref = cloneref or function(...) return ... end

local Services = setmetatable({}, {
    __index = function(self, name)
        local service = cloneref(game:GetService(name))
        rawset(self, name, service)
        return service
    end
})

local MarketplaceService = Services.MarketplaceService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local RunService = Services.RunService
local Players = Services.Players

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local gethui = gethui or function() return Services.CoreGui end
local CoreGui = gethui()

-- File system helpers (executor dependent)
local makefolder = makefolder or function() end
local writefile = writefile or function() end
local readfile = readfile or function() return nil end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local delfile = delfile or deletefile or function() end
local delfolder = delfolder or deletefolder or function() end

--------------------------------------------------------------------
-- THEMES (factory → many accent colors like WindUI + more)
--------------------------------------------------------------------
local SHARED_ICONS = {
    Error = "rbxassetid://10709752996",
    Button = "rbxassetid://10709791437",
    Close = "rbxassetid://10747384394",
    TextBox = "rbxassetid://15637081879",
    Search = "rbxassetid://10734943674",
    Keybind = "rbxassetid://10734982144",
    Dropdown = {
        Open = "rbxassetid://10709791523",
        Close = "rbxassetid://10709790948"
    }
}

local SHARED_FONT = {
    Normal = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
    ExtraBold = Enum.Font.GothamBold,
    SliderValue = Enum.Font.GothamBold
}

-- accent, iconTint, softBg, buttonHold  (RGB tables)
-- WindUI-inspired contrast while keeping redz compact dark feel
local function MakeTheme(name, accent, iconTint, opts)
    opts = opts or {}
    local bg1 = opts.bg1 or Color3.fromRGB(12, 12, 14)
    local bg2 = opts.bg2 or Color3.fromRGB(18, 18, 22)
    local onPrimary = opts.onPrimary or accent:Lerp(Color3.new(0, 0, 0), 0.5)
    local stroke = opts.stroke or Color3.fromRGB(42, 42, 48)
    local btnDefault = opts.btnDefault or Color3.fromRGB(28, 28, 32)
    local btnHold = opts.btnHold or Color3.fromRGB(40, 40, 46)
    local dialogBg = opts.dialog or Color3.fromRGB(16, 16, 18)

    return {
        Name = name,
        Colors = {
            Background = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, bg1),
                ColorSequenceKeypoint.new(0.50, bg2),
                ColorSequenceKeypoint.new(1.00, bg1)
            }),
            Primary = accent,
            OnPrimary = onPrimary,
            ScrollBar = accent,
            Stroke = stroke,
            Error = Color3.fromRGB(248, 113, 113),
            Icons = iconTint or accent,
            JoinButton = Color3.fromRGB(34, 197, 94),
            Link = accent:Lerp(Color3.fromRGB(255, 255, 255), 0.25),
            Dialog = { Background = dialogBg },
            Buttons = {
                Holding = btnHold,
                Default = btnDefault
            },
            Border = {
                Holding = stroke:Lerp(Color3.fromRGB(255, 255, 255), 0.3),
                Default = stroke
            },
            Text = {
                Default = Color3.fromRGB(255, 255, 255),
                Dark = Color3.fromRGB(185, 185, 192),
                Darker = Color3.fromRGB(140, 140, 150)
            },
            Slider = {
                SliderBar = accent,
                SliderNumber = Color3.fromRGB(245, 245, 250)
            },
            Dropdown = { Holder = bg2 }
        },
        Icons = SHARED_ICONS,
        Font = SHARED_FONT,
        BackgroundTransparency = opts.transparency or 0.02,
        Rainbow = opts.rainbow or false
    }
end

local Themes = {
    -- Neutral
    Black = MakeTheme("Black",
        Color3.fromRGB(99, 102, 241),
        Color3.fromRGB(245, 245, 250)
    ),
    -- Redz-style Darker (default) — lighter + clearer contrast (WindUI-inspired)
    Darker = MakeTheme("Darker",
        Color3.fromRGB(88, 101, 242),
        Color3.fromRGB(232, 233, 235),
        {
            bg1 = Color3.fromRGB(22, 22, 26),
            bg2 = Color3.fromRGB(30, 30, 36),
            stroke = Color3.fromRGB(55, 55, 65),
            btnDefault = Color3.fromRGB(36, 36, 42),
            btnHold = Color3.fromRGB(48, 48, 56),
            dialog = Color3.fromRGB(26, 26, 30),
            onPrimary = Color3.fromRGB(55, 62, 130),
            transparency = 0.04
        }
    ),

    -- Accent packs (icons + primary follow color)
    Amber = MakeTheme("Amber",
        Color3.fromRGB(245, 158, 11),
        Color3.fromRGB(252, 211, 77),
        { bg1 = Color3.fromRGB(12, 9, 4), bg2 = Color3.fromRGB(20, 15, 6), stroke = Color3.fromRGB(50, 35, 10) }
    ),
    Rose = MakeTheme("Rose",
        Color3.fromRGB(244, 63, 94),
        Color3.fromRGB(251, 113, 133),
        { bg1 = Color3.fromRGB(14, 4, 8), bg2 = Color3.fromRGB(22, 8, 12), stroke = Color3.fromRGB(55, 20, 30) }
    ),
    Emerald = MakeTheme("Emerald",
        Color3.fromRGB(16, 185, 129),
        Color3.fromRGB(52, 211, 153),
        { bg1 = Color3.fromRGB(4, 12, 8), bg2 = Color3.fromRGB(8, 20, 14), stroke = Color3.fromRGB(20, 50, 35) }
    ),
    Cyan = MakeTheme("Cyan",
        Color3.fromRGB(6, 182, 212),
        Color3.fromRGB(34, 211, 238),
        { bg1 = Color3.fromRGB(4, 12, 16), bg2 = Color3.fromRGB(8, 20, 24), stroke = Color3.fromRGB(15, 45, 55) }
    ),
    Sky = MakeTheme("Sky",
        Color3.fromRGB(14, 165, 233),
        Color3.fromRGB(56, 189, 248),
        { bg1 = Color3.fromRGB(4, 10, 18), bg2 = Color3.fromRGB(8, 18, 28), stroke = Color3.fromRGB(15, 40, 60) }
    ),
    Violet = MakeTheme("Violet",
        Color3.fromRGB(139, 92, 246),
        Color3.fromRGB(167, 139, 250),
        { bg1 = Color3.fromRGB(10, 6, 18), bg2 = Color3.fromRGB(16, 10, 28), stroke = Color3.fromRGB(40, 25, 65) }
    ),
    Indigo = MakeTheme("Indigo",
        Color3.fromRGB(99, 102, 241),
        Color3.fromRGB(129, 140, 248),
        { bg1 = Color3.fromRGB(8, 8, 20), bg2 = Color3.fromRGB(14, 14, 32), stroke = Color3.fromRGB(30, 30, 60) }
    ),
    Pink = MakeTheme("Pink",
        Color3.fromRGB(236, 72, 153),
        Color3.fromRGB(244, 114, 182),
        { bg1 = Color3.fromRGB(14, 6, 12), bg2 = Color3.fromRGB(24, 10, 20), stroke = Color3.fromRGB(55, 25, 45) }
    ),
    Red = MakeTheme("Red",
        Color3.fromRGB(239, 68, 68),
        Color3.fromRGB(248, 113, 113),
        { bg1 = Color3.fromRGB(14, 4, 4), bg2 = Color3.fromRGB(24, 8, 8), stroke = Color3.fromRGB(55, 20, 20) }
    ),
    Orange = MakeTheme("Orange",
        Color3.fromRGB(249, 115, 22),
        Color3.fromRGB(251, 146, 60),
        { bg1 = Color3.fromRGB(14, 8, 2), bg2 = Color3.fromRGB(24, 14, 4), stroke = Color3.fromRGB(55, 30, 10) }
    ),
    Lime = MakeTheme("Lime",
        Color3.fromRGB(132, 204, 22),
        Color3.fromRGB(163, 230, 53),
        { bg1 = Color3.fromRGB(8, 12, 4), bg2 = Color3.fromRGB(14, 20, 6), stroke = Color3.fromRGB(35, 50, 15) }
    ),
    Teal = MakeTheme("Teal",
        Color3.fromRGB(20, 184, 166),
        Color3.fromRGB(45, 212, 191),
        { bg1 = Color3.fromRGB(4, 12, 12), bg2 = Color3.fromRGB(8, 20, 20), stroke = Color3.fromRGB(15, 50, 48) }
    ),
    Blue = MakeTheme("Blue",
        Color3.fromRGB(59, 130, 246),
        Color3.fromRGB(96, 165, 250),
        { bg1 = Color3.fromRGB(4, 8, 18), bg2 = Color3.fromRGB(8, 14, 28), stroke = Color3.fromRGB(20, 35, 65) }
    ),
    Fuchsia = MakeTheme("Fuchsia",
        Color3.fromRGB(217, 70, 239),
        Color3.fromRGB(232, 121, 249),
        { bg1 = Color3.fromRGB(12, 4, 16), bg2 = Color3.fromRGB(20, 8, 26), stroke = Color3.fromRGB(50, 20, 60) }
    ),
    Gold = MakeTheme("Gold",
        Color3.fromRGB(234, 179, 8),
        Color3.fromRGB(250, 204, 21),
        { bg1 = Color3.fromRGB(12, 10, 2), bg2 = Color3.fromRGB(20, 16, 4), stroke = Color3.fromRGB(50, 40, 10) }
    ),
    Crimson = MakeTheme("Crimson",
        Color3.fromRGB(220, 38, 38),
        Color3.fromRGB(248, 113, 113),
        { bg1 = Color3.fromRGB(16, 2, 4), bg2 = Color3.fromRGB(26, 6, 8), stroke = Color3.fromRGB(60, 15, 20) }
    ),
    Mint = MakeTheme("Mint",
        Color3.fromRGB(52, 211, 153),
        Color3.fromRGB(110, 231, 183),
        { bg1 = Color3.fromRGB(4, 14, 10), bg2 = Color3.fromRGB(8, 22, 16), stroke = Color3.fromRGB(20, 55, 40) }
    ),
    Grape = MakeTheme("Grape",
        Color3.fromRGB(168, 85, 247),
        Color3.fromRGB(192, 132, 252),
        { bg1 = Color3.fromRGB(10, 4, 16), bg2 = Color3.fromRGB(18, 8, 26), stroke = Color3.fromRGB(45, 20, 65) }
    ),
    Coral = MakeTheme("Coral",
        Color3.fromRGB(251, 113, 133),
        Color3.fromRGB(253, 164, 175),
        { bg1 = Color3.fromRGB(14, 6, 8), bg2 = Color3.fromRGB(24, 12, 14), stroke = Color3.fromRGB(55, 28, 32) }
    ),
    Ocean = MakeTheme("Ocean",
        Color3.fromRGB(14, 116, 144),
        Color3.fromRGB(34, 211, 238),
        { bg1 = Color3.fromRGB(2, 10, 16), bg2 = Color3.fromRGB(4, 18, 26), stroke = Color3.fromRGB(10, 40, 55) }
    ),
    Sunset = MakeTheme("Sunset",
        Color3.fromRGB(251, 146, 60),
        Color3.fromRGB(253, 186, 116),
        { bg1 = Color3.fromRGB(16, 6, 4), bg2 = Color3.fromRGB(28, 12, 6), stroke = Color3.fromRGB(60, 30, 15) }
    ),
    -- Animated rainbow (Primary cycles hue)
    Rainbow = MakeTheme("Rainbow",
        Color3.fromRGB(255, 0, 128),
        Color3.fromRGB(255, 180, 220),
        { rainbow = true, bg1 = Color3.fromRGB(8, 8, 10), bg2 = Color3.fromRGB(14, 14, 16) }
    ),
}

for name, theme in pairs(Themes) do
    theme.Name = name
end

--------------------------------------------------------------------
-- LIBRARY CORE
--------------------------------------------------------------------
-- Detect mobile (touch device / small viewport)
local function IsMobileDevice()
    local ok, result = pcall(function()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    end)
    if ok and result then return true end
    -- fallback: small screen
    return Camera.ViewportSize.X < 700 or Camera.ViewportSize.Y < 500
end

local IS_MOBILE = IsMobileDevice()

--------------------------------------------------------------------
-- LANGUAGES (built-in EN + VI, add more via Library:AddLanguage)
--------------------------------------------------------------------
local Languages = {
    en = {
        Name = "English",
        CloseWindow = "Close Window?",
        CloseWindowDesc = "Do you want to close the UI?",
        Yes = "Yes",
        No = "No",
        Search = "Search...",
        Input = "Input",
        GoToServer = "Go to Server",
        CopiedClipboard = "Copied to Clipboard!",
        Settings = "Settings",
        Main = "Main",
        Misc = "Misc",
        Appearance = "Appearance",
        Theme = "Theme",
        Language = "Language",
        BackgroundImage = "Background Image ID",
        BackgroundImageDesc = "Enter only the number (rbxassetid:// is auto-added)",
        BackgroundTransparency = "Background Transparency",
        UIScale = "UI Scale",
        SaveConfig = "Config is saved automatically",
        OpenMenu = "Open Menu",
        CloseMenu = "Close Menu",
        Combat = "Combat",
        Notify = "Notification",
    },
    vi = {
        Name = "Tiếng Việt",
        CloseWindow = "Đóng cửa sổ?",
        CloseWindowDesc = "Bạn có muốn đóng giao diện không?",
        Yes = "Có",
        No = "Không",
        Search = "Tìm kiếm...",
        Input = "Nhập...",
        GoToServer = "Vào Server",
        CopiedClipboard = "Đã sao chép!",
        Settings = "Cài đặt",
        Main = "Chính",
        Misc = "Khác",
        Appearance = "Giao diện",
        Theme = "Chủ đề",
        Language = "Ngôn ngữ",
        BackgroundImage = "ID Ảnh nền",
        BackgroundImageDesc = "Chỉ nhập số (tự thêm rbxassetid://)",
        BackgroundTransparency = "Độ trong suốt ảnh nền",
        UIScale = "Tỉ lệ giao diện",
        SaveConfig = "Cấu hình được lưu tự động",
        OpenMenu = "Mở menu",
        CloseMenu = "Đóng menu",
        Combat = "Chiến đấu",
        Notify = "Thông báo",
    }
}

local Library = {
    Information = {
        Version = "v1.4.3",
        Name = "NNVN Lib",
        GitHubOwner = "NNVN"
    },
    Default = {
        Theme = "Darker",
        -- Desktop larger / Mobile slightly bigger
        UISize = IS_MOBILE and UDim2.fromOffset(400, 300) or UDim2.fromOffset(560, 380),
        TabSize = IS_MOBILE and 120 or 155,
        BackgroundImage = nil,
        BackgroundImageTransparency = 0.55,
        Language = "en"
    },
    Themes = Themes,
    Languages = Languages,
    CurrentLanguage = "en",
    Connections = {},
    Options = {},
    Tabs = {},
    Icons = {},
    -- registered text elements for live language switch: { {instance, key} ... }
    LocalizedLabels = {},
    LOADED_UI_LIBRARY = false,
    IsMobile = IS_MOBILE
}

Library.Info = Library.Information
Library.Save = Library.Default

--------------------------------------------------------------------
-- LANGUAGE API
--------------------------------------------------------------------
-- Translate a key: Library:T("CloseWindow") → "Đóng cửa sổ?" if VI
function Library:T(key, fallback)
    local lang = self.Languages[self.CurrentLanguage]
    if lang and lang[key] then return lang[key] end
    local en = self.Languages.en
    if en and en[key] then return en[key] end
    return fallback or key
end

-- Register a TextLabel / TextButton to auto-update when language changes
function Library:BindText(instance, key)
    if not instance or not key then return end
    table.insert(self.LocalizedLabels, { Instance = instance, Key = key })
    instance.Text = self:T(key)
end

-- Add / extend a language table
-- Library:AddLanguage("ja", { Name = "日本語", CloseWindow = "...", ... })
function Library:AddLanguage(code, strings)
    assert(type(code) == "string", "AddLanguage code expects string")
    assert(type(strings) == "table", "AddLanguage strings expects table")
    if self.Languages[code] then
        for k, v in pairs(strings) do
            self.Languages[code][k] = v
        end
    else
        self.Languages[code] = strings
    end
end

function Library:GetLanguages()
    local list = {}
    for code, data in pairs(self.Languages) do
        table.insert(list, { Code = code, Name = data.Name or code })
    end
    table.sort(list, function(a, b) return a.Code < b.Code end)
    return list
end

function Library:SetLanguage(code)
    assert(type(code) == "string", "SetLanguage expects string")
    assert(self.Languages[code], "Language not found: " .. tostring(code))
    self.CurrentLanguage = code
    self.Default.Language = code
    if self.WindowSettings then
        self.WindowSettings.SelectedLanguage = code
    end
    -- refresh all bound labels
    for _, entry in ipairs(self.LocalizedLabels) do
        if entry.Instance and entry.Instance.Parent then
            entry.Instance.Text = self:T(entry.Key)
        end
    end
    -- fire optional callback
    if type(self.OnLanguageChanged) == "function" then
        task.spawn(self.OnLanguageChanged, code)
    end
end

function Library:GetLanguage()
    return self.CurrentLanguage
end

--------------------------------------------------------------------
-- UTILS
--------------------------------------------------------------------
local ViewportSize = Camera.ViewportSize

local function Connect(signal, callback, method)
    method = method or "Connect"
    local conn = signal[method](signal, callback)
    table.insert(Library.Connections, conn)
    return conn
end

local function DeepGet(tbl, path)
    for key in string.gmatch(path, "[^%.]+") do
        tbl = tbl[key]
    end
    return tbl
end

local function ApplyThemeProperty(object, property, valuePath, theme)
    theme = theme or Library.CurrentTheme
    local value = type(valuePath) == "function" and valuePath() or DeepGet(theme, valuePath)
    object[property] = value
end

local function ApplyTheme(object, properties, theme)
    for prop, path in pairs(properties) do
        ApplyThemeProperty(object, prop, path, theme)
    end
end

local function EnsureFolder(path)
    if not makefolder then return end
    local parts = string.split(path, "/")
    parts[#parts] = nil
    local folder = table.concat(parts, "/")
    if folder ~= "" and (not isfolder or not isfolder(folder)) then
        makefolder(folder)
    end
end

local function SafeWriteFile(path, content)
    if not writefile then return false end
    EnsureFolder(path)
    writefile(path, content)
    return true
end

local function CreateTween(instance, property, goal, duration, style, direction, ...)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.22, style, direction, ...)
    return TweenService:Create(instance, info, {[property] = goal})
end

local function ToSet(list)
    local set = {}
    for _, v in ipairs(list) do
        set[v] = true
    end
    return set
end

local SPECIAL_CHARS = ToSet(string.split("\n\t,_:;()[]#&=!. \"'*^<>$", ""))

local function CleanString(str)
    return string.gsub(string.lower(str), ".", function(c)
        return SPECIAL_CHARS[c] and "" or c
    end)
end

local function FormatNumber(n)
    local s = tostring(n)
    local result = ""
    local count = 0
    for i = #s, 1, -1 do
        result = s:sub(i, i) .. result
        count = count + 1
        if i > 1 and count % 3 == 0 then
            result = "," .. result
        end
    end
    return result
end

local function IsAssetId(str)
    return string.sub(tostring(str), 1, 13) == "rbxassetid://"
end

local function NormalizeAssetId(id)
    if id == nil or id == "" then return nil end
    id = tostring(id):gsub("%s+", "")
    if id == "" then return nil end
    if IsAssetId(id) then return id end
    -- allow pure number or number as string
    if tonumber(id) then
        return "rbxassetid://" .. id
    end
    return id
end

local function ScaleValue(value)
    return (ViewportSize.Y / 450) * value
end

local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local hours = math.floor(seconds / 3600)
    seconds = math.floor((seconds - mins * 60) * 10) / 10
    mins = mins - hours * 60

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, mins, math.floor(seconds))
    elseif mins > 0 then
        return string.format("%dm %ds", mins, math.floor(seconds))
    else
        return tostring(seconds)
    end
end

local function PackCallback(cb)
    if cb == nil then return {} end
    if type(cb) ~= "function" and type(cb) ~= "table" then
        error(string.format("Callback must be function or table, got %s", typeof(cb)), 2)
    end
    if type(cb) ~= "function" then
        local obj, key = cb[1], cb[2]
        cb = function(value)
            obj[key] = value
        end
    end
    return table.pack(cb)
end

local function FireCallbacks(callbacks, ...)
    for i = 1, #callbacks do
        task.spawn(callbacks[i], ...)
    end
end

--------------------------------------------------------------------
-- THEME OBJECT SYSTEM
--------------------------------------------------------------------
local ThemeObject = {}
ThemeObject.__index = ThemeObject

function ThemeObject:add(instance, tags)
    self.Descendants[tags] = instance
    if self.IS_RENDERING then
        ApplyTheme(instance, tags)
    end
end

function ThemeObject:update()
    if self.IS_RENDERING and not self.UPDATED_OBJECTS then
        local theme = Library.CurrentTheme
        self.UPDATED_OBJECTS = true
        for tags, obj in pairs(self.Descendants) do
            if typeof(obj) == "table" then
                obj:update()
            else
                ApplyTheme(obj, tags, theme)
            end
        end
    end
end

function ThemeObject:destroy()
    if self.Parent then
        local idx = table.find(self.Parent.Descendants, self)
        if idx then table.remove(self.Parent.Descendants, idx) end
    end
    table.clear(self.Descendants)
    setmetatable(self, nil)
end

function ThemeObject:changeRendering(enabled)
    if self.IS_RENDERING ~= enabled then
        self.IS_RENDERING = enabled
        self.UPDATED_OBJECTS = false
    end
end

function ThemeObject:new()
    local obj = setmetatable({
        IS_RENDERING = true,
        UPDATED_OBJECTS = false,
        Descendants = {},
        Parent = self.Descendants ~= nil and self or nil
    }, ThemeObject)

    if self.Descendants then
        table.insert(self.Descendants, obj)
    end
    return obj
end

local RootTheme = ThemeObject:new()

--------------------------------------------------------------------
-- INSTANCE HELPERS
--------------------------------------------------------------------
local Creator = {}

local ElementBuilders = {
    Corner = function(radius)
        return Creator.new("UICorner", {
            CornerRadius = radius or UDim.new(0, 6)
        })
    end,
    Stroke = function(color, thickness)
        return Creator.new("UIStroke", {
            Color = color or Color3.fromRGB(50, 50, 58),
            Thickness = thickness or 0.8
        })
    end,
    Image = function(image)
        return Creator.new("ImageLabel", {
            Image = image or "",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1)
        })
    end,
    Button = function()
        return Creator.new("TextButton", {
            Text = "",
            Size = UDim2.fromScale(1, 1),
            AutoButtonColor = false
        })
    end,
    Padding = function(left, right, top, bottom)
        return Creator.new("UIPadding", {
            PaddingLeft = left or UDim.new(0, 8),
            PaddingRight = right or UDim.new(0, 8),
            PaddingTop = top or UDim.new(0, 8),
            PaddingBottom = bottom or UDim.new(0, 8)
        })
    end,
    ListLayout = function(padding)
        return Creator.new("UIListLayout", {
            Padding = padding or UDim.new(0, 4)
        })
    end,
    Text = function(text)
        return Creator.new("TextLabel", {
            BackgroundTransparency = 1,
            Text = text or ""
        })
    end,
    Gradient = function(color)
        return Creator.new("UIGradient", {
            Color = color
        })
    end
}

function Creator:Create(parent, name, ...)
    local builder = ElementBuilders[name]
    if builder then
        local el = builder(...)
        el.Parent = parent
        return el
    end
end

local Methods = {}

function Methods:Childs(children)
    for i = 1, #children do
        children[i].Parent = self
    end
end

function Methods:Elements(list)
    for name, config in pairs(list) do
        if type(config) == "table" then
            Creator.SetProperties(Creator:Create(self, name), config)
        else
            Creator:Create(self, name, config)
        end
    end
end

function Methods:ThemeTag(tags)
    local objects = tags.OBJECTS
    tags.OBJECTS = nil
    return (objects or RootTheme):add(self, tags)
end

function Creator:SetProperties(props)
    for key, value in pairs(props) do
        if Methods[key] then
            Methods[key](self, value)
        else
            self[key] = value
        end
    end
end

function Creator:SetValues(...)
    local instance = self
    for _, arg in ipairs({...}) do
        local t = typeof(arg)
        if t == "table" then
            Creator.SetProperties(instance, arg)
        else
            instance[t == "string" and "Name" or "Parent"] = arg
        end
    end
    return instance
end

function Creator.new(className, ...)
    return Creator.SetValues(Instance.new(className), ...)
end

local New = Creator.new

-- Dragging
local isDragging = false
local currentDrag = nil

function Creator:Draggable(scaleObj, speed, constrainFn)
    speed = speed or 0.28
    local startPos, startInputPos
    local lastMove = 0
    local cleanup

    local function onMove(input)
        local delta = input.Position - startInputPos
        local newPos
        lastMove = tick()

        if constrainFn then
            newPos = constrainFn(
                startPos.X.Scale, startPos.X.Offset + delta.X / scaleObj.Scale,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y / scaleObj.Scale
            )
        else
            newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X / scaleObj.Scale,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y / scaleObj.Scale
            )
        end
        self.Position = self.Position:Lerp(newPos, speed)
    end

    local function idleCheck()
        while currentDrag == self do
            if (tick() - lastMove) >= 1 then
                cleanup()
                break
            end
            task.wait()
        end
    end

    local mouseButtons = {
        [Enum.UserInputType.MouseButton1] = true,
        [Enum.UserInputType.Touch] = true
    }
    local moveTypes = {
        [Enum.UserInputType.MouseMovement] = true,
        [Enum.UserInputType.Touch] = true
    }

    Connect(self.InputBegan, function(input)
        if not isDragging and currentDrag == nil and mouseButtons[input.UserInputType] then
            startInputPos = input.Position
            startPos = self.Position
            currentDrag = self
            lastMove = tick()
            isDragging = true

            local changedConn
            function cleanup()
                isDragging = false
                currentDrag = nil
                if changedConn then changedConn:Disconnect() end
            end

            task.spawn(idleCheck)

            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    cleanup()
                end
            end)
        end
    end)

    Connect(UserInputService.InputChanged, function(input)
        if currentDrag == self and moveTypes[input.UserInputType] then
            onMove(input)
        end
    end)
end

--------------------------------------------------------------------
-- SCREEN GUI
--------------------------------------------------------------------
local LibraryName = "NNVN-Lib"
local ScreenGui = CoreGui:FindFirstChild(LibraryName)

if not ScreenGui then
    ScreenGui = New("ScreenGui", LibraryName, CoreGui, {
        IgnoreGuiInset = true
    })
end

local ScaleLimits = {
    MAX_SCALE = 1.6,
    MIN_SCALE = 0.6,
    TEXTBOX = {
        PLACEHOLDER_TEXT = "Input"
    }
}

--------------------------------------------------------------------
-- OPTION BASE
--------------------------------------------------------------------
local Option = {}
Option.__index = Option

function Option:SetTitle(text)
    assert(type(text) == "string", "Option.SetTitle expects string")
    assert(self.TITLE_LABEL, "Cannot change title of this option")
    self.TITLE_LABEL.Text = text
    self.Title = text
    return self
end

function Option:SetDescription(text)
    assert(text == nil or type(text) == "string", "Option.SetDescription expects string or nil")
    assert(self.DESCRIPTION_LABEL, "Cannot change description of this option")
    self.DESCRIPTION_LABEL.Text = text or ""
    self.Description = text
    return self
end

function Option:SetVisible(visible)
    assert(typeof(self.VISIBLE_ELEMENT) == "Instance", "Cannot change visibility")
    assert(type(visible) == "boolean", "SetVisible expects boolean")
    self.VISIBLE_ELEMENT.Visible = visible
end

function Option:Destroy()
    assert(typeof(self.DESTROY_ELEMENT) == "Instance", "Cannot destroy this option")
    self.DESTROY_ELEMENT:Destroy()
    setmetatable(self, nil)
    self.Destroyed = true
end

function Option:AddCallback(fn)
    assert(self.CALLBACKS, "Cannot add callback to this option")
    assert(type(fn) == "function", "AddCallback expects function")
    table.insert(self.CALLBACKS, fn)
    return self
end

Option.NewCallback = Option.AddCallback
Option.SetContent = Option.SetDescription
Option.SetDesc = Option.SetDescription

--------------------------------------------------------------------
-- SPECIALIZED OPTIONS
--------------------------------------------------------------------
local TextBoxOpt = setmetatable({}, {__index = function(_, k) return Option[k] end})
TextBoxOpt.__index = TextBoxOpt

function TextBoxOpt:SetText(text)
    assert(type(text) == "string", "SetText expects string")
    self.TEXTBOX.Text = text
    return self
end

function TextBoxOpt:SetPlaceholder(text)
    assert(type(text) == "string", "SetPlaceholder expects string")
    self.TEXTBOX.PlaceholderText = text
    return self
end

function TextBoxOpt:CaptureFocus()
    self.TEXTBOX:CaptureFocus()
    return self
end

function TextBoxOpt:Clear()
    self.TEXTBOX.Text = ""
    return self
end

function TextBoxOpt:SetTextFilter(fn)
    if fn ~= nil then
        assert(type(fn) == "function", "SetTextFilter expects function or nil")
    end
    self.TEXTBOX_TEXT_FILTER = fn
    return self
end

function TextBoxOpt.new(parent, titleLabel, descLabel, button, textbox, callbacks)
    return setmetatable({
        Title = titleLabel.Text,
        Description = descLabel.Text,
        DESCRIPTION_LABEL = descLabel,
        TITLE_LABEL = titleLabel,
        CALLBACKS = callbacks,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TEXTBOX = textbox,
        BUTTON = button,
        Parent = parent,
        Kind = "TextBox"
    }, TextBoxOpt)
end

local ToggleOpt = setmetatable({}, {__index = function(_, k) return Option[k] end})
ToggleOpt.__index = ToggleOpt

function ToggleOpt:SetValue(value)
    assert(type(value) == "boolean", "SetValue expects boolean")
    if self.Value ~= value then
        self.Value = value
        self.WHEN_VALUE_CHANGED(value)
    end
end

function ToggleOpt.new(parent, button, titleLabel, descLabel, whenChanged, callbacks)
    return setmetatable({
        CALLBACKS = callbacks,
        WHEN_VALUE_CHANGED = whenChanged,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Description = descLabel.Text,
        Title = titleLabel.Text,
        Parent = parent,
        Kind = "Toggle"
    }, ToggleOpt)
end

local SliderOpt = setmetatable({}, {__index = function(_, k) return Option[k] end})
SliderOpt.__index = SliderOpt

function SliderOpt:SetValue(value)
    assert(type(value) == "number", "SetValue expects number")
    if self.Value ~= value then
        self.WHEN_VALUE_CHANGED(value)
    end
end

function SliderOpt.new(parent, button, titleLabel, descLabel, callbacks)
    return setmetatable({
        CALLBACKS = callbacks,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Description = descLabel.Text,
        Title = titleLabel.Text,
        Parent = parent,
        Kind = "Slider"
    }, SliderOpt)
end

local DropdownOpt = setmetatable({}, {__index = function(_, k) return Option[k] end})
DropdownOpt.__index = DropdownOpt

function DropdownOpt:SetEnabled(list)
    assert(type(list) == "table", "SetEnabled expects table")
    self.SET_ENABLED_OPTIONS(list)
end

function DropdownOpt:Clear()
    self.CLEAR_DROPDOWN()
end

function DropdownOpt:NewOptions(...)
    self:Clear()
    self:Add(...)
end

function DropdownOpt:GetOptionsCount()
    return #self.DROPDOWN_OPTIONS
end

function DropdownOpt:Remove(...)
    local opts = {...}
    assert(#opts > 0, "Remove requires one or more options")
    for _, opt in ipairs(opts) do
        self.REMOVE_DROPDOWN_OPTION(opt)
    end
end

function DropdownOpt:Add(...)
    local opts = {...}
    assert(#opts > 0, "Add requires one or more options")
    for _, opt in ipairs(opts) do
        self.ADD_DROPDOWN_OPTION(opt)
    end
end

function DropdownOpt.new(parent, button, titleLabel, descLabel, callbacks)
    return setmetatable({
        CALLBACKS = callbacks,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Description = descLabel.Text,
        Title = titleLabel.Text,
        Parent = parent,
        Kind = "Dropdown"
    }, DropdownOpt)
end

local DialogOpt = setmetatable({}, {__index = function(_, k) return Option[k] end})
DialogOpt.__index = DialogOpt

local currentDialog = nil
local dialogOutBox = nil

local function CloseDialogInternal()
    if not currentDialog then return end
    currentDialog.Closed = true
    currentDialog.Closing = false
    setmetatable(currentDialog, nil)
    currentDialog = nil
    if dialogOutBox then
        dialogOutBox.Parent = nil
    end
end

local function ForceCloseDialog()
    if currentDialog then
        currentDialog:Close()
    end
end

function DialogOpt:NewOption(config)
    local name = config[1] or config.Name or config.Title
    local callbacks = PackCallback(config[2] or config.Callback)
    table.insert(callbacks, ForceCloseDialog)

    assert(type(name) == "string", "Dialog option name must be string")

    local btn = New("TextButton", {
        AutoButtonColor = false,
        Size = UDim2.fromScale(0.2, 1),
        BackgroundTransparency = 1,
        TextSize = 10,
        Text = name,
        Elements = {
            Corner = UDim.new(1, 0)
        },
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default",
            TextColor3 = "Colors.Text.Dark",
            Font = "Font.Normal"
        }
    })

    local fadeIn = CreateTween(btn, "BackgroundTransparency", 0, 0.3)
    local fadeOut = CreateTween(btn, "BackgroundTransparency", 1, 0.3)

    Connect(btn.MouseLeave, function() fadeOut:Play() end)
    Connect(btn.MouseEnter, function() fadeIn:Play() end)
    Connect(btn.Activated, function() FireCallbacks(callbacks) end)

    btn.Parent = dialogOutBox.Template.Options
end

function DialogOpt:Close(wait)
    if self.Closed or self.Closing or currentDialog ~= self then
        return
    end
    self.Closing = true
    local tween = CreateTween(self.TEMPLATE, "Size", self.NEW_SIZE, 0.1)
    tween:Play()
    if wait then
        tween.Completed:Wait()
        CloseDialogInternal()
    else
        Connect(tween.Completed, CloseDialogInternal)
    end
end

function DialogOpt.new(descLabel, titleLabel)
    return setmetatable({
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Content = descLabel.Text,
        Title = titleLabel.Text,
        Closed = false,
        Closing = false,
        Kind = "Dialog"
    }, DialogOpt)
end

--------------------------------------------------------------------
-- WINDOW STATE
--------------------------------------------------------------------
local TabsList = {}
local TabElements = {}   -- [tab] = { SelectTabButton, Container }
local TabThemes = {}     -- [tab] = ThemeObject
local TabSelectors = {}  -- [tab] = { Select, Unselect }
local SelectedTab = nil
local MainFrame = nil
local UIScaleObj = nil
local FlagsTable = nil
local DropdownHolder = nil
local WindowMinimized = false
local DefaultNotifyIcon = ""

local WindowAPI = {}
WindowAPI.__index = WindowAPI

local TabAPI = {}
TabAPI.__index = TabAPI

local MinimizerAPI = {}
MinimizerAPI.__index = MinimizerAPI

--------------------------------------------------------------------
-- HELPER: Create Option Row
--------------------------------------------------------------------
local function CreateOptionRow(tab, title, description, contentSize)
    local themeObj = TabThemes[tab]
    local container = TabElements[tab].Container

    local titleLabel = New("TextLabel", {
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -12),
        Position = UDim2.fromScale(0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        TextSize = 12,
        ThemeTag = {
            OBJECTS = RootTheme,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Medium"
        }
    })

    local descLabel = New("TextLabel", {
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, -12),
        Position = UDim2.new(0, 10, 0, 13),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 10,
        RichText = true,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Dark",
            Font = "Font.Normal"
        }
    })

    local themeTag = {
        OBJECTS = themeObj,
        BackgroundColor3 = "Colors.Buttons.Default"
    }

    local button = New("TextButton", "Option", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 26),
        AutoButtonColor = false,
        Text = "",
        ThemeTag = themeTag,
        Elements = {
            Corner = UDim.new(0, 6)
        },
        Childs = {
            New("Frame", "Holder", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = contentSize,
                Elements = {
                    ListLayout = {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 2)
                    },
                    Padding = {
                        PaddingBottom = UDim.new(0, 6),
                        PaddingTop = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 8)
                    }
                },
                Childs = { titleLabel, descLabel }
            })
        }
    })

    local holder = button.Holder
    local hoverTarget = nil

    local function setHover(colorPath, isHover)
        if isHover then
            if hoverTarget then
                local defaultColor = DeepGet(Library.CurrentTheme, "Colors.Buttons.Default")
                hoverTarget.Theme.BackgroundColor3 = "Colors.Buttons.Default"
                CreateTween(hoverTarget.Button, "BackgroundColor3", defaultColor, 0.15):Play()
            end
            hoverTarget = { Button = button, Theme = themeTag }
        end
        themeTag.BackgroundColor3 = colorPath
        CreateTween(button, "BackgroundColor3", DeepGet(Library.CurrentTheme, colorPath), 0.15):Play()
    end

    Connect(button.MouseLeave, function() setHover("Colors.Buttons.Default", false) end)
    Connect(button.MouseEnter, function() setHover("Colors.Buttons.Holding", true) end)

    Connect(descLabel:GetPropertyChangedSignal("Text"), function()
        local hasDesc = #descLabel.Text > 0
        if descLabel.Visible ~= hasDesc then
            local scale = hasDesc and 0 or 0.5
            descLabel.Visible = hasDesc
            holder.Position = UDim2.fromScale(0, scale)
            holder.AnchorPoint = Vector2.new(0, scale)
        end
    end)

    titleLabel.Text = title
    descLabel.Text = description or ""
    button.Parent = container

    return button, titleLabel, descLabel
end

local function ParseOptionConfig(kind, config)
    if type(config) ~= "table" then
        error(string.format("Tab.Add%s[Configs] expects table, got %s", kind, typeof(config)), 2)
    end
    local title = config[1] or config.Name or config.Title
    local desc = config.Desc or config.Description
    assert(type(title) == "string", string.format("Tab.Add%s.Title expects string", kind))
    if desc ~= nil and type(desc) ~= "string" then
        error(string.format("Tab.Add%s.Description expects string or nil", kind), 2)
    end
    return title, desc or ""
end

local function ParseFlag(kind, flag)
    if flag ~= nil and type(flag) ~= "string" then
        error(string.format("Tab.Add%s.Flag expects string or nil", kind))
    end
    return flag
end

--------------------------------------------------------------------
-- DROPDOWN SYSTEM (with Search)
--------------------------------------------------------------------
local DropdownSystem = nil

local function CreateDropdownSystem()
    local DROPDOWN_WIDTH = 150
    local SEARCH_WIDTH = 120
    local OPTION_HEIGHT = 22
    local MAX_VISIBLE = 10
    local MAX_HEIGHT = (OPTION_HEIGHT * MAX_VISIBLE) + 8
    local MARGIN = 4

    local elements = {
        Corner = UDim.new(0, 5),
        Stroke = {
            ThemeTag = { Color = "Colors.Stroke" }
        },
        Gradient = {
            Rotation = 45,
            ThemeTag = { Color = "Colors.Background" }
        }
    }

    local outBox = New("TextButton", "OutBox", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Active = true,
        Text = ""
    })

    local dropdownFrame = New("Frame", "Dropdown", outBox, {
        Size = UDim2.fromOffset(DROPDOWN_WIDTH, 100),
        Position = UDim2.fromOffset(50, 50),
        Elements = elements,
        Active = true,
        ThemeTag = {
            BackgroundTransparency = "BackgroundTransparency"
        }
    })

    local searchBtn = New("TextButton", "Search", dropdownFrame, {
        Position = UDim2.new(1, 5, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        AutomaticSize = Enum.AutomaticSize.X,
        Active = true,
        Elements = elements,
        Text = "",
        ThemeTag = {
            BackgroundTransparency = "BackgroundTransparency"
        },
        Childs = {
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5)
            }),
            New("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Horizontal
            }),
            New("TextBox", "SearchBox", {
                Size = UDim2.fromScale(0, 1),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Visible = false,
                PlaceholderText = Library:T("Search"),
                ClearTextOnFocus = false,
                Text = "",
                Elements = {
                    Corner = UDim.new(0, 6)
                },
                ThemeTag = {
                    BackgroundColor3 = "Colors.Stroke",
                    TextColor3 = "Colors.Text.Default",
                    Font = "Font.ExtraBold"
                }
            }),
            New("ImageLabel", "SearchIcon", {
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ThemeTag = {
                    BackgroundColor3 = "Colors.Stroke",
                    ImageColor3 = "Colors.Icons",
                    Image = "Icons.Search"
                }
            })
        }
    })

    local scroll = New("ScrollingFrame", dropdownFrame, {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ScrollBarThickness = 3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = true,
        ThemeTag = {
            OBJECTS = RootTheme,
            ScrollBarImageColor3 = "Colors.ScrollBar"
        },
        Elements = {
            Padding = {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            },
            ListLayout = {
                Padding = UDim.new(0, 4)
            }
        }
    })

    local searchIcon = searchBtn.SearchIcon
    local searchBox = searchBtn.SearchBox

    local closeTween = CreateTween(dropdownFrame, "Size", UDim2.fromOffset(DROPDOWN_WIDTH, 0), 0.18)
    local openSearchTween = CreateTween(searchBox, "Size", UDim2.new(0, SEARCH_WIDTH - 28, 1, 0), 0.22)
    local closeSearchTween = CreateTween(searchBox, "Size", UDim2.new(0, 0, 1, 0), 0.16)

    local activeOptions = {}
    local isClosing = false
    local isSearchOpen = false
    local onCloseCallback = nil
    local onSelectCallback = nil
    local isMulti = false
    local holderElement = nil
    local lastSearchInteract = 0
    local searchResultCount = 0
    local currentOptions = nil

    local function calcHeight(count)
        local maxH = ScreenGui.AbsoluteSize.Y / UIScaleObj.Scale
        return math.min((OPTION_HEIGHT * math.max(count, 0.5)) + 10, MAX_HEIGHT, maxH / 1.75)
    end

    local function isMouseOver()
        local pos = dropdownFrame.AbsolutePosition
        local size = dropdownFrame.AbsoluteSize
        local mx, my = Mouse.X, Mouse.Y
        return mx >= pos.X and mx <= (pos.X + size.X) and my >= pos.Y and my <= (pos.Y + size.Y)
    end

    local function calcPosition(count)
        local absPos = holderElement.AbsolutePosition
        local absSize = holderElement.AbsoluteSize
        local screen = ScreenGui.AbsoluteSize
        local scale = UIScaleObj.Scale
        local height = calcHeight(count)

        local screenW = screen.X / scale
        local screenH = screen.Y / scale
        local x = absPos.X / scale
        local y = absPos.Y / scale
        local w = absSize.X / scale
        local h = absSize.Y / scale

        local centerY = y + (h / 2)
        local topY = centerY - (height / 2)

        local minY = MARGIN
        local maxY = screenH - height - MARGIN
        local finalY = math.clamp(topY, minY, maxY)

        local anchor = Vector2.new(0, 0)
        if finalY > (screenH * 0.7) then
            anchor = Vector2.new(0, 1)
            finalY = math.min(centerY + (height / 2), screenH - MARGIN)
        end

        local finalX = math.clamp(
            x,
            MARGIN,
            screenW - dropdownFrame.Size.X.Offset - (MARGIN * 2) - (searchBtn.AbsoluteSize.X / scale)
        )

        return Vector2.new(finalX, finalY), anchor
    end

    local function applyPosition(...)
        local pos, anchor = calcPosition(...)
        dropdownFrame.AnchorPoint = anchor
        dropdownFrame.Position = UDim2.fromOffset(pos.X, pos.Y)
    end

    local function closeSearch()
        if not isSearchOpen then return end
        isSearchOpen = false
        searchBox.Text = ""
        closeSearchTween:Play()
        closeSearchTween.Completed:Wait()
        searchBox.Visible = false
    end

    local function openSearch()
        if isSearchOpen then return end
        isSearchOpen = true
        searchBox.Visible = true
        openSearchTween:Play()
        searchBox:CaptureFocus()

        -- shift if needed
        local absSize = dropdownFrame.AbsoluteSize
        local screen = ScreenGui.AbsoluteSize
        local scale = UIScaleObj.Scale
        local searchW = SEARCH_WIDTH * scale
        local right = dropdownFrame.AbsolutePosition.X + absSize.X + 5 + searchW
        if right > screen.X - (MARGIN * scale) then
            local newX = (screen.X - absSize.X - searchW - 5 - (MARGIN * scale)) / scale
            newX = math.max(newX, MARGIN)
            CreateTween(dropdownFrame, "Position", UDim2.fromOffset(newX, dropdownFrame.Position.Y.Offset), 0.3):Play()
        end
    end

    local function tryOpen(closeCb)
        if not isClosing then
            onCloseCallback = closeCb
            outBox.Parent = DropdownHolder
            return true
        end
    end

    local function closeDropdown()
        if isClosing then return end
        if onCloseCallback then
            onCloseCallback()
            onCloseCallback = nil
        end
        task.spawn(closeSearch)
        isClosing = true
        closeTween:Play()
        closeTween.Completed:Wait()
        outBox.Parent = nil
        isClosing = false
    end

    local function checkOutsideClick()
        if searchBox:IsFocused() then
            lastSearchInteract = tick()
            return
        end
        if (tick() - lastSearchInteract) >= 0.3 and not isMouseOver() then
            closeDropdown()
        end
    end

    local function clearOptions()
        for inst in pairs(activeOptions) do
            inst.Parent = nil
            activeOptions[inst] = nil
        end
    end

    local function setOptionVisual(opt, selected)
        opt.Selected = selected
        if opt.Instance then
            local inst = opt.Instance
            local label = inst.TextLabel
            local indicator = inst.Frame
            local bgT = selected and 0 or (isMulti and 0.8 or 1)
            local textT = selected and 0 or 0.4
            local size = UDim2.fromOffset(4, selected and 14 or 4)

            if inst.Parent then
                CreateTween(indicator, "BackgroundTransparency", bgT, 0.2):Play()
                CreateTween(label, "TextTransparency", textT, 0.2):Play()
                CreateTween(indicator, "Size", size, 0.2):Play()
            else
                label.TextTransparency = textT
                indicator.BackgroundTransparency = bgT
                indicator.Size = size
            end
        end
    end

    local function updateSearchVisibility(opt)
        if not searchBox.Visible or not opt then
            local count = currentOptions and #currentOptions or 0
            dropdownFrame.Size = UDim2.fromOffset(DROPDOWN_WIDTH, calcHeight(count))
            return
        end
        local inst = opt.Instance
        local query = CleanString(searchBox.Text)
        inst.Visible = #query == 0 or opt.SearchText:find(query) ~= nil
        if inst.Visible then
            searchResultCount = searchResultCount + 1
            dropdownFrame.Size = UDim2.fromOffset(DROPDOWN_WIDTH, calcHeight(searchResultCount))
        end
    end

    local function matchFilter(opt, prefix, query, searchText)
        local ok = true
        if prefix == "+" or prefix == "-" then
            ok = opt.Selected == (prefix == "+")
            query = query:sub(2)
        end
        return ok and searchText:find(query, 1, true) ~= nil
    end

    local function createOptionTemplate(opt, addToScroll)
        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 21),
            AutoButtonColor = false,
            Text = "",
            Elements = {
                Corner = UDim.new(0, 4)
            },
            ThemeTag = {
                BackgroundColor3 = "Colors.Buttons.Default"
            },
            Childs = {
                New("Frame", {
                    Position = UDim2.new(0, 1, 0.5),
                    Size = UDim2.new(0, 4, 0, 4),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Elements = {
                        Corner = UDim.new(0.5, 0)
                    },
                    ThemeTag = {
                        BackgroundColor3 = "Colors.Primary"
                    }
                }),
                New("TextLabel", {
                    Size = UDim2.fromScale(1, 1),
                    Position = UDim2.fromOffset(10, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    TextTransparency = 0.4,
                    Text = opt.DisplayName,
                    TextSize = 9,
                    ThemeTag = {
                        Font = "Font.Bold",
                        TextColor3 = "Colors.Text.Default"
                    }
                })
            }
        })

        local lastClick = 0
        Connect(btn.Activated, function()
            if (tick() - lastClick) < 0 then return end
            if outBox.Parent and not isClosing then
                lastClick = tick() + 0.2
                onSelectCallback(opt)
            end
        end)

        opt.SearchText = CleanString(opt.DisplayName)
        opt.Instance = btn

        if addToScroll then
            local text = searchBox.Text
            if #text > 0 then
                local prefix = string.sub(text, 1, 1)
                local cleaned = CleanString(text)
                btn.Visible = matchFilter(opt, prefix, cleaned, opt.SearchText)
            end
            btn.Parent = scroll
            updateSearchVisibility(opt)
        end

        setOptionVisual(opt, opt.Selected)
    end

    local function setOptions(list)
        clearOptions()
        currentOptions = list
        for i = 1, #list do
            local opt = list[i]
            if opt.Instance == nil then
                createOptionTemplate(opt)
            end
            opt.Instance.Parent = scroll
            activeOptions[opt.Instance] = true
        end
        applyPosition(#list)
        CreateTween(dropdownFrame, "Size", UDim2.fromOffset(DROPDOWN_WIDTH, calcHeight(#list)), 0.2):Play()
    end

    local function onSearchTextChanged()
        local text = searchBox.Text
        local prefix = string.sub(text, 1, 1)
        local cleaned = CleanString(text)
        local empty = #cleaned == 0
        local count = 0

        if not currentOptions then return end
        for i = 1, #currentOptions do
            local opt = currentOptions[i]
            local visible = empty or matchFilter(opt, prefix, cleaned, opt.SearchText)
            opt.Instance.Visible = visible
            if visible then count = count + 1 end
        end
        searchResultCount = count
        dropdownFrame.Size = UDim2.fromOffset(DROPDOWN_WIDTH, calcHeight(count))
    end

    Connect(MainFrame and MainFrame:GetPropertyChangedSignal("Visible") or Instance.new("BindableEvent").Event, checkOutsideClick)
    Connect(outBox.MouseButton1Down, checkOutsideClick)
    Connect(outBox.Activated, checkOutsideClick)
    Connect(searchBtn.Activated, openSearch)
    Connect(searchBox:GetPropertyChangedSignal("Text"), onSearchTextChanged)

    return table.freeze({
        CreateOptionTemplate = createOptionTemplate,
        SetOptionValue = setOptionVisual,
        CloseDropdown = closeDropdown,
        OpenDropdown = tryOpen,
        SetOptions = setOptions,
        Clear = clearOptions,
        SetOnClicked = function(cb) onSelectCallback = cb end,
        SetMultiSelect = function(v) isMulti = v end,
        SetHolder = function(h) holderElement = h end
    })
end

--------------------------------------------------------------------
-- TAB METHODS
--------------------------------------------------------------------
function TabAPI:GetNoSelfCall(name)
    assert(type(name) == "string", "GetNoSelfCall expects string")
    local fn = self[name]
    assert(type(fn) == "function", string.format("%s is not a function", name))
    return function(...)
        return fn(self, ...)
    end
end

function TabAPI:AddSection(title)
    assert(title == nil or type(title) == "string", "AddSection expects string or nil")
    title = title or ""

    local themeObj = TabThemes[self]
    local frame = New("Frame", "Option", TabElements[self].Container, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1
    })

    local label = New("TextLabel", frame, {
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 4),
        BackgroundTransparency = 1,
        TextSize = 14,
        Text = title,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    return setmetatable({
        Title = title,
        DESTROY_ELEMENT = frame,
        VISIBLE_ELEMENT = frame,
        TITLE_LABEL = label,
        Kind = "Section",
        Parent = self
    }, Option)
end

function TabAPI:AddToggle(config)
    local title, desc = ParseOptionConfig("Toggle", config)
    local flag = ParseFlag("Toggle", config[4] or config.Flag)
    local default = config[2] or config.Default or false
    local callbacks = PackCallback(config[3] or config.Callback)

    if type(default) ~= "boolean" then
        error("Toggle.Default expects boolean", 2)
    end
    if flag and type(FlagsTable[flag]) == "number" then
        default = FlagsTable[flag] == 0
    end

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(1, -38, 0, 0))

    local track = New("Frame", button, {
        Size = UDim2.new(0, 32, 0, 16),
        Position = UDim2.new(1, -8, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        Elements = {
            Corner = UDim.new(0.5, 0)
        },
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Stroke"
        }
    })

    local knobHolder = New("Frame", track, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.82, 0, 0.82, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })

    local knobTheme = {
        OBJECTS = themeObj,
        BackgroundColor3 = "Colors.OnPrimary"
    }

    local knob = New("Frame", knobHolder, {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        Elements = {
            Corner = UDim.new(0.5, 0)
        },
        ThemeTag = knobTheme
    })

    local lastChange = tick()
    local cooldown = 0.15
    local playingTweens = {}

    local function playTweens(list)
        playingTweens = {}
        for i, t in ipairs(list) do
            t:Play()
            playingTweens[i] = t
        end
    end

    local function cancelTweens()
        for i = #playingTweens, 1, -1 do
            local t = playingTweens[i]
            if t.PlaybackState == Enum.PlaybackState.Playing then
                t:Cancel()
            end
            playingTweens[i] = nil
        end
    end

    local function onValueChanged(value)
        if flag then FlagsTable[flag] = value and 0 or 1 end
        FireCallbacks(callbacks, value)

        local pos = UDim2.new(value and 1 or 0, 0, 0.5, 0)
        local anchor = Vector2.new(value and 1 or 0, 0.5)
        local colorPath = value and "Colors.Primary" or "Colors.OnPrimary"
        local color = DeepGet(Library.CurrentTheme, colorPath)
        knobTheme.BackgroundColor3 = colorPath

        if self.Selected and (tick() - lastChange) >= cooldown then
            playTweens({
                CreateTween(knob, "Position", pos, 0.18),
                CreateTween(knob, "AnchorPoint", anchor, 0.18),
                CreateTween(knob, "BackgroundColor3", color, 0.18)
            })
        else
            cancelTweens()
            knob.Position = pos
            knob.AnchorPoint = anchor
            knob.BackgroundColor3 = color
        end
        lastChange = tick()
    end

    local toggle = ToggleOpt.new(self, button, titleLabel, descLabel, onValueChanged, callbacks)
    toggle:SetValue(default)

    local lastClick = 0
    Connect(button.Activated, function()
        if (tick() - lastClick) >= cooldown then
            lastClick = tick()
            toggle:SetValue(not toggle.Value)
        end
    end)

    return toggle
end

function TabAPI:AddButton(config)
    local title, desc = ParseOptionConfig("Button", config)
    local callbacks = PackCallback(config[2] or config.Callback)
    local debounce = config.Debounce or config.Cooldown

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(1, -20, 0, 0))

    New("ImageLabel", button, {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        ThemeTag = {
            OBJECTS = themeObj,
            Image = "Icons.Button"
        }
    })

    local lastClick = 0
    Connect(button.Activated, function()
        if debounce and (tick() - lastClick) < 0 then return end
        if debounce then lastClick = tick() + debounce end
        FireCallbacks(callbacks)
    end)

    return setmetatable({
        CALLBACKS = callbacks,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Title = title,
        Description = desc,
        Parent = self,
        Kind = "Button"
    }, Option)
end

function TabAPI:AddTextBox(config)
    local title, desc = ParseOptionConfig("TextBox", config)
    local flag = ParseFlag("TextBox", config[4] or config.Flag)
    local default = config[2] or config.Default
    local callbacks = PackCallback(config[3] or config.Callback)
    local placeholder = config.Placeholder or config.PlaceholderText
    local clearOnFocus = config.ClearOnFocus or config.ClearTextOnFocus

    if default ~= nil and type(default) ~= "string" then
        error("TextBox.Default expects string or nil", 2)
    end
    if flag and type(FlagsTable[flag]) == "string" then
        default = FlagsTable[flag]
    end

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(1, -150, 0, 0))

    local holder = New("Frame", button, {
        Size = UDim2.new(0, 130, 0, 16),
        Position = UDim2.new(1, -8, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Stroke"
        },
        Elements = {
            Corner = UDim.new(0, 4)
        }
    })

    local textbox = New("TextBox", holder, {
        Size = UDim2.new(0.86, 0, 0.86, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        TextScaled = true,
        Active = true,
        Text = "",
        PlaceholderText = Library:T("Input"),
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    local iconTheme = {
        OBJECTS = themeObj,
        Image = "Icons.TextBox",
        ImageColor3 = "Colors.Icons"
    }

    local icon = New("ImageLabel", holder, {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(0, -4, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        ThemeTag = iconTheme
    })

    if default then textbox.Text = default end
    if clearOnFocus ~= nil then textbox.ClearTextOnFocus = clearOnFocus end
    if placeholder then textbox.PlaceholderText = placeholder end

    local opt = TextBoxOpt.new(self, titleLabel, descLabel, button, textbox, callbacks)

    local function setIconColor(path)
        iconTheme.ImageColor3 = path
        CreateTween(icon, "ImageColor3", DeepGet(Library.CurrentTheme, path), 0.25):Play()
    end

    if flag then
        Connect(textbox:GetPropertyChangedSignal("Text"), function()
            FlagsTable[flag] = textbox.Text
        end)
    end

    Connect(textbox.Focused, function() setIconColor("Colors.Primary") end)
    Connect(textbox.FocusLost, function()
        setIconColor("Colors.Icons")
        local filter = opt.TEXTBOX_TEXT_FILTER
        if filter then
            local filtered = filter(textbox.Text)
            if type(filtered) == "string" then
                textbox.Text = filtered
            end
        end
        FireCallbacks(callbacks, textbox.Text)
    end)

    Connect(button.Activated, function()
        textbox:CaptureFocus()
    end)

    return opt
end

function TabAPI:AddSlider(config)
    local title, desc = ParseOptionConfig("Slider", config)
    local flag = ParseFlag("Slider", config[7] or config.Flag)
    local min = config[2] or config.Min
    local max = config[3] or config.Max
    local increment = config[4] or config.Increment
    local default = config[5] or config.Default
    local callbacks = PackCallback(config[6] or config.Callback)

    if increment ~= nil and type(increment) ~= "number" then
        error("Slider.Increment expects number or nil", 2)
    end
    if default ~= nil and type(default) ~= "number" then
        error("Slider.Default expects number or nil", 2)
    end
    assert(type(min) == "number", "Slider.Min expects number")
    assert(type(max) == "number", "Slider.Max expects number")

    local themeObj = TabThemes[self]
    local container = TabElements[self].Container
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(0.55, 0, 0, 0))

    if default == nil then default = min end
    if increment == nil then increment = 1 end
    if flag and type(FlagsTable[flag]) == "number" then
        default = FlagsTable[flag]
    end

    local sliderBtn = New("TextButton", button, {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Text = ""
    })

    local bar = New("Frame", sliderBtn, {
        Size = UDim2.new(1, -16, 0, 5),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Stroke"
        },
        Elements = {
            Corner = UDim.new(0.5, 0)
        }
    })

    local fill = New("Frame", bar, {
        Size = UDim2.fromScale(0, 1),
        BorderSizePixel = 0,
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Primary"
        },
        Elements = {
            Corner = UDim.new(0.5, 0)
        }
    })

    local thumb = New("Frame", bar, {
        Size = UDim2.new(0, 5, 0, 11),
        BackgroundColor3 = Color3.fromRGB(245, 245, 250),
        Position = UDim2.fromScale(0, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.1,
        Elements = {
            Corner = UDim.new(0, 5)
        }
    })

    local valueLabel = New("TextLabel", sliderBtn, {
        Size = UDim2.new(0, 42, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0, -1, 0.5, 0),
        BackgroundTransparency = 1,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.SliderValue"
        }
    })

    local valueScale = New("UIScale", valueLabel)

    local slider = SliderOpt.new(self, button, titleLabel, descLabel, callbacks)
    slider.Min = min
    slider.Max = max
    slider.Increment = increment

    local function toRatio(v) return (v - min) / (max - min) end
    local function fromRatio(r) return (r * (max - min)) + min end
    local function snap(v) return math.round(v / increment) * increment end

    local function applyValue(value, ratio)
        if value == slider.Value then return end
        if flag then FlagsTable[flag] = value end
        task.defer(FireCallbacks, callbacks, value)
        slider.Value = value

        local thumbPos = UDim2.fromScale(ratio, 0.5)
        local fillSize = UDim2.fromScale(ratio, 1)
        valueLabel.Text = tostring(math.floor(value * 1000) / 1000)

        if self.Selected then
            CreateTween(thumb, "Position", thumbPos, 0.18):Play()
            CreateTween(fill, "Size", fillSize, 0.18):Play()
        else
            thumb.Position = thumbPos
            fill.Size = fillSize
        end
    end

    local function setValue(raw)
        local v = math.clamp(snap(raw), min, max)
        applyValue(v, toRatio(v))
    end

    slider.WHEN_VALUE_CHANGED = setValue

    local function onDrag(barPos, barSize)
        local ratio = math.clamp((Mouse.X - barPos.X) / barSize.X, 0, 1)
        local raw = fromRatio(ratio)
        local snapped = math.clamp(snap(raw), min, max)
        applyValue(snapped, toRatio(snapped))
    end

    local rng = Random.new()
    setValue(default)

    Connect(sliderBtn.MouseButton1Down, function()
        if isDragging then return end
        CreateTween(thumb, "BackgroundTransparency", 0, 0.15):Play()
        container.ScrollingEnabled = false
        isDragging = true

        local pos = bar.AbsolutePosition
        local size = bar.AbsoluteSize

        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            onDrag(pos, size)
            task.wait()
        end

        isDragging = false
        CreateTween(thumb, "BackgroundTransparency", 0.1, 0.18):Play()
        container.ScrollingEnabled = true
    end)

    Connect(valueLabel:GetPropertyChangedSignal("Text"), function()
        if not self.Selected then return end
        valueScale.Scale = 0.5
        CreateTween(valueScale, "Scale", 1.12, 0.08):Play()
        local rot = CreateTween(valueLabel, "Rotation", rng:NextNumber(-5, 5), 0.1)
        rot:Play()
        rot.Completed:Wait()
        CreateTween(valueScale, "Scale", 1, 0.12):Play()
        CreateTween(valueLabel, "Rotation", 0, 0.08):Play()
    end)

    return slider
end

function TabAPI:AddDropdown(config)
    local title, desc = ParseOptionConfig("Dropdown", config)
    local flag = ParseFlag("Dropdown", config[5] or config.Flag)
    local options = config[2] or config.Options
    local default = config[3] or config.Default
    local callbacks = PackCallback(config[4] or config.Callback)
    local multi = config.MultiSelect

    if default ~= nil and type(default) ~= "table" and type(default) ~= "string" then
        error("Dropdown.Default expects string, table or nil", 2)
    end
    if options ~= nil and type(options) ~= "table" then
        error("Dropdown.Options expects table or nil", 2)
    end
    if multi ~= nil and type(multi) ~= "boolean" then
        error("Dropdown.MultiSelect expects boolean or nil", 2)
    end

    if flag and type(FlagsTable[flag]) == (multi and "table" or "string") then
        default = FlagsTable[flag]
    end

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(1, -150, 0, 0))

    local holder = New("Frame", button, {
        Size = UDim2.new(0, 130, 0, 16),
        Position = UDim2.new(1, -8, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        Elements = {
            Corner = UDim.new(0, 4)
        },
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Stroke"
        }
    })

    local valueLabel = New("TextLabel", holder, {
        Size = UDim2.new(0.86, 0, 0.86, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        TextScaled = true,
        Text = "...",
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    local iconTheme = {
        OBJECTS = themeObj,
        Image = "Icons.Dropdown.Open",
        ImageColor3 = "Colors.Icons"
    }

    local icon = New("ImageLabel", holder, {
        Size = UDim2.new(0, 13, 0, 13),
        Position = UDim2.new(0, -4, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        ThemeTag = iconTheme
    })

    local dropdown = DropdownOpt.new(self, button, titleLabel, descLabel, callbacks)

    local selectedSingle = nil
    local isOpen = false
    local isDirty = false
    local multiState = {}
    local pending = {}
    local optionList = {}
    local optionMap = {}

    dropdown.DROPDOWN_OPTIONS = optionList
    dropdown.Opened = isOpen

    local function setIcon(colorPath, imagePath)
        iconTheme.ImageColor3 = colorPath
        iconTheme.Image = imagePath
        CreateTween(icon, "ImageColor3", DeepGet(Library.CurrentTheme, colorPath), 0.2):Play()
        icon.Image = DeepGet(Library.CurrentTheme, imagePath)
    end

    local function setOpenState(open)
        isOpen = open
        dropdown.Opened = open
        local color = open and "Colors.Primary" or "Colors.Icons"
        local img = open and "Icons.Dropdown.Close" or "Icons.Dropdown.Open"
        setIcon(color, img)
    end

    local function onClose()
        setOpenState(false)
    end

    local function getMultiSelected()
        local result = {}
        for name, selected in pairs(multiState) do
            if selected then
                result[#result + 1] = name
            end
        end
        return result
    end

    local function updateDisplay(value)
        local text = type(value) == "table" and table.concat(value, ", ") or (value or "")
        if #text >= 100 then
            text = text:sub(1, 97) .. "..."
        end
        valueLabel.Text = #text ~= 0 and text or "..."
    end

    local function commit()
        isDirty = false
        local value = multi and getMultiSelected() or (selectedSingle and selectedSingle.Name)
        FireCallbacks(callbacks, multi and multiState or value)
        updateDisplay(value)
        if flag then FlagsTable[flag] = value end
    end

    local function scheduleCommit()
        if not isDirty then
            isDirty = true
            task.delay(0.1, commit)
        end
    end

    local function onOptionClicked(opt)
        if multi then
            local newState = not opt.Selected
            DropdownSystem.SetOptionValue(opt, newState)
            multiState[opt.Name] = newState
        else
            if selectedSingle == opt then return end
            if selectedSingle then
                DropdownSystem.SetOptionValue(selectedSingle, false)
            end
            selectedSingle = opt
            DropdownSystem.SetOptionValue(opt, true)
        end
        scheduleCommit()
    end

    local function createOption(name)
        name = tostring(name)
        if optionMap[name] then return end

        local opt = {
            Name = name,
            DisplayName = name,
            Selected = false
        }

        if multi and multiState[name] == nil then
            multiState[name] = false
        end

        optionMap[name] = opt
        optionList[#optionList + 1] = opt
        return opt
    end

    local function toggleOpen(open)
        if isOpen == open then return end
        if not DropdownSystem then
            DropdownSystem = CreateDropdownSystem()
        end

        if open then
            if not DropdownSystem.OpenDropdown(onClose) then return end
            DropdownSystem.SetHolder(holder)
            DropdownSystem.SetMultiSelect(multi)
            DropdownSystem.SetOnClicked(onOptionClicked)
            DropdownSystem.SetOptions(optionList)
        else
            DropdownSystem.CloseDropdown()
        end
        setOpenState(open)
    end

    local function resolveOption(val, idx)
        if idx and type(val) == "boolean" then
            return val == true and optionList[idx]
        end
        return type(val) == "number" and optionList[val] or optionMap[tostring(val)]
    end

    local function markSelected(opt)
        opt.Selected = true
        if multi then
            multiState[opt.Name] = true
        else
            selectedSingle = opt
        end
    end

    local function applyDefault(...)
        local opt = resolveOption(...)
        if opt then
            markSelected(opt)
        elseif multi and type(...) == "string" then
            pending[select(1, ...)] = true
        end
    end

    local function initDefaults()
        if not default then return end
        for i = 1, (multi and #default or 1) do
            applyDefault(default[i], i)
        end
    end

    local function removeOption(opt)
        local idx = table.find(optionList, opt)
        if idx then table.remove(optionList, idx) end
        if opt.Instance then opt.Instance:Destroy() end
        optionMap[opt.Name] = nil
    end

    local function isSelected(opt)
        if multi then
            return (multiState[opt.Name] or pending[opt.Name]) == true
        else
            return selectedSingle and selectedSingle.Name == opt.Name
        end
    end

    dropdown.ADD_DROPDOWN_OPTION = function(val)
        if type(val) == "table" then
            for i = 1, #val do
                dropdown:Add(val[i])
            end
            return
        end

        local opt = createOption(val)
        if opt then
            if dropdown.Opened then
                DropdownSystem.CreateOptionTemplate(opt, true)
            end
            if isSelected(opt) then
                markSelected(opt)
                if opt.Instance then
                    DropdownSystem.SetOptionValue(opt, opt.Selected)
                end
            end
            scheduleCommit()
        end
    end

    dropdown.REMOVE_DROPDOWN_OPTION = function(val)
        local opt = optionMap[tostring(val)]
        if opt then removeOption(opt) end
    end

    dropdown.CLEAR_DROPDOWN = function()
        for i = #optionList, 1, -1 do
            local opt = optionList[i]
            if opt.Instance then opt.Instance:Destroy() end
            optionMap[opt.Name] = nil
            optionList[i] = nil
        end
        if dropdown.Opened then
            DropdownSystem.Clear()
        end
    end

    -- init
    if options then
        for i = 1, #options do
            createOption(options[i])
        end
    end

    if type(default) == "table" then
        initDefaults()
    elseif type(default) == "string" or type(default) == "number" then
        local opt = resolveOption(default)
        if opt then markSelected(opt) end
    end

    if multi then
        local selected = getMultiSelected()
        task.defer(FireCallbacks, callbacks, multiState)
        updateDisplay(selected)
    else
        local name = selectedSingle and selectedSingle.Name or ""
        task.defer(FireCallbacks, callbacks, name)
        updateDisplay(name)
    end

    Connect(button.Activated, function()
        toggleOpen(not isOpen)
    end)

    return dropdown
end

function TabAPI:AddParagraph(title, description)
    assert(type(title) == "string", "AddParagraph title expects string")
    if description ~= nil and type(description) ~= "string" then
        error("AddParagraph description expects string or nil", 2)
    end

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, description, UDim2.new(1, 0, 0, 0))

    return setmetatable({
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Title = title,
        Description = description,
        Parent = self,
        Kind = "Paragraph"
    }, Option)
end

--------------------------------------------------------------------
-- ProgressBar
--------------------------------------------------------------------
function TabAPI:AddProgressBar(config)
    config = type(config) == "table" and config or {}
    local title = config[1] or config.Name or config.Title or "Progress"
    local desc = config.Desc or config.Description or ""
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or config.Value or min
    local showValue = config.ShowValue ~= false

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(0.45, 0, 0, 0))

    local holder = New("Frame", button, {
        Size = UDim2.new(0.52, 0, 0, 14),
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1
    })

    local track = New("Frame", holder, {
        Size = UDim2.new(1, showValue and -36 or 0, 0, 6),
        Position = UDim2.fromScale(0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Stroke"
        },
        Elements = { Corner = UDim.new(1, 0) }
    })

    local fill = New("Frame", track, {
        Size = UDim2.fromScale(0, 1),
        BorderSizePixel = 0,
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Primary"
        },
        Elements = { Corner = UDim.new(1, 0) }
    })

    local valueLabel = New("TextLabel", holder, {
        Size = UDim2.new(0, 32, 1, 0),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Visible = showValue,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Dark",
            Font = "Font.Bold"
        }
    })

    local bar = setmetatable({
        Min = min,
        Max = max,
        Value = value,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        Title = title,
        Kind = "ProgressBar",
        Parent = self
    }, Option)

    function bar:SetValue(v)
        v = math.clamp(tonumber(v) or self.Min, self.Min, self.Max)
        self.Value = v
        local ratio = (self.Max == self.Min) and 1 or ((v - self.Min) / (self.Max - self.Min))
        CreateTween(fill, "Size", UDim2.fromScale(ratio, 1), 0.2):Play()
        if showValue then
            valueLabel.Text = tostring(math.floor(ratio * 100)) .. "%"
        end
    end

    bar:SetValue(value)
    return bar
end

--------------------------------------------------------------------
-- Colorpicker (simple R/G/B + preview)
--------------------------------------------------------------------
function TabAPI:AddColorpicker(config)
    config = type(config) == "table" and config or {}
    local title = config[1] or config.Name or config.Title or "Color"
    local desc = config.Desc or config.Description or ""
    local default = config.Default or config.Color or Color3.fromRGB(99, 102, 241)
    if typeof(default) ~= "Color3" then
        default = Color3.fromRGB(99, 102, 241)
    end
    local callbacks = PackCallback(config.Callback or config[2])
    local flag = config.Flag

    local themeObj = TabThemes[self]
    local button, titleLabel, descLabel = CreateOptionRow(self, title, desc, UDim2.new(1, -90, 0, 0))

    local preview = New("TextButton", button, {
        Size = UDim2.fromOffset(28, 16),
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default,
        AutoButtonColor = false,
        Text = "",
        Elements = {
            Corner = UDim.new(0, 4),
            Stroke = {
                Thickness = 1,
                ThemeTag = { Color = "Colors.Stroke" }
            }
        }
    })

    -- Expand panel (hidden)
    local panel = New("Frame", button, {
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })

    local function makeChannel(name, order, init)
        local row = New("Frame", panel, {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, (order - 1) * 20),
            BackgroundTransparency = 1
        })
        New("TextLabel", row, {
            Size = UDim2.new(0, 14, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextSize = 10,
            ThemeTag = {
                OBJECTS = themeObj,
                TextColor3 = "Colors.Text.Dark",
                Font = "Font.Bold"
            }
        })
        local track = New("TextButton", row, {
            Size = UDim2.new(1, -50, 0, 6),
            Position = UDim2.new(0, 18, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            AutoButtonColor = false,
            Text = "",
            ThemeTag = {
                OBJECTS = themeObj,
                BackgroundColor3 = "Colors.Stroke"
            },
            Elements = { Corner = UDim.new(1, 0) }
        })
        local fill = New("Frame", track, {
            Size = UDim2.fromScale(init, 1),
            ThemeTag = {
                OBJECTS = themeObj,
                BackgroundColor3 = "Colors.Primary"
            },
            Elements = { Corner = UDim.new(1, 0) }
        })
        local num = New("TextLabel", row, {
            Size = UDim2.new(0, 28, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            TextSize = 9,
            Text = tostring(math.floor(init * 255)),
            ThemeTag = {
                OBJECTS = themeObj,
                TextColor3 = "Colors.Text.Dark",
                Font = "Font.Medium"
            }
        })
        return track, fill, num
    end

    local r, g, b = default.R, default.G, default.B
    local rTrack, rFill, rNum = makeChannel("R", 1, r)
    local gTrack, gFill, gNum = makeChannel("G", 2, g)
    local bTrack, bFill, bNum = makeChannel("B", 3, b)

    local opened = false
    local colorObj = setmetatable({
        Color = default,
        Value = default,
        DESTROY_ELEMENT = button,
        VISIBLE_ELEMENT = button,
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = descLabel,
        CALLBACKS = callbacks,
        Title = title,
        Kind = "Colorpicker",
        Parent = self
    }, Option)

    local function applyColor(nr, ng, nb, fire)
        r, g, b = nr, ng, nb
        local c = Color3.new(r, g, b)
        colorObj.Color = c
        colorObj.Value = c
        preview.BackgroundColor3 = c
        rFill.Size = UDim2.fromScale(r, 1)
        gFill.Size = UDim2.fromScale(g, 1)
        bFill.Size = UDim2.fromScale(b, 1)
        rNum.Text = tostring(math.floor(r * 255))
        gNum.Text = tostring(math.floor(g * 255))
        bNum.Text = tostring(math.floor(b * 255))
        if flag and FlagsTable then FlagsTable[flag] = { r, g, b } end
        if fire then FireCallbacks(callbacks, c) end
    end

    local function bindTrack(track, getter, setter)
        Connect(track.MouseButton1Down, function()
            if isDragging then return end
            isDragging = true
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                local pos = track.AbsolutePosition
                local size = track.AbsoluteSize
                local ratio = math.clamp((Mouse.X - pos.X) / math.max(size.X, 1), 0, 1)
                local nr, ng, nb = r, g, b
                if getter == "r" then nr = ratio
                elseif getter == "g" then ng = ratio
                else nb = ratio end
                applyColor(nr, ng, nb, true)
                task.wait()
            end
            isDragging = false
        end)
    end
    bindTrack(rTrack, "r")
    bindTrack(gTrack, "g")
    bindTrack(bTrack, "b")

    function colorObj:SetValue(c)
        if typeof(c) ~= "Color3" then return end
        applyColor(c.R, c.G, c.B, false)
    end

    Connect(preview.Activated, function()
        opened = not opened
        panel.Visible = opened
        if opened then
            panel.Size = UDim2.new(1, -16, 0, 64)
            button.Size = UDim2.new(1, 0, 0, 90)
        else
            panel.Size = UDim2.new(1, -16, 0, 0)
            button.Size = UDim2.new(1, 0, 0, 22)
        end
    end)

    -- restore flag
    if flag and FlagsTable and type(FlagsTable[flag]) == "table" then
        local t = FlagsTable[flag]
        if t[1] then applyColor(t[1], t[2], t[3], false) end
    end

    return colorObj
end

--------------------------------------------------------------------
-- Tooltip (attach to any GuiObject)
--------------------------------------------------------------------
local TooltipGui = nil
local TooltipLabel = nil
local TooltipScale = nil

local function EnsureTooltip()
    if TooltipGui then return end
    TooltipGui = New("Frame", "Tooltip", ScreenGui, {
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 0.08,
        Visible = false,
        ZIndex = 200,
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Elements = {
            Corner = UDim.new(0, 6),
            Stroke = {
                Thickness = 1,
                ThemeTag = { Color = "Colors.Stroke" }
            },
            Padding = {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            }
        }
    })
    TooltipLabel = New("TextLabel", TooltipGui, {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        TextSize = 11,
        Text = "",
        ThemeTag = {
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Medium"
        }
    })
    TooltipScale = New("UIScale", TooltipGui, { Scale = 0.9 })
end

function Library:Tooltip(target, text)
    assert(typeof(target) == "Instance", "Tooltip target must be Instance")
    text = tostring(text or "")
    EnsureTooltip()

    Connect(target.MouseEnter, function()
        TooltipLabel.Text = text
        TooltipGui.Visible = true
        TooltipScale.Scale = 0.9
        CreateTween(TooltipScale, "Scale", 1, 0.15):Play()
        CreateTween(TooltipGui, "BackgroundTransparency", 0.08, 0.15):Play()
    end)
    Connect(target.MouseLeave, function()
        CreateTween(TooltipScale, "Scale", 0.9, 0.12):Play()
        task.delay(0.12, function()
            if TooltipGui then TooltipGui.Visible = false end
        end)
    end)
    Connect(UserInputService.InputChanged, function(input)
        if not TooltipGui or not TooltipGui.Visible then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local scale = (UIScaleObj and UIScaleObj.Scale) or 1
            TooltipGui.Position = UDim2.fromOffset(
                (Mouse.X / scale) + 14,
                (Mouse.Y / scale) + 14
            )
        end
    end)
end

-- Convenience on Option rows
function Option:SetTooltip(text)
    if self.VISIBLE_ELEMENT then
        Library:Tooltip(self.VISIBLE_ELEMENT, text)
    end
    return self
end

function TabAPI:AddDiscordInvite(config)
    -- simplified version kept compatible
    local title, desc = ParseOptionConfig("DiscordInvite", config)
    local icon = config.Icon or config.Image or config.Logo
    local banner = config.Banner or config.BannerColor
    local online = config.Online or config.MembersOnline
    local members = config.Members or config.TotalMembers
    local invite = config.Invite or config.Link

    assert(type(invite) == "string", "DiscordInvite.Invite expects string")

    local themeObj = TabThemes[self]
    local container = TabElements[self].Container

    local frame = New("Frame", "Option", container, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 148)
    })

    local card = New("CanvasGroup", frame, {
        Size = UDim2.new(0, 178, 1, -15),
        Position = UDim2.new(0, 5, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ClipsDescendants = true,
        Elements = {
            Corner = UDim.new(0, 9),
            Stroke = {
                ThemeTag = { Color = "Colors.Border.Default" }
            }
        },
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Buttons.Default"
        }
    })

    local bannerImg = New("ImageLabel", card, {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromScale(1, 0.28),
        BackgroundTransparency = 1
    })

    New("TextLabel", frame, {
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, 0, 0, 15),
        TextColor3 = Color3.fromRGB(40, 150, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = 9,
        Text = invite,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Link",
            Font = "Font.Medium"
        }
    })

    New("ImageLabel", card, {
        Size = UDim2.fromOffset(33, 33),
        Position = UDim2.new(0, 10, 0.28, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Image = icon or "",
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Elements = {
            Corner = UDim.new(0, 8),
            Stroke = {
                Thickness = 2.2,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                ThemeTag = {
                    OBJECTS = themeObj,
                    Color = "Colors.Buttons.Default"
                }
            }
        }
    })

    New("TextLabel", card, {
        Size = UDim2.new(1, -10, 0, 10),
        Position = UDim2.new(0, 10, 0.44, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        TextSize = 11,
        Text = title,
        ThemeTag = {
            OBJECTS = themeObj,
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    local joinBtn = New("TextButton", card, {
        Position = UDim2.new(0.5, 0, 1, -9),
        Size = UDim2.new(1, -18, 0, 18),
        AnchorPoint = Vector2.new(0.5, 1),
        Text = Library:T("GoToServer"),
        Elements = {
            Corner = UDim.new(0.5, 0)
        },
        ThemeTag = {
            OBJECTS = themeObj,
            BackgroundColor3 = "Colors.JoinButton",
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    local lastCopy = 0
    Connect(joinBtn.Activated, function()
        if (tick() - lastCopy) < 0 then return end
        lastCopy = tick() + 5
        local old = joinBtn.Text
        joinBtn.Text = Library:T("CopiedClipboard")
        if setclipboard then setclipboard(invite) end
        task.wait(4)
        joinBtn.Text = old
    end)

    if type(banner) == "string" then
        bannerImg.ScaleType = Enum.ScaleType.Crop
        bannerImg.Image = banner
    elseif typeof(banner) == "Color3" then
        bannerImg.BackgroundTransparency = 0
        New("UIGradient", bannerImg, {
            Rotation = -15,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, banner),
                ColorSequenceKeypoint.new(1, banner:Lerp(Color3.new(1, 1, 1), 0.2))
            })
        })
    end

    return setmetatable({
        DESTROY_ELEMENT = frame,
        VISIBLE_ELEMENT = frame,
        Title = title,
        Description = desc,
        Kind = "DiscordInvite",
        Parent = self
    }, Option)
end

function TabAPI:Destroy()
    assert(type(self) == "table" and self.IS_A_TAB, "Not a tab")
    if self.IS_DESTROYED then return end
    local idx = table.find(TabsList, self)
    assert(idx, "Failed to destroy tab")
    table.remove(TabsList, idx)

    for _, el in pairs(TabElements[self]) do
        el:Destroy()
    end
    TabThemes[self]:destroy()
    TabElements[self] = nil
    TabThemes[self] = nil
    setmetatable(self, nil)
end

function TabAPI:SetVisible(visible)
    assert(type(visible) == "boolean", "SetVisible expects boolean")
    for _, el in pairs(TabElements[self]) do
        el.Visible = visible
    end
end

function TabAPI:Select()
    if SelectedTab == self then return end
    if SelectedTab then
        TabSelectors[SelectedTab].Unselect()
    end
    SelectedTab = self
    TabSelectors[SelectedTab].Select()
end

--------------------------------------------------------------------
-- WINDOW METHODS
--------------------------------------------------------------------
function WindowAPI:SelectTab(tabOrIndex)
    local tab = type(tabOrIndex) == "number" and TabsList[tabOrIndex]
    if type(tabOrIndex) == "table" and tabOrIndex.IS_A_TAB then
        tab = tabOrIndex
    end
    if tab then
        tab:Select()
    else
        assert(type(tabOrIndex) == "number", "SelectTab expects number or tab")
        assert(tabOrIndex > 0, "Index must be > 0")
        assert(tabOrIndex == math.floor(tabOrIndex), "Index must be integer")
        self.SelectedTab = tabOrIndex
    end
end

function WindowAPI:Minimize()
    MainFrame.Visible = not MainFrame.Visible
end

function WindowAPI:MakeTab(config)
    local title = config[1] or config.Name or config.Title
    local icon = config[2] or config.Icon or config.Image

    assert(type(title) == "string", "Tab.Title expects string")
    assert(icon == nil or type(icon) == "string", "Tab.Icon expects string or nil")

    local tab = setmetatable({
        Selected = self.SelectedTab == #TabsList + 1,
        Icon = Library:GetIconByName(icon),
        Title = title,
        Parent = self,
        IS_A_TAB = true
    }, TabAPI)

    local elements = self:GetElements()
    local tabsContainer = elements.TabsContainer
    local containerHolder = elements.ContainerHolder

    -- Tab button
    local tabBtn = New("TextButton", "Button", tabsContainer, {
        Size = UDim2.new(1, 0, 0, 22),
        AutoButtonColor = false,
        Text = "",
        Elements = {
            Corner = UDim.new(0, 5)
        },
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Childs = {
            New("TextLabel", "Title", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ThemeTag = {
                    TextColor3 = "Colors.Text.Default"
                }
            })
        }
    })

    local indicator = New("Frame", tabBtn, {
        Position = UDim2.new(0, 1, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(3, 3),
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Colors.Primary"
        },
        Elements = {
            Corner = UDim.new(0.5, 0)
        }
    })

    local container = New("ScrollingFrame", "Container", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 1),
        AnchorPoint = Vector2.new(0, 1),
        ScrollBarThickness = 1.2,
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 0.25,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ThemeTag = {
            ScrollBarImageColor3 = "Colors.ScrollBar"
        },
        Elements = {
            Padding = {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            },
            ListLayout = {
                Padding = UDim.new(0, 4)
            }
        }
    })

    local iconImg = New("ImageLabel", tabBtn, {
        Position = UDim2.new(0, 7, 0.5),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        ImageTransparency = 0.25,
        Image = tab.Icon or ""
    })

    local function updateIcon()
        local hasIcon = string.sub(iconImg.Image, 1, 13) == "rbxassetid://"
        local titleLabel = tabBtn.Title
        iconImg.Visible = hasIcon
        titleLabel.Size = UDim2.new(1, hasIcon and -25 or -15, 1)
        titleLabel.Position = UDim2.fromOffset(hasIcon and 25 or 15)
    end
    Connect(iconImg:GetPropertyChangedSignal("Image"), updateIcon)
    updateIcon()

    local openTween = CreateTween(container, "Size", UDim2.new(1, 0, 1, 0), 0.22)
    local closedSize = UDim2.new(1, 0, 1, 120)
    local animDuration = 0.28

    local selectAnims = {
        CreateTween(indicator, "BackgroundTransparency", 0, animDuration),
        CreateTween(indicator, "Size", UDim2.fromOffset(3, 12), animDuration)
    }
    local unselectAnims = {
        CreateTween(indicator, "BackgroundTransparency", 1, animDuration),
        CreateTween(indicator, "Size", UDim2.fromOffset(3, 3), animDuration)
    }

    local themeObj = RootTheme:new()
    TabThemes[tab] = themeObj

    local function playAnims(list)
        for _, t in ipairs(list) do t:Play() end
    end

    local function doSelect()
        playAnims(selectAnims)
        tab.Selected = true
        themeObj:changeRendering(true)
        themeObj:update()
        container.Parent = containerHolder
        container.Size = closedSize
        openTween:Play()
    end

    local function doUnselect()
        playAnims(unselectAnims)
        tab.Selected = false
        container.Parent = nil
        themeObj:changeRendering(false)
    end

    TabSelectors[tab] = table.freeze({
        Unselect = doUnselect,
        Select = doSelect
    })

    TabElements[tab] = table.freeze({
        SelectTabButton = tabBtn,
        Container = container
    })

    table.insert(TabsList, tab)

    Connect(tabBtn.Activated, function()
        tab:Select()
    end)

    if tab.Selected then
        tab:Select()
    end

    return tab
end

function WindowAPI:StartWindow(config)
    local minimizeBtn = config.MinimizeButton
    local mainFrame = config.MainFrame
    local resizers = config.Resizers
    local topBar = config.TopBar
    local subTitle = config.SubTitle
    local title = config.Title

    DropdownHolder = config.Dropdowns
    MainFrame = config.MainFrame
    UIScaleObj = config.UIScale
    FlagsTable = config.Flags

    local originalSize = mainFrame.Size
    local lastMinimize = 0

    function WindowAPI:MinimizeButton()
        if (tick() - lastMinimize) < 0 then return false end

        if self.Minimized then
            minimizeBtn.Image = "rbxassetid://10734896206"
            CreateTween(mainFrame, "Size", originalSize, 0.2):Play()
        else
            originalSize = mainFrame.Size
            minimizeBtn.Image = "rbxassetid://10734924532"
            CreateTween(mainFrame, "Size", UDim2.fromOffset(mainFrame.Size.X.Offset, topBar.Size.Y.Offset), 0.2):Play()
        end

        for _, r in pairs(resizers) do
            r.Visible = self.Minimized
        end

        self.Minimized = not self.Minimized
        lastMinimize = tick() + 0.5
        return true
    end

    function WindowAPI:GetTitle()
        return title.Text
    end

    function WindowAPI:GetSubTitle()
        return subTitle.Text
    end

    function WindowAPI:SetTitle(text)
        assert(type(text) == "string", "SetTitle expects string")
        assert(#text > 0, "Title too short")
        title.Text = text
    end

    function WindowAPI:SetSubTitle(text)
        assert(type(text) == "string", "SetSubTitle expects string")
        assert(#text > 0, "SubTitle too short")
        subTitle.Text = text
    end

    -- Background Image (independent of Acrylic)
    -- Layer order: Window solid bg (Z0) → Acrylic (Z1) → BgImage (Z2) → Content (higher)
    local bgImage = New("ImageLabel", mainFrame, {
        Name = "BackgroundImage",
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ImageTransparency = Library.Default.BackgroundImageTransparency or 0.55,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 0,
        Visible = false
    })
    -- clip to window corners
    local bgCorner = New("UICorner", bgImage, { CornerRadius = UDim.new(0, 12) })

    function WindowAPI:SetBackgroundImage(assetId)
        local normalized = NormalizeAssetId(assetId)
        if not normalized then
            bgImage.Visible = false
            bgImage.Image = ""
            if Library.WindowSettings then
                Library.WindowSettings.BackgroundImage = nil
            end
            return
        end
        bgImage.Image = normalized
        bgImage.Visible = true
        local pureId = tostring(assetId):gsub("rbxassetid://", ""):gsub("%s+", "")
        if Library.WindowSettings then
            Library.WindowSettings.BackgroundImage = pureId
        end
        Library.Default.BackgroundImage = pureId
    end

    function WindowAPI:SetBackgroundImageTransparency(t)
        assert(type(t) == "number", "Transparency expects number")
        local v = math.clamp(t, 0, 1)
        bgImage.ImageTransparency = v
        if Library.WindowSettings then
            Library.WindowSettings.BackgroundImageTransparency = v
        end
        Library.Default.BackgroundImageTransparency = v
    end

    if Library.Default.BackgroundImage then
        WindowAPI:SetBackgroundImage(Library.Default.BackgroundImage)
    end

    -- Notification holder
    local notifHolder = New("Frame", ScreenGui, {
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Elements = {
            Padding = {
                PaddingBottom = UDim.new(0, 20)
            },
            ListLayout = {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 20)
            }
        }
    })

    -- Dialog outbox
    dialogOutBox = New("TextButton", "OutBox", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.3,
        AutoButtonColor = false,
        Text = "",
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Childs = {
            mainFrame:FindFirstChildOfClass("UICorner"):Clone(),
            New("Frame", "Template", {
                Size = UDim2.new(0.35, 60, 0.20, 80),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Active = true,
                Elements = {
                    Corner = UDim.new(0, 6),
                    Gradient = {
                        Rotation = 45,
                        ThemeTag = { Color = "Colors.Background" }
                    }
                },
                Childs = {
                    New("TextLabel", "Title", {
                        Size = UDim2.new(1, -20, 0, 20),
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextSize = 15,
                        Position = UDim2.new(0.5, 0, 0, 28),
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        ThemeTag = {
                            Font = "Font.ExtraBold",
                            TextColor3 = "Colors.Text.Default"
                        }
                    }),
                    New("TextLabel", "Description", {
                        Position = UDim2.new(0.5, 0, 0, 46),
                        Size = UDim2.new(1, -20, 0, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        TextWrapped = true,
                        TextSize = 11,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        ThemeTag = {
                            TextColor3 = "Colors.Text.Darker",
                            Font = "Font.Medium"
                        }
                    }),
                    New("Frame", "Options", {
                        Size = UDim2.new(1, -20, 0.15, 18),
                        Position = UDim2.new(0.5, 0, 1, -10),
                        AnchorPoint = Vector2.new(0.5, 1),
                        BackgroundTransparency = 1,
                        Elements = {
                            Padding = {
                                PaddingLeft = UDim.new(0, 10),
                                PaddingRight = UDim.new(0, 10),
                                PaddingBottom = UDim.new(0, 30),
                                PaddingTop = UDim.new(0, 30)
                            },
                            ListLayout = {
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                FillDirection = Enum.FillDirection.Horizontal
                            }
                        }
                    })
                }
            })
        }
    })

    dialogOutBox.Template:SetAttribute("OriginalSize", dialogOutBox.Template.Size)

    Connect(dialogOutBox.Activated, function()
        if currentDialog and not currentDialog.Closing and not currentDialog.Closed then
            currentDialog:Close()
        end
    end)

    WindowAPI.StartWindow = nil
end

function WindowAPI:DeleteFlags()
    return FlagsTable()
end

function WindowAPI:SetFlag(key, value)
    assert(type(key) == "string", "SetFlag key expects string")
    local allowed = { number = true, string = true, ["nil"] = true, boolean = true, table = true }
    if not allowed[typeof(value)] then
        error("SetFlag value type not allowed", 2)
    end
    FlagsTable[key] = value
end

function WindowAPI:GetFlag(key)
    return FlagsTable[key]
end

function WindowAPI:ReadFile(name)
    assert(type(name) == "string", "ReadFile expects string")
    local path = self.ScriptFolder .. "/" .. name
    if readfile and (not isfile or isfile(path)) then
        return readfile(path)
    end
end

function WindowAPI:WriteFile(name, content)
    assert(type(name) == "string", "WriteFile expects string")
    local path = self.ScriptFolder .. "/" .. name
    if content ~= nil and type(content) ~= "string" then
        error("WriteFile content expects string or nil", 2)
    end
    if content == nil then
        if delfile then
            delfile(path)
            return true
        end
    else
        if writefile then
            SafeWriteFile(path, content)
            return true
        end
    end
    return false
end

function WindowAPI:NewMinimizer(config)
    local key = type(config) == "table" and (config[1] or config.KeyCode) or config
    local keyCodes = {}
    for _, k in ipairs(Enum.KeyCode:GetEnumItems()) do
        keyCodes[k] = true
    end
    if not (typeof(key) == "EnumItem" and keyCodes[key]) then
        error("NewMinimizer.KeyCode expects KeyCode", 2)
    end

    local minimizer = setmetatable({ KeyCode = key }, MinimizerAPI)

    Connect(UserInputService.InputBegan, function(input)
        if input.KeyCode == minimizer.KeyCode then
            WindowAPI:Minimize()
        end
    end)

    return minimizer
end

-- Smooth rounded floating button to toggle menu (mobile-friendly)
-- Window:CreateOpenButton({ Icon = "...", Size = 44, Position = UDim2.fromScale(0.08, 0.5) })
function WindowAPI:CreateOpenButton(config)
    config = type(config) == "table" and config or {}
    local size = config.Size or (Library.IsMobile and 48 or 44)
    local pos = config.Position or UDim2.fromScale(0.12, 0.45)
    local iconId = NormalizeAssetId(config.Icon) or "rbxassetid://10734896206"
    local corner = config.Corner or UDim.new(0, 14)

    local btn = New("ImageButton", "OpenButton", ScreenGui, {
        Size = UDim2.fromOffset(size, size),
        Position = pos,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.15,
        AutoButtonColor = false,
        Image = "",
        ZIndex = 100,
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Elements = {
            Corner = corner,
            Stroke = {
                Thickness = 1.2,
                ThemeTag = { Color = "Colors.Primary" }
            }
        }
    })

    local icon = New("ImageLabel", btn, {
        Size = UDim2.fromScale(0.55, 0.55),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = iconId,
        ThemeTag = {
            ImageColor3 = "Colors.Icons"
        }
    })

    local scale = New("UIScale", btn, { Scale = 1 })
    local glow = New("UIStroke", btn, {
        Thickness = 0,
        Transparency = 1,
        ThemeTag = { Color = "Colors.Primary" }
    })

    -- drag
    if UIScaleObj then
        Creator.Draggable(btn, UIScaleObj, 0.4)
    end

    local function pulse(targetScale, dur)
        CreateTween(scale, "Scale", targetScale, dur or 0.15):Play()
    end

    Connect(btn.MouseEnter, function()
        pulse(1.08, 0.18)
        CreateTween(btn, "BackgroundTransparency", 0.05, 0.18):Play()
        CreateTween(glow, "Thickness", 2.5, 0.2):Play()
        CreateTween(glow, "Transparency", 0.4, 0.2):Play()
    end)
    Connect(btn.MouseLeave, function()
        pulse(1, 0.18)
        CreateTween(btn, "BackgroundTransparency", 0.15, 0.18):Play()
        CreateTween(glow, "Thickness", 0, 0.2):Play()
        CreateTween(glow, "Transparency", 1, 0.2):Play()
    end)
    Connect(btn.MouseButton1Down, function()
        pulse(0.92, 0.08)
    end)
    Connect(btn.MouseButton1Up, function()
        pulse(1.08, 0.1)
    end)

    Connect(btn.Activated, function()
        -- bounce
        pulse(0.88, 0.08)
        task.delay(0.08, function()
            pulse(1.12, 0.12)
            task.delay(0.12, function() pulse(1, 0.15) end)
        end)
        WindowAPI:Minimize()
    end)

    -- keep icon color synced with theme primary
    local api = {
        Button = btn,
        Icon = icon,
        SetIcon = function(_, id)
            icon.Image = NormalizeAssetId(id) or icon.Image
        end,
        SetVisible = function(_, v)
            btn.Visible = v
        end,
        Destroy = function()
            btn:Destroy()
        end
    }

    return api
end

function WindowAPI:Dialog(config)
    if self.Minimized then
        while not self:MinimizeButton() do task.wait() end
    end
    if currentDialog then
        currentDialog:Close(true)
    end

    local title = config.Title or config.Name
    local content = config.Content or config.Description
    local options = config.Options

    assert(type(title) == "string", "Dialog.Title expects string")
    assert(type(content) == "string", "Dialog.Content expects string")
    assert(type(options) == "table", "Dialog.Options expects table")
    assert(#options > 0, "Dialog.Options requires at least one option")

    local function open()
        local template = dialogOutBox.Template
        local descLabel = template.Description
        local titleLabel = template.Title
        local original = template:GetAttribute("OriginalSize")
        local bigger = UDim2.new(original.X.Scale * 1.2, original.X.Offset, original.Y.Scale * 1.2, original.Y.Offset)

        template.Size = bigger
        dialogOutBox.Parent = MainFrame
        descLabel.Text = content
        titleLabel.Text = title

        CreateTween(template, "Size", original, 0.3):Play()

        local dialog = DialogOpt.new(descLabel, titleLabel)
        dialog.NEW_SIZE = bigger
        dialog.TEMPLATE = template

        for _, child in ipairs(template.Options:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end

        for i = #options, 1, -1 do
            dialog:NewOption(options[i])
        end

        return dialog
    end

    currentDialog = open()
    return currentDialog
end

function WindowAPI:SetNotifyDefaultIcon(icon)
    assert(type(icon) == "string", "SetNotifyDefaultIcon expects string")
    DefaultNotifyIcon = icon
end

function WindowAPI:Notify(config)
    if type(config) ~= "table" then config = {} end

    local title = config[1] or config.Name or config.Title
    local content = config[2] or config.Content
    local icon = config[3] or config.Icon or config.Image
    local duration = config[4] or config.Duration or config.Countdown or config.Time

    if self.NOTIFICATION_GROUP then
        if duration == nil then duration = self.Duration end
        if content == nil then content = self.Content end
        if title == nil then title = self.Title end
        if icon == nil then icon = self.Icon end
    end

    assert(type(title) == "string", "Notify.Title expects string")
    assert(type(content) == "string", "Notify.Content expects string")
    assert(icon == nil or type(icon) == "string", "Notify.Icon expects string or nil")

    if duration ~= nil and type(duration) ~= "number" then
        error("Notify.Time expects number or nil", 2)
    elseif duration == nil then
        duration = 5
    end

    -- simple notification (holder is created in StartWindow)
    local notif = New("Frame", "Notification", {
        Size = UDim2.new(0.85, 0, 0, 60),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })

    -- For simplicity, attach to ScreenGui if holder not ready
    notif.Parent = ScreenGui

    local body = New("TextButton", notif, {
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 1),
        AutoButtonColor = false,
        Text = "",
        ThemeTag = {
            BackgroundTransparency = "BackgroundTransparency"
        },
        Elements = {
            Corner = UDim.new(0, 9),
            Gradient = {
                Rotation = 45,
                ThemeTag = { Color = "Colors.Background" }
            }
        }
    })

    local scale = New("UIScale", notif)
    local holder = New("Frame", "Holder", body, {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Elements = {
            ListLayout = {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4)
            },
            Padding = {
                PaddingBottom = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 40)
            }
        }
    })

    local titleLabel = New("TextLabel", holder, {
        Size = UDim2.new(1, 0, 0, 20),
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        BackgroundTransparency = 1,
        TextSize = 14,
        ThemeTag = {
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        }
    })

    local contentLabel = New("TextLabel", holder, {
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 12,
        ThemeTag = {
            TextColor3 = "Colors.Text.Dark",
            Font = "Font.Normal"
        }
    })

    local iconImg = New("ImageLabel", body, {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        ThemeTag = {
            ImageColor3 = "Colors.Icons"
        }
    })

    local timeLabel = New("TextLabel", body, {
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -10, 0, 8),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        TextSize = 10,
        ThemeTag = {
            TextColor3 = "Colors.Text.Darker",
            Font = "Font.Normal"
        }
    })

    local paused = false
    local expand = CreateTween(scale, "Scale", 1.22, 0.35)
    local shrink = CreateTween(scale, "Scale", 1.00, 0.35)

    local notifObj = setmetatable({
        TITLE_LABEL = titleLabel,
        DESCRIPTION_LABEL = contentLabel,
        VISIBLE_ELEMENT = notif,
        DESTROY_ELEMENT = notif,
        NOTIFICATION = body,
        Kind = "Notification",
        Closed = false,
        Parent = self
    }, Option)

    function notifObj:Close()
        if self.Closed then return end
        self:Destroy()
        self.Closed = true
        local t = CreateTween(body, "Position", UDim2.fromScale(3, 0), 0.8)
        t:Play()
        t.Completed:Wait()
        notif:Destroy()
    end

    task.defer(function()
        local finalIcon = Library:GetIconByName(icon or DefaultNotifyIcon) or ""
        iconImg.Image = finalIcon
        if not IsAssetId(finalIcon) then
            iconImg.Visible = false
            holder.UIPadding.PaddingLeft = UDim.new(0, 15)
        end

        body.Position = UDim2.fromScale(3, 0)
        CreateTween(body, "Position", UDim2.fromScale(0, 0), 0.35):Play()

        titleLabel.Text = title
        contentLabel.Text = content

        local leave = body.MouseLeave
        while duration > 0 do
            timeLabel.Text = FormatTime(duration)
            if paused then leave:Wait() end
            duration = duration - task.wait()
        end
        notifObj:Close()
    end)

    Connect(body.MouseButton1Down, function() expand:Play() paused = true end)
    Connect(body.MouseLeave, function() shrink:Play() paused = false end)

    return notifObj
end

function WindowAPI:NewNotifyGroup(config)
    local title = config[1] or config.Name or config.Title
    local content = config[2] or config.Content
    local icon = config[3] or config.Icon or config.Image
    local duration = config[4] or config.Duration or config.Countdown or config.Time

    return {
        NOTIFICATION_GROUP = true,
        Notify = WindowAPI.Notify,
        Duration = duration,
        Content = content,
        Title = title,
        Icon = icon
    }
end

function WindowAPI:GetTabByTitle(title)
    assert(type(title) == "string", "GetTabByTitle expects string")
    for _, tab in ipairs(TabsList) do
        if tab.Title == title then return tab end
    end
end

WindowAPI.NewNotificationGroup = WindowAPI.NewNotifyGroup
WindowAPI.SetDefaultNotifyIcon = WindowAPI.SetNotifyDefaultIcon
WindowAPI.GetTabByName = WindowAPI.GetTabByTitle
WindowAPI.Notificafion = WindowAPI.Notify

--------------------------------------------------------------------
-- LIBRARY PUBLIC API
--------------------------------------------------------------------
function Library:GetIconByName(name)
    if name == nil then return end
    if IsAssetId(name) or #name == 0 then return name end

    local cleaned = CleanString(name)
    if self.Icons[cleaned] then
        return "rbxassetid://" .. self.Icons[cleaned]
    end
    for key, id in pairs(self.Icons) do
        if key:find(cleaned, 1, true) then
            return "rbxassetid://" .. id
        end
    end
end

function Library:IsValidTheme(name)
    assert(type(name) == "string", "IsValidTheme expects string")
    return self.Themes[name] ~= nil
end

function Library:GetThemes()
    local list = {}
    for name in pairs(self.Themes) do
        table.insert(list, name)
    end
    return list
end

function Library:GetTheme(name)
    if name == nil then return self.CurrentTheme end
    assert(type(name) == "string", "GetTheme expects string")
    local theme = self.Themes[name]
    assert(theme, "Theme not found: " .. name)
    return theme
end

local RainbowConnection = nil

function Library:SetTheme(name)
    assert(type(name) == "string", "SetTheme expects string")
    local theme = self.Themes[name]
    assert(theme, "Theme not found: " .. name)
    self.CurrentTheme = theme
    if self.WindowSettings then
        self.WindowSettings.SelectedTheme = theme.Name
    end
    RootTheme:update()

    -- Rainbow accent animation
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end
    if theme.Rainbow then
        local hue = 0
        RainbowConnection = RunService.RenderStepped:Connect(function(dt)
            hue = (hue + dt * 0.15) % 1
            local c = Color3.fromHSV(hue, 0.85, 1)
            -- mutate live theme colors (not frozen)
            theme.Colors.Primary = c
            theme.Colors.ScrollBar = c
            theme.Colors.Icons = c
            theme.Colors.Link = c:Lerp(Color3.new(1, 1, 1), 0.25)
            theme.Colors.Slider.SliderBar = c
            theme.Colors.OnPrimary = c:Lerp(Color3.new(0, 0, 0), 0.55)
            RootTheme:update()
        end)
        table.insert(self.Connections, RainbowConnection)
    end
end

function Library:SetUIScale(scale)
    assert(type(scale) == "number", "SetUIScale expects number")
    assert(scale >= ScaleLimits.MIN_SCALE and scale <= ScaleLimits.MAX_SCALE,
        string.format("Scale must be between %s and %s", ScaleLimits.MIN_SCALE, ScaleLimits.MAX_SCALE))
    ScreenGui.Scale.Scale = ScaleValue(scale)
end

function Library:GetMaxScale() return ScaleLimits.MAX_SCALE end
function Library:GetMinScale() return ScaleLimits.MIN_SCALE end

function Library:GetCurrentTheme()
    if not self.LOADED_UI_LIBRARY then
        error("UI is not loaded", 2)
    end
    return self.CurrentTheme
end

function Library:Destroy()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    if ScreenGui and ScreenGui:GetAttribute("UID") == self.SCREENGUI_UID then
        pcall(ScreenGui.Destroy, ScreenGui)
    end
end

function Library:MakeWindow(config)
    if self.LOADED_UI_LIBRARY then
        return error("You can create only 1 Window", 2)
    end

    local uid = math.random()
    ScreenGui:SetAttribute("UID", uid)
    self.SCREENGUI_UID = uid
    ScreenGui:ClearAllChildren()

    local scale = New("UIScale", "Scale", ScreenGui, {
        Scale = ScaleValue(1)
    })

    local windowConfig = {
        Title = config[1] or config.Name or config.Title,
        SubTitle = config[2] or config.SubName or config.SubTitle,
        ScriptFolder = config[3] or config.ScriptFolder or config.FolderName,
        BackgroundImage = config.BackgroundImage or self.Default.BackgroundImage,
        BackgroundImageTransparency = config.BackgroundImageTransparency or self.Default.BackgroundImageTransparency,
        Acrylic = config.Acrylic == true,
        User = type(config.User) == "table" and config.User or nil
    }

    assert(type(windowConfig.Title) == "string", "Window.Title expects string")
    assert(type(windowConfig.SubTitle) == "string", "Window.SubTitle expects string")

    if windowConfig.ScriptFolder ~= nil and type(windowConfig.ScriptFolder) ~= "string" then
        return error("Window.ScriptFolder expects string or nil", 2)
    end
    if windowConfig.ScriptFolder and string.find(windowConfig.ScriptFolder, "/") then
        return error("Window.ScriptFolder cannot contain \"/\"", 2)
    end

    -- Settings (theme, size...)
    local settings = (function()
        local folder = windowConfig.ScriptFolder
        local dirty = false
        local ok, data = pcall(function()
            return folder and HttpService:JSONDecode(readfile(folder .. "/LibrarySettings.json"))
        end)
        if type(data) ~= "table" then data = {} end

        local function save()
            dirty = false
            return pcall(function()
                return SafeWriteFile(folder .. "/LibrarySettings.json", HttpService:JSONEncode(data))
            end)
        end

        return setmetatable({}, {
            __newindex = function(_, k, v)
                rawset(data, k, v)
                if folder and not dirty then
                    dirty = true
                    task.delay(0.5, save)
                end
            end,
            __index = data
        })
    end)()

    -- Flags
    local flags = (function()
        local folder = windowConfig.ScriptFolder
        local dirty = false
        local ok, data = pcall(function()
            return folder and HttpService:JSONDecode(readfile(folder .. "/ScriptFlags.json"))
        end)
        if type(data) ~= "table" then data = {} end

        local function save()
            dirty = false
            return pcall(function()
                SafeWriteFile(folder .. "/ScriptFlags.json", HttpService:JSONEncode(data))
            end)
        end

        local function clear()
            table.clear(data)
            return pcall(function()
                return folder and delfile(folder .. "/ScriptFlags.json")
            end)
        end

        return setmetatable({}, {
            __newindex = function(_, k, v)
                rawset(data, k, v)
                if folder and not dirty then
                    dirty = true
                    task.delay(0.5, save)
                end
            end,
            __call = clear,
            __index = data
        })
    end)()

    self.ThemesObjects = RootTheme
    self.WindowSettings = settings
    self.Flags = flags

    -- Icons (try load from file / github)
    self.Icons = (function()
        local folder = windowConfig.ScriptFolder
        local ok, icons = pcall(function()
            return loadstring(readfile(folder .. "/Icons.lua"))()
        end)
        if ok and type(icons) == "table" then return icons end

        local url = string.format(
            "https://raw.githubusercontent.com/%s/Library/refs/heads/main/redz-V5-remake/Utils/Icons.lua",
            self.Information.GitHubOwner
        )
        local content
        local ok2, result = pcall(function()
            content = game:HttpGet(url)
            return loadstring(content)()
        end)
        if ok2 and type(result) == "table" then
            if type(content) == "string" and folder then
                pcall(function() SafeWriteFile(folder .. "/Icons.lua", content) end)
            end
            return result
        end
        return {}
    end)()

    if type(settings.SelectedTheme) == "string" and self:IsValidTheme(settings.SelectedTheme) then
        self:SetTheme(settings.SelectedTheme)
    else
        self:SetTheme(self.Default.Theme)
    end

    -- restore language
    if type(settings.SelectedLanguage) == "string" and self.Languages[settings.SelectedLanguage] then
        self:SetLanguage(settings.SelectedLanguage)
    else
        self:SetLanguage(self.Default.Language or "en")
    end

    -- restore background image from config
    if type(settings.BackgroundImage) == "string" and #settings.BackgroundImage > 0 then
        windowConfig.BackgroundImage = settings.BackgroundImage
    end
    if type(settings.BackgroundImageTransparency) == "number" then
        windowConfig.BackgroundImageTransparency = settings.BackgroundImageTransparency
    end

    self.LOADED_UI_LIBRARY = true

    local size = self.Default.UISize
    if settings and type(settings.UISize) == "table" then
        local w, h = unpack(settings.UISize)
        if type(w) == "number" and type(h) == "number" then
            w = math.clamp(w, 400, 1000)
            h = math.clamp(h, 220, 560)
            size = UDim2.fromOffset(w, h)
        end
    end

    local acrylicOn = windowConfig.Acrylic == true
    -- Always keep solid redz-style gradient base (Acrylic is an extra layer, does not replace bg)
    local window = New("Frame", "Window", ScreenGui, {
        Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
        Active = true,
        Size = size,
        ThemeTag = {
            BackgroundTransparency = "BackgroundTransparency"
        },
        Elements = {
            Corner = UDim.new(0, 12),
            Stroke = {
                Thickness = 1.2,
                ThemeTag = { Color = "Colors.Stroke" }
            },
            Gradient = {
                Rotation = 45,
                ThemeTag = { Color = "Colors.Background" }
            }
        }
    })

    -- Acrylic layer: frosted tint OVER the solid bg, UNDER content & bg image
    local acrylicLayer = New("Frame", "Acrylic", window, {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = acrylicOn and 0.55 or 1,
        Visible = acrylicOn,
        ZIndex = 1,
        ThemeTag = {
            BackgroundColor3 = "Colors.Buttons.Default"
        },
        Elements = {
            Corner = UDim.new(0, 12)
        }
    })
    local acrylicTint = New("Frame", acrylicLayer, {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = acrylicOn and 0.82 or 1,
        ThemeTag = {
            BackgroundColor3 = "Colors.Primary"
        },
        Elements = {
            Corner = UDim.new(0, 12)
        }
    })

    Connect(window.Destroying, function() self:Destroy() end)
    Connect(ScreenGui:GetAttributeChangedSignal("UID"), function()
        self:Destroy()
        window:Destroy()
    end)

    Creator.Draggable(window, scale, 0.5)

    local components = New("Folder", "Components", window)
    local dropdowns = New("Folder", "Dropdowns", ScreenGui)

    local topBar = New("Frame", "TopBar", components, {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 10
    })

    local titleLabel = New("TextLabel", "Title", topBar, {
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.XY,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = windowConfig.Title,
        TextSize = 11,
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Colors.Text.Default",
            Font = "Font.Bold"
        },
        Childs = {
            New("TextLabel", "SubTitle", {
                Size = UDim2.fromScale(0, 1),
                AutomaticSize = "X",
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(1, 5, 0.9),
                Text = windowConfig.SubTitle,
                BackgroundTransparency = 1,
                TextXAlignment = "Left",
                TextYAlignment = "Bottom",
                TextSize = 8,
                ThemeTag = {
                    TextColor3 = "Colors.Text.Dark",
                    Font = "Font.Normal"
                }
            })
        }
    })

    -- Tags holder (center of topbar)
    local tagsHolder = New("Frame", "Tags", topBar, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Elements = {
            ListLayout = {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4)
            }
        }
    })

    local buttons = New("Folder", "Buttons", topBar, {
        Childs = {
            New("ImageButton", "Close", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -8, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.fromRGB(255, 35, 35),
                AutoButtonColor = false,
                ThemeTag = { Image = "Icons.Close" },
                Elements = { Corner = UDim.new(0.2, 0) }
            }),
            New("ImageButton", "Minimize", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -30, 0.5),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Image = "rbxassetid://10734896206",
                AutoButtonColor = false,
                Elements = { Corner = UDim.new(0.2, 0) }
            })
        }
    })

    local minimizeBtn = buttons.Minimize
    local closeBtn = buttons.Close

    local api = setmetatable(windowConfig, { __index = WindowAPI })

    -- Tabs + Containers
    local tabSize = settings.TabSize or self.Default.TabSize
    local topH = topBar.Size.Y.Offset

    -- WindUI-style User panel height (bottom-left of sidebar)
    local userCfg = windowConfig.User
    local userEnabled = type(userCfg) == "table" and userCfg.Enabled ~= false and userCfg ~= nil
    local USER_PANEL_H = 48
    local userBottomPad = userEnabled and (USER_PANEL_H + 8) or 0

    local tabsScroll = New("ScrollingFrame", "TabsScroll", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Position = UDim2.new(0, 0, 1, -userBottomPad),
        AnchorPoint = Vector2.new(0, 1),
        ScrollBarThickness = 1.5,
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(),
        BorderSizePixel = 0,
        ZIndex = 10,
        Size = UDim2.new(0, tabSize, 1, -(topH + userBottomPad)),
        ThemeTag = { ScrollBarImageColor3 = "Colors.ScrollBar" },
        Elements = {
            Padding = {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6)
            },
            ListLayout = { Padding = UDim.new(0, 3) }
        }
    })

    local containers = New("Frame", "Containers", {
        Size = UDim2.new(1, -tabSize, 1, -topH),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 10
    })

    tabsScroll.Parent = components
    containers.Parent = components

    -- ========== WindUI-style User panel (bottom-left) ==========
    local userPanel = nil
    local userAvatar, userDisplay, userNameLabel
    local userState = {
        Enabled = userEnabled,
        Anonymous = type(userCfg) == "table" and userCfg.Anonymous == true,
        Callback = type(userCfg) == "table" and userCfg.Callback or nil
    }

    local function getUserThumb()
        local ok, id = pcall(function()
            return Players:GetUserThumbnailAsync(
                userState.Anonymous and 1 or LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        return ok and id or ""
    end

    local function refreshUserLabels()
        if not userDisplay then return end
        if userState.Anonymous then
            userDisplay.Text = "Anonymous"
            userNameLabel.Text = "anonymous"
            userAvatar.Image = getUserThumb()
        else
            userDisplay.Text = LocalPlayer.DisplayName
            userNameLabel.Text = LocalPlayer.Name
            userAvatar.Image = getUserThumb()
        end
    end

    local function layoutUserPanel(enabled)
        userBottomPad = enabled and (USER_PANEL_H + 8) or 0
        tabsScroll.Position = UDim2.new(0, 0, 1, -userBottomPad)
        tabsScroll.Size = UDim2.new(0, tabsScroll.Size.X.Offset, 1, -(topH + userBottomPad))
        if userPanel then
            userPanel.Visible = enabled
        end
    end

    if type(userCfg) == "table" then
        userPanel = New("TextButton", "UserPanel", components, {
            Size = UDim2.new(0, tabSize - 8, 0, USER_PANEL_H),
            Position = UDim2.new(0, 4, 1, -4),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 12,
            Visible = userState.Enabled
        })

        local userBg = New("Frame", userPanel, {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.55,
            ThemeTag = { BackgroundColor3 = "Colors.Buttons.Default" },
            Elements = {
                Corner = UDim.new(0, 8),
                Stroke = {
                    Thickness = 1,
                    Transparency = 0.7,
                    ThemeTag = { Color = "Colors.Stroke" }
                }
            }
        })

        userAvatar = New("ImageLabel", userBg, {
            Size = UDim2.fromOffset(32, 32),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 0.85,
            BackgroundColor3 = Color3.fromRGB(40, 40, 48),
            Image = "",
            Elements = { Corner = UDim.new(1, 0) }
        })

        local textCol = New("Frame", userBg, {
            Size = UDim2.new(1, -48, 1, 0),
            Position = UDim2.new(0, 46, 0, 0),
            BackgroundTransparency = 1,
            Elements = {
                ListLayout = {
                    FillDirection = Enum.FillDirection.Vertical,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 2)
                }
            }
        })

        userDisplay = New("TextLabel", textCol, {
            Size = UDim2.new(1, -4, 0, 14),
            BackgroundTransparency = 1,
            Text = "",
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ThemeTag = {
                TextColor3 = "Colors.Text.Default",
                Font = "Font.Bold"
            }
        })

        userNameLabel = New("TextLabel", textCol, {
            Size = UDim2.new(1, -4, 0, 12),
            BackgroundTransparency = 1,
            Text = "",
            TextSize = 9,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ThemeTag = {
                TextColor3 = "Colors.Text.Dark",
                Font = "Font.Normal"
            }
        })

        task.spawn(refreshUserLabels)

        -- hover
        Connect(userPanel.MouseEnter, function()
            CreateTween(userBg, "BackgroundTransparency", 0.35, 0.15):Play()
        end)
        Connect(userPanel.MouseLeave, function()
            CreateTween(userBg, "BackgroundTransparency", 0.55, 0.15):Play()
        end)

        if userState.Callback then
            Connect(userPanel.Activated, function()
                task.spawn(userState.Callback)
            end)
        end

        -- keep width in sync with tab resizer
        Connect(tabsScroll:GetPropertyChangedSignal("Size"), function()
            userPanel.Size = UDim2.new(0, tabsScroll.Size.X.Offset - 8, 0, USER_PANEL_H)
        end)
    end

    api.User = {
        Enabled = userState.Enabled,
        Anonymous = userState.Anonymous,
        SetAnonymous = function(_, v)
            if v ~= false then v = true end
            userState.Anonymous = v
            api.User.Anonymous = v
            refreshUserLabels()
        end,
        Enable = function(_)
            userState.Enabled = true
            api.User.Enabled = true
            layoutUserPanel(true)
        end,
        Disable = function(_)
            userState.Enabled = false
            api.User.Enabled = false
            layoutUserPanel(false)
        end,
        ToggleAnonymous = function(_)
            api.User:SetAnonymous(not userState.Anonymous)
        end
    }

    local elements = table.freeze({
        ContainerHolder = containers,
        TabsContainer = tabsScroll,
        Components = components,
        MainFrame = window
    })

    function api:GetElements()
        return elements
    end

    -- Resizers
    local sizeResizer = New("Frame", "ControlWindowSize", window, {
        Size = UDim2.new(0, 35, 0, 35),
        Position = window.Size,
        AnchorPoint = Vector2.new(0.8, 0.8),
        BackgroundTransparency = 1,
        Active = true,
        Elements = { Corner = UDim.new(0, 6) },
        ThemeTag = { BackgroundColor3 = "Colors.OnPrimary" }
    })

    local tabResizer = New("Frame", "ControlTabsSize", window, {
        Size = UDim2.new(0, 16, 0.75, -30),
        Position = UDim2.new(0, tabsScroll.Size.X.Offset, 0.5, 15),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Active = true,
        Elements = { Corner = UDim.new(0, 6) },
        ThemeTag = { BackgroundColor3 = "Colors.OnPrimary" }
    })

    local function flashResizer(r)
        local last = r:GetAttribute("Resizing")
        r:SetAttribute("Resizing", tick())
        if last and (tick() - last) <= 0.1 then return end
        CreateTween(r, "BackgroundTransparency", 0.5, 0.3):Play()
        while tick() - r:GetAttribute("Resizing") <= 0.1 do task.wait() end
        CreateTween(r, "BackgroundTransparency", 1, 0.4):Play()
    end

    Connect(sizeResizer:GetPropertyChangedSignal("Position"), function()
        flashResizer(sizeResizer)
        local p = sizeResizer.Position
        window.Size = p
        settings.UISize = { p.X.Offset, p.Y.Offset }
    end)

    Connect(tabResizer:GetPropertyChangedSignal("Position"), function()
        flashResizer(tabResizer)
        local p = tabResizer.Position
        local ub = (api.User and api.User.Enabled) and (USER_PANEL_H + 8) or 0
        tabsScroll.Size = UDim2.new(0, p.X.Offset, 1, -(topBar.Size.Y.Offset + ub))
        tabsScroll.Position = UDim2.new(0, 0, 1, -ub)
        containers.Size = UDim2.new(1, -tabsScroll.Size.X.Offset, 1, -topBar.Size.Y.Offset)
        settings.TabSize = p.X.Offset
        if userPanel then
            userPanel.Size = UDim2.new(0, p.X.Offset - 8, 0, USER_PANEL_H)
        end
    end)

    Creator.Draggable(sizeResizer, scale, 0.55, function(_, x, _, y)
        return UDim2.fromOffset(math.clamp(x, 400, 1000), math.clamp(y, 220, 560))
    end)

    Creator.Draggable(tabResizer, scale, 0.55, function(_, x)
        return UDim2.new(0, math.clamp(x, 110, 180), 0.5, 12)
    end)

    -- Close confirm
    local function getCloseDialog()
        return {
            Title = Library:T("CloseWindow"),
            Content = Library:T("CloseWindowDesc"),
            Options = {
                { Title = Library:T("Yes"), Callback = function() self:Destroy() end },
                { Title = Library:T("No") }
            }
        }
    end

    Connect(minimizeBtn.MouseEnter, function() minimizeBtn.BackgroundTransparency = 0.65 end)
    Connect(minimizeBtn.MouseLeave, function() minimizeBtn.BackgroundTransparency = 1 end)
    Connect(closeBtn.MouseEnter, function() closeBtn.BackgroundTransparency = 0.65 end)
    Connect(closeBtn.MouseLeave, function() closeBtn.BackgroundTransparency = 1 end)

    api.SetUIScale = self.SetUIScale
    api.SUBTITLE_LABEL = titleLabel.SubTitle
    api.TITLE_LABEL = titleLabel
    api.AcrylicEnabled = acrylicOn

    function api:SetAcrylic(enabled)
        self.AcrylicEnabled = enabled == true
        acrylicLayer.Visible = self.AcrylicEnabled
        -- Only toggle acrylic overlay — never touch BackgroundImage or solid window bg
        if self.AcrylicEnabled then
            acrylicLayer.BackgroundTransparency = 0.45
            acrylicTint.BackgroundTransparency = 0.82
        else
            acrylicLayer.BackgroundTransparency = 1
            acrylicTint.BackgroundTransparency = 1
        end
        -- window solid bg stays from theme (BackgroundTransparency)
        local themeT = Library.CurrentTheme and Library.CurrentTheme.BackgroundTransparency or 0.03
        window.BackgroundTransparency = themeT
    end

    -- WindUI-style Tag (pill on topbar center — height 22, full radius, soft glass)
    local function TagTextColor(bg)
        local r, g, b = bg.R, bg.G, bg.B
        local lum = 0.299 * r + 0.587 * g + 0.114 * b
        return lum > 0.55 and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(255, 255, 255)
    end

    function api:AddTag(config)
        config = type(config) == "table" and config or { Title = tostring(config) }
        local text = config.Title or config.Name or config.Text or "Tag"
        local color = config.Color or config.BackgroundColor3
        local icon = config.Icon
        if typeof(color) ~= "Color3" then
            color = DeepGet(Library.CurrentTheme, "Colors.Primary")
        end
        local textCol = TagTextColor(color)

        local tag = New("Frame", tagsHolder, {
            Size = UDim2.fromOffset(0, 22),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.12,
            Elements = {
                Corner = UDim.new(1, 0),
                Padding = {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 0),
                    PaddingBottom = UDim.new(0, 0)
                },
                ListLayout = {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 5)
                }
            }
        })

        -- soft glass overlay (WindUI feel)
        New("Frame", tag, {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.88,
            ZIndex = 0,
            Elements = { Corner = UDim.new(1, 0) }
        })

        local iconLabel = nil
        if icon then
            iconLabel = New("ImageLabel", tag, {
                Size = UDim2.fromOffset(14, 14),
                BackgroundTransparency = 1,
                Image = NormalizeAssetId(icon) or "",
                ImageColor3 = textCol,
                ZIndex = 2
            })
        end

        local label = New("TextLabel", tag, {
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            Text = text,
            TextSize = 11,
            TextColor3 = textCol,
            Font = Enum.Font.GothamBold,
            ZIndex = 2
        })

        New("UIStroke", tag, {
            Thickness = 1,
            Color = color,
            Transparency = 0.55
        })

        return {
            Frame = tag,
            Label = label,
            Kind = "Tag",
            SetText = function(_, t)
                label.Text = tostring(t)
            end,
            SetColor = function(_, c)
                if typeof(c) == "Color3" then
                    tag.BackgroundColor3 = c
                    local tc = TagTextColor(c)
                    label.TextColor3 = tc
                    if iconLabel then iconLabel.ImageColor3 = tc end
                end
            end,
            SetIcon = function(_, ic)
                if iconLabel then iconLabel:Destroy() iconLabel = nil end
                if ic then
                    iconLabel = New("ImageLabel", tag, {
                        Size = UDim2.fromOffset(14, 14),
                        BackgroundTransparency = 1,
                        Image = NormalizeAssetId(ic) or "",
                        ImageColor3 = label.TextColor3,
                        ZIndex = 2
                    })
                end
            end,
            Destroy = function()
                tag:Destroy()
            end
        }
    end
    -- alias WindUI naming
    api.Tag = api.AddTag

    api:StartWindow({
        Resizers = { sizeResizer, tabResizer },
        MinimizeButton = minimizeBtn,
        Dropdowns = dropdowns,
        MainFrame = window,
        TopBar = topBar,
        SubTitle = titleLabel.SubTitle,
        Title = titleLabel,
        UIScale = scale,
        Flags = flags
    })

    -- Apply background image from config
    if windowConfig.BackgroundImage then
        api:SetBackgroundImage(windowConfig.BackgroundImage)
    end
    if windowConfig.BackgroundImageTransparency then
        api:SetBackgroundImageTransparency(windowConfig.BackgroundImageTransparency)
    end

    Connect(minimizeBtn.Activated, function() api:MinimizeButton() end)
    Connect(closeBtn.Activated, function() api:Dialog(getCloseDialog()) end)

    return api
end

return Library
