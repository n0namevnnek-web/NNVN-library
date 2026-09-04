--[[
    NNVN Hub UI Library (Gray/White Edition)
    ==========================================
    • Hỗ trợ scale cho điện thoại (0.65)
    • Đổi ngôn ngữ mượt mà (cập nhật ngay)
    • SaveManager tự động lưu mọi thay đổi
    • Hỗ trợ background qua rbxassetid
]]

local Players          = game:GetService("Players")
local Player           = Players.LocalPlayer
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local HttpService      = game:GetService("HttpService")

-- ============================================================
-- Palette
-- ============================================================
local ACCENT      = Color3.fromRGB(190, 190, 190)
local ACCENT_DIM  = Color3.fromRGB(120, 120, 120)
local BG_MAIN     = Color3.fromRGB(15,  15,  15)
local BG_SECTION  = Color3.fromRGB(255, 255, 255)
local TEXT_HI     = Color3.fromRGB(235, 235, 235)
local TEXT_LO     = Color3.fromRGB(140, 140, 140)

-- Lucide icon assets from the icon pack used by the linked library.
local LUCIDE_ICONS = {
    zap="rbxassetid://7733655755", star="rbxassetid://7734068321",
    clipboard="rbxassetid://7733734762", swords="rbxassetid://7733765307",
    settings="rbxassetid://7734053495", info="rbxassetid://7733964719",
    shield="rbxassetid://7734056608", ["shield-check"]="rbxassetid://7734056411",
    sparkles="rbxassetid://7734068321", users="rbxassetid://7743876054",
    sword="rbxassetid://7733765307", palette="rbxassetid://7734021595",
    sun="rbxassetid://7734068495", list="rbxassetid://7743869612",
    ["refresh-cw"]="rbxassetid://7734051052", ["battery-charging"]="rbxassetid://7733674402",
    ["cloud-off"]="rbxassetid://7733745572", eye="rbxassetid://7733774602",
    hash="rbxassetid://7733955906", crosshair="rbxassetid://7733765307",
    shuffle="rbxassetid://7734057059", ["repeat"]="rbxassetid://7734051454",
    play="rbxassetid://7743871480", ["play-circle"]="rbxassetid://7734037784",
    check="rbxassetid://7733715400", ["check-circle"]="rbxassetid://7733919427",
    tag="rbxassetid://7734075797", ["file-text"]="rbxassetid://7733789088",
    target="rbxassetid://7743872758", move="rbxassetid://7743870731",
    activity="rbxassetid://7733655755", search="rbxassetid://7734052925",
    ["log-in"]="rbxassetid://7733992604", ["rotate-ccw"]="rbxassetid://7734051861",
    ["message-circle"]="rbxassetid://7733993311", crown="rbxassetid://7733765398",
    user="rbxassetid://7743875962", code="rbxassetid://7733749837",
    terminal="rbxassetid://7743872929", link="rbxassetid://7733978098",
    x="rbxassetid://7743878857",
}

local function ResolveLucideIcon(icon)
    if type(icon) ~= "string" or icon == "" then return nil end
    if icon:match("^rbxassetid://") then return icon end
    return LUCIDE_ICONS[string.lower(icon)]
end

-- ============================================================
-- Custom helper + Ngôn ngữ + Scale
-- ============================================================
local Custom = {}
Custom.ColorRGB = ACCENT
Custom.Language = "en"
Custom.Scale    = 1  -- sẽ được set dựa trên mobile

Custom.Translations = {
    en = {
        Search        = "Search",
        WriteInput    = "Write your input here",
        SelectOptions = "Select options",
        Close         = "X",
        Minimize      = "-",
    },
    vi = {
        Search        = "Tìm kiếm",
        WriteInput    = "Nhập nội dung tại đây",
        SelectOptions = "Chọn tùy chọn",
        Close         = "X",
        Minimize      = "-",
    }
}

function Custom:T(key)
    local lang = Custom.Translations[Custom.Language] or Custom.Translations["en"]
    return lang[key] or key
end

function Custom:SetLanguage(lang)
    if lang == "vi" or lang == "en" then
        Custom.Language = lang
        -- Cập nhật tất cả các label trong GUI hiện tại
        Custom:UpdateLanguage()
    end
end

-- Lưu tham chiếu các label cần cập nhật
Custom._languageLabels = {}

function Custom:RegisterLanguageLabel(label, key, prop)
    -- prop = "Text" (default) hoặc "PlaceholderText" cho TextBox
    prop = prop or "Text"
    table.insert(Custom._languageLabels, {label = label, key = key, prop = prop})
    if prop == "PlaceholderText" then
        label.PlaceholderText = Custom:T(key)
    else
        label.Text = Custom:T(key)
    end
end

function Custom:UpdateLanguage()
    for _, entry in ipairs(Custom._languageLabels) do
        local newText = Custom:T(entry.key)
        if entry.prop == "PlaceholderText" then
            entry.label.PlaceholderText = newText
        else
            -- Chỉ cập nhật Text nếu đang hiển thị 1 trong các bản dịch cũ của key (tránh ghi đè giá trị đã chọn của dropdown)
            local isPlaceholder = false
            for _, langTable in pairs(Custom.Translations) do
                if entry.label.Text == (langTable[entry.key] or entry.key) then
                    isPlaceholder = true
                    break
                end
            end
            if isPlaceholder then
                entry.label.Text = newText
            end
        end
    end
end

function Custom:Create(Name, Props, Parent)
    local inst = Instance.new(Name)
    for k, v in pairs(Props) do inst[k] = v end
    if Parent then inst.Parent = Parent end
    return inst
end

function Custom:EnabledAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end
Custom:EnabledAFK()

-- ============================================================
-- Ripple click effect
-- ============================================================
local function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true
        local C = Instance.new("ImageLabel")
        C.Image             = "rbxassetid://106471194043211"
        C.ImageColor3       = Color3.fromRGB(200,200,200)
        C.ImageTransparency = 0.75
        C.BackgroundTransparency = 1
        C.ZIndex            = 10
        C.Name              = "Circle"
        C.Parent            = Button
        local nx = X - Button.AbsolutePosition.X
        local ny = Y - Button.AbsolutePosition.Y
        C.Position = UDim2.new(0, nx, 0, ny)
        local sz = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
        local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(C, ti, {
            Size = UDim2.new(0,sz,0,sz),
            Position = UDim2.new(0.5,-sz/2,0.5,-sz/2)
        }):Play()
        task.wait(0.5)
        for _ = 1,10 do C.ImageTransparency = C.ImageTransparency + 0.025; task.wait(0.02) end
        C:Destroy()
    end)
end

-- ============================================================
-- Minimize/restore button (floating icon)
-- ============================================================
local function OpenClose()
    local SG = Custom:Create("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Sibling},
        RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui() or cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")))

    local Btn = Custom:Create("ImageButton", {
        BackgroundColor3     = Color3.fromRGB(30,30,30),
        BackgroundTransparency = 0.3,
        BorderSizePixel      = 0,
        Position             = UDim2.new(0.05, 0, 0.07, 0),
        Size                 = UDim2.new(0, 52, 0, 42),
        Image                = "rbxassetid://138952058031836",
        ImageColor3          = ACCENT,
        Visible              = false,
    }, SG)
    Custom:Create("UICorner", {CornerRadius = UDim.new(0,9)}, Btn)
    Custom:Create("UIStroke", {Color = ACCENT_DIM, Thickness = 1.2}, Btn)

    local drag, ds, sp = false, nil, nil
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = Btn.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    Btn.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    return Btn
end

local Open_Close = OpenClose()

local function MakeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = target.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ============================================================
-- NNVN Hub main object
-- ============================================================
local NNVN_Hub = {}
NNVN_Hub.Unloaded = false

-- ============================================================
-- Notifications — bottom-RIGHT
-- ============================================================
local _notifyGui = nil
local _notifyLayout = nil

local function EnsureNotifyGui()
    if _notifyGui and _notifyGui.Parent then return end
    _notifyGui = Custom:Create("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Sibling},
        RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui() or cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")))

    _notifyLayout = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        Position             = UDim2.new(1,-20, 1,-20),
        Size                 = UDim2.new(0, 300, 1, 0),
        Name                 = "NotifyLayout"
    }, _notifyGui)
end

function NNVN_Hub:SetNotification(Config)
    local Title   = Config[1] or Config.Title       or ""
    local Desc    = Config[2] or Config.Description or ""
    local Content = Config[3] or Config.Content     or ""
    local Time    = Config[5] or Config.Time        or 0.4
    local Delay   = Config[6] or Config.Delay       or 5

    EnsureNotifyGui()
    local Layout = _notifyLayout

    Layout.ChildRemoved:Connect(function()
        local count = 0
        local ti = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        for _, v in ipairs(Layout:GetChildren()) do
            local newPos = UDim2.new(0,0, 1, -((v.Size.Y.Offset+10)*count))
            TweenService:Create(v, ti, {Position = newPos}):Play()
            count += 1
        end
    end)

    local stackOff = 0
    for _, v in ipairs(Layout:GetChildren()) do
        stackOff = -(v.Position.Y.Offset) + v.Size.Y.Offset + 10
    end

    local NFrame = Custom:Create("Frame", {
        AnchorPoint          = Vector2.new(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(1,0,0,90),
        Position             = UDim2.new(1,0, 1,-stackOff),
        Name                 = "NFrame"
    }, Layout)

    local NReal = Custom:Create("Frame", {
        BackgroundColor3     = Color3.fromRGB(28,28,28),
        BorderSizePixel      = 0,
        Position             = UDim2.new(0, 320, 0, 0),
        Size                 = UDim2.new(1,0,1,0),
        Name                 = "NReal"
    }, NFrame)
    Custom:Create("UICorner",  {CornerRadius = UDim.new(0,8)}, NReal)
    Custom:Create("UIStroke",  {Color = ACCENT_DIM, Thickness = 1}, NReal)

    local Top = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        Size                 = UDim2.new(1,0,0,34),
        Name                 = "Top"
    }, NReal)

    Custom:Create("TextLabel", {
        Font        = Enum.Font.GothamBold,
        Text        = Title,
        TextColor3  = TEXT_HI,
        TextSize    = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size        = UDim2.new(0.55,0,1,0),
        Position    = UDim2.new(0,10,0,0),
    }, Top)

    local DescLabel = Custom:Create("TextLabel", {
        Font        = Enum.Font.GothamBold,
        Text        = Desc,
        TextColor3  = ACCENT,
        TextSize    = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size        = UDim2.new(0.4,0,1,0),
        Position    = UDim2.new(0.56,0,0,0),
    }, Top)
    Custom:Create("UIStroke", {Color = ACCENT_DIM, Thickness = 0.3}, DescLabel)

    local XBtn = Custom:Create("TextButton", {
        Font        = Enum.Font.GothamBold,
        Text        = "×",
        TextColor3  = TEXT_LO,
        TextSize    = 16,
        AnchorPoint = Vector2.new(1,0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position    = UDim2.new(1,-6,0.5,0),
        Size        = UDim2.new(0,24,0,24),
    }, Top)

    Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5,0),
        BackgroundColor3 = ACCENT_DIM,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position    = UDim2.new(0.5,0,0,34),
        Size        = UDim2.new(0.9,0,0,1),
    }, NReal)

    local ContentLabel = Custom:Create("TextLabel", {
        Font        = Enum.Font.GothamBold,
        Text        = Content,
        TextColor3  = TEXT_LO,
        TextSize    = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position    = UDim2.new(0,10,0,38),
        Size        = UDim2.new(1,-20,0,40),
    }, NReal)

    task.defer(function()
        local h = math.max(90, ContentLabel.TextBounds.Y + 48)
        NFrame.Size = UDim2.new(1,0,0,h)
        ContentLabel.Size = UDim2.new(1,-20,0, h-48)
    end)

    local PBar = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0,1),
        BackgroundColor3 = ACCENT_DIM,
        BorderSizePixel = 0,
        Position    = UDim2.new(0,0,1,0),
        Size        = UDim2.new(1,0,0,2),
    }, NReal)
    Custom:Create("UICorner", {CornerRadius = UDim.new(0,2)}, PBar)

    local closed = false
    local function Close()
        if closed then return end; closed = true
        TweenService:Create(NReal, TweenInfo.new(Time, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0, 320, 0, 0)}):Play()
        task.wait(Time * 1.1)
        NFrame:Destroy()
    end

    XBtn.Activated:Connect(Close)

    TweenService:Create(NReal, TweenInfo.new(Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0,0,0,0)}):Play()

    task.spawn(function()
        TweenService:Create(PBar, TweenInfo.new(Delay, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0,0,0,2)}):Play()
        task.wait(Delay)
        Close()
    end)
end

-- ============================================================
-- Discord API helpers
-- ============================================================
function NNVN_Hub:FetchDiscord(Config)
    local GuildId  = Config.GuildId  or Config[1] or ""
    local Token    = Config.BotToken or Config[2] or ""
    local Callback = Config.Callback or Config[3] or function() end

    task.spawn(function()
        local reqFunc = (syn and syn.request) or (http and http.request) or request
        if not reqFunc then
            Callback(nil, "No HTTP function available (try syn.request / request)")
            return
        end

        local ok, res = pcall(reqFunc, {
            Url    = "https://discord.com/api/v10/guilds/" .. GuildId .. "?with_counts=true",
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bot " .. Token,
                ["Content-Type"]  = "application/json",
            }
        })

        if ok and res and res.StatusCode == 200 then
            local ok2, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if ok2 then
                Callback({
                    name         = data.name or "",
                    icon         = data.icon or "",
                    members      = data.approximate_member_count or 0,
                    online       = data.approximate_presence_count or 0,
                    raw          = data,
                }, nil)
            else
                Callback(nil, "JSON decode failed")
            end
        else
            local code = res and res.StatusCode or "?"
            Callback(nil, "HTTP " .. tostring(code))
        end
    end)
end

function NNVN_Hub:GetDiscordIconUrl(GuildId, IconHash, Size)
    if not IconHash or IconHash == "" then return "" end
    return "https://cdn.discordapp.com/icons/" .. GuildId .. "/" .. IconHash .. ".png?size=" .. (Size or 128)
end

-- ============================================================
-- SaveManager tích hợp
-- ============================================================
local SAVE_FILE = "NNVNSettings.json"
local Settings = {}
local function LoadSettings()
    if isfile(SAVE_FILE) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(SAVE_FILE)) end)
        if ok and type(data) == "table" then
            Settings = data
        end
    end
end
local function SaveSettings()
    local ok, json = pcall(HttpService.JSONEncode, HttpService, Settings)
    if ok then
        writefile(SAVE_FILE, json)
    end
end
LoadSettings()

-- Hàm hỗ trợ lưu/load cho từng control
function NNVN_Hub:SaveValue(key, value)
    Settings[key] = value
    SaveSettings()
end
function NNVN_Hub:LoadValue(key, default)
    if Settings[key] ~= nil then
        return Settings[key]
    end
    return default
end

-- ============================================================
-- CreateWindow
-- ============================================================
function NNVN_Hub:CreateWindow(Config)
    local Title    = Config[1] or Config.Title       or "NNVN Hub"
    local Desc     = Config[2] or Config.Description or "v1.0"
    local TabWidth = Config[3] or Config["Tab Width"] or
        ((UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 90 or 130)
    local Language = Config.Language or Config[5] or "en"
    Custom:SetLanguage(Language)

    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if not IsMobile then
        local cam = workspace.CurrentCamera
        if cam and cam.ViewportSize.X < 700 then IsMobile = true end
    end

    -- Scale cho mobile
    if IsMobile then
        Custom.Scale = 0.65
    else
        Custom.Scale = 1
    end
    local sc = Custom.Scale

    local DefaultSize    = IsMobile and UDim2.fromOffset(300*sc, 230*sc) or UDim2.fromOffset(700, 420)
    local SizeUi         = Config[4] or Config.SizeUi or DefaultSize
    local WindowMinSize  = Config.MinSize or (IsMobile and Vector2.new(260*sc,200*sc) or Vector2.new(480,300))
    local WindowMaxSize  = Config.MaxSize or (IsMobile and Vector2.new(480*sc,380*sc) or Vector2.new(1100,720))

    local NNGui = Custom:Create("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Sibling},
        RunService:IsStudio() and Player.PlayerGui
        or (gethui and gethui() or cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")))

    local ShadowHolder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = SizeUi,
        Position               = UDim2.new(0.5,-SizeUi.X.Offset//2, 0.5,-SizeUi.Y.Offset//2),
        Name                   = "ShadowHolder"
    }, NNGui)

    local Shadow = Custom:Create("ImageLabel", {
        Image              = "",
        ImageColor3        = Color3.fromRGB(10,10,10),
        ImageTransparency  = 0.55,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(49,49,450,450),
        AnchorPoint        = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        BorderSizePixel    = 0,
        Position           = UDim2.new(0.5,0,0.5,0),
        Size               = SizeUi,
        Name               = "Shadow"
    }, ShadowHolder)

    -- Main frame (có thể đặt background image)
    local Main = Custom:Create("Frame", {
        AnchorPoint        = Vector2.new(0.5,0.5),
        BackgroundColor3   = BG_MAIN,
        BackgroundTransparency = 0.08,
        BorderSizePixel    = 0,
        Position           = UDim2.new(0.5,0,0.5,0),
        Size               = SizeUi,
        Name               = "Main",
        ClipsDescendants   = true,
    }, Shadow)
    Custom:Create("UICorner", {}, Main)
    Custom:Create("UIStroke", {Color = Color3.fromRGB(55,55,55), Thickness = 1.4}, Main)

    -- Background image (nếu có)
    local bgId = Config.BackgroundAssetId or Config.Background
    if bgId and tonumber(bgId) then
        local bg = Custom:Create("ImageLabel", {
            Image = "rbxassetid://" .. tostring(bgId),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0),
            ScaleType = Enum.ScaleType.Fit,
            Name = "BackgroundImage",
            ZIndex = 0,
        }, Main)
        -- Đảm bảo các thành phần khác nằm trên
        for _, child in ipairs(Main:GetChildren()) do
            if child ~= bg then child.ZIndex = child.ZIndex + 1 end
        end
    end

    -- ── Top bar ──────────────────────────────────────────────
    local Top = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1,0,0,38*sc),
        Name                   = "Top"
    }, Main)
    Custom:Create("UICorner", {}, Top)

    -- Title + Tag (giống WindUI)
    local TitleLabel = Custom:Create("TextLabel", {
        Font           = Enum.Font.GothamBold,
        Text           = Title,
        TextColor3     = TEXT_HI,
        TextSize       = 14*sc,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize   = Enum.AutomaticSize.X,
        Size           = UDim2.new(0,0,1,0),
        Position       = UDim2.new(0,10*sc,0,0),
        Name           = "WindowTitle",
    }, Top)

    local TagFrame
    local TagLabel

    local function UpdateTagLayout()
        task.defer(function()
            if not TagFrame or not TagLabel or not TagFrame.Visible then return end
            local gap = 8*sc
            TagFrame.Position = UDim2.new(0,10*sc + TitleLabel.TextBounds.X + gap,0.5,0)
            TagFrame.Size = UDim2.new(0,TagLabel.TextBounds.X + 14*sc,0,20*sc)
        end)
    end

    local function SetWindowTag(TagConfig)
        local TagText = type(TagConfig) == "table"
            and (TagConfig.Title or TagConfig.Text or TagConfig.Tag or "")
            or (TagConfig or "")
        local TagColor = type(TagConfig) == "table" and TagConfig.Color or nil
        TagText = tostring(TagText)

        if TagText == "" then
            if TagFrame then TagFrame.Visible = false end
            return
        end

        if not TagFrame then
            TagFrame = Custom:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(234,179,8),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0,0.5),
                Position = UDim2.new(0,0,0.5,0),
                Size = UDim2.new(0,0,0,20*sc),
                Name = "WindowTag",
            }, Top)
            Custom:Create("UICorner", {CornerRadius = UDim.new(0,5*sc)}, TagFrame)
            Custom:Create("UIStroke", {
                Color = Color3.fromRGB(161,98,7),
                Thickness = 0.8,
                Transparency = 0.1,
            }, TagFrame)

            TagLabel = Custom:Create("TextLabel", {
                Font = Enum.Font.GothamMedium,
                TextColor3 = Color3.fromRGB(30,30,30),
                TextSize = 10*sc,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -14*sc, 1, 0),
                Position = UDim2.new(0,7*sc,0,0),
                Name = "TagText",
            }, TagFrame)
        end

        TagFrame.Visible = true
        TagFrame.BackgroundColor3 = typeof(TagColor) == "Color3" and TagColor or Color3.fromRGB(234,179,8)
        TagLabel.Text = TagText
        UpdateTagLayout()
    end

    SetWindowTag(Config.Tag or Config.tag)
    TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateTagLayout)

    local DescLabel = Custom:Create("TextLabel", {
        Font           = Enum.Font.GothamBold,
        Text           = Desc,
        TextColor3     = ACCENT,
        TextSize       = 13*sc,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size           = UDim2.new(0.3,0,1,0),
        Position       = UDim2.new(0.56,0,0,0),
    }, Top)
    Custom:Create("UIStroke", {Color = ACCENT_DIM, Thickness = 0.35}, DescLabel)

    local Lucide = {
        Maximize = "rbxassetid://7733992982",
        Minimize = "rbxassetid://7733997941",
        Minus    = "rbxassetid://7734000129",
        X        = "rbxassetid://7743878857",
    }

    local function MakeWinBtn(Name, IconId, PosX, BgColor, BgTrans)
        local Btn = Custom:Create("TextButton", {
            Text        = "",
            AnchorPoint = Vector2.new(1,0.5),
            BackgroundColor3 = BgColor,
            BackgroundTransparency = BgTrans,
            BorderSizePixel = 0,
            Position    = UDim2.new(1, PosX, 0.5, 0),  -- PosX đã được scale sẵn từ ngoài
            Size        = UDim2.new(0,28*sc,0,22*sc),
            Name        = Name,
            AutoButtonColor = false,
        }, Top)
        Custom:Create("UICorner", {CornerRadius = UDim.new(0,4)}, Btn)
        local Img = Custom:Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image       = IconId,
            ImageColor3 = Color3.fromRGB(220,220,220),
            Size        = UDim2.new(0,14*sc,0,14*sc),
            Position    = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ScaleType   = Enum.ScaleType.Fit,
            Name        = "Icon",
        }, Btn)
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = math.max(0,BgTrans-0.25)}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = BgTrans}):Play()
        end)
        return Btn, Img
    end

    -- Spacing lớn hơn trên mobile (button ~28*sc, gap ~10*sc)
    local btnW = 28 * sc
    local gap  = math.max(8, 10 * sc)  -- tối thiểu 8px
    local CloseBtn, _  = MakeWinBtn("Close", Lucide.X,        -(4 + btnW),                 Color3.fromRGB(80,80,80), 0.4)
    local MaxBtn, MaxIco = MakeWinBtn("Max", Lucide.Maximize, -(4 + btnW + gap + btnW),     Color3.fromRGB(55,55,55), 0.5)
    local MinBtn, _    = MakeWinBtn("Min",  Lucide.Minus,    -(4 + btnW + gap + btnW + gap + btnW), Color3.fromRGB(55,55,55), 0.5)

    Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5,0),
        BackgroundColor3 = Color3.fromRGB(50,50,50),
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5,0,0,38*sc),
        Size             = UDim2.new(1,0,0,1),
    }, Main)

    -- ── Tab list ─────────────────────────────────────────────
    local LayersTab = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0,9*sc,0,50*sc),
        Size             = UDim2.new(0,TabWidth*sc,1,-59*sc),
        Name             = "LayersTab"
    }, Main)
    Custom:Create("UICorner", {CornerRadius = UDim.new(0,2)}, LayersTab)

    Custom:Create("Frame", {
        BackgroundColor3  = Color3.fromRGB(48,48,48),
        BorderSizePixel   = 0,
        Position          = UDim2.new(0, (TabWidth+14)*sc, 0, 50*sc),
        Size              = UDim2.new(0,1,1,-58*sc),
    }, Main)

    -- ── Content area ──────────────────────────────────────────
    local Layers = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0, (TabWidth+20)*sc, 0, 50*sc),
        Size             = UDim2.new(1, -(TabWidth+28)*sc, 1, -59*sc),
        Name             = "Layers"
    }, Main)

    local NameTab = Custom:Create("TextLabel", {
        Font           = Enum.Font.GothamBold,
        Text           = "",
        TextColor3     = TEXT_HI,
        TextSize       = 15*sc,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size           = UDim2.new(1,0,0,28*sc),
        Name           = "NameTab"
    }, Layers)

    local LayersReal = Custom:Create("Frame", {
        AnchorPoint    = Vector2.new(0,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position       = UDim2.new(0,0,1,0),
        Size           = UDim2.new(1,0,1,-31*sc),
        Name           = "LayersReal"
    }, Layers)

    local LayersFolder = Custom:Create("Folder", {Name = "LayersFolder"}, LayersReal)

    local LayersPageLayout = Custom:Create("UIPageLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        TweenTime       = 0.45,
        EasingDirection = Enum.EasingDirection.InOut,
        EasingStyle     = Enum.EasingStyle.Quad,
        Name            = "LayersPageLayout"
    }, LayersFolder)

    local ScrollTab = Custom:Create("ScrollingFrame", {
        CanvasSize        = UDim2.new(0,0,2,0),
        ScrollBarThickness = 0,
        Active            = true,
        BackgroundTransparency = 1,
        BorderSizePixel   = 0,
        Size              = UDim2.new(1,0,1,-8*sc),
        Name              = "ScrollTab"
    }, LayersTab)
    Custom:Create("UIListLayout", {Padding = UDim.new(0,0), SortOrder = Enum.SortOrder.LayoutOrder}, ScrollTab)

    local function UpdateScrollCanvas()
        local h = 0
        for _, v in pairs(ScrollTab:GetChildren()) do
            if v.Name ~= "UIListLayout" then h += 3*sc + v.Size.Y.Offset end
        end
        ScrollTab.CanvasSize = UDim2.new(0,0,0,h)
    end
    ScrollTab.ChildAdded:Connect(UpdateScrollCanvas)
    ScrollTab.ChildRemoved:Connect(UpdateScrollCanvas)

    -- ── Window state ──────────────────────────────────────────
    local IsMaximized = false
    local SavedPos    = ShadowHolder.Position
    local SavedSize   = SizeUi
    local CanResize   = true

    MinBtn.Activated:Connect(function()
        CircleClick(MinBtn, Player:GetMouse().X, Player:GetMouse().Y)
        ShadowHolder.Visible = false
        Open_Close.Visible   = true
    end)
    Open_Close.Activated:Connect(function()
        ShadowHolder.Visible = true
        Open_Close.Visible   = false
    end)
    CloseBtn.Activated:Connect(function()
        CircleClick(CloseBtn, Player:GetMouse().X, Player:GetMouse().Y)
        if NNGui then NNGui:Destroy() end
        NNVN_Hub.Unloaded = true
    end)

    local function ToggleMaximize()
        CircleClick(MaxBtn, Player:GetMouse().X, Player:GetMouse().Y)
        local cam = workspace.CurrentCamera
        local vs  = cam and cam.ViewportSize or Vector2.new(1280,720)
        local ti  = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

        if not IsMaximized then
            SavedPos  = ShadowHolder.Position
            SavedSize = Shadow.Size

            local fullSize = UDim2.fromOffset(vs.X, vs.Y)
            local fullPos  = UDim2.new(0,0,0,0)

            TweenService:Create(Shadow,       ti, {Size = fullSize}):Play()
            TweenService:Create(Main,         ti, {Size = fullSize}):Play()
            TweenService:Create(ShadowHolder, ti, {Size = fullSize, Position = fullPos}):Play()

            MaxIco.Image  = Lucide.Minimize
            IsMaximized   = true
            CanResize     = false
        else
            TweenService:Create(Shadow,       ti, {Size = SavedSize}):Play()
            TweenService:Create(Main,         ti, {Size = SavedSize}):Play()
            TweenService:Create(ShadowHolder, ti, {Size = SavedSize, Position = SavedPos}):Play()

            MaxIco.Image  = Lucide.Maximize
            IsMaximized   = false
            CanResize     = true
        end
    end
    MaxBtn.Activated:Connect(ToggleMaximize)

    ShadowHolder.Size = SizeUi
    MakeDraggable(Top, ShadowHolder)

    -- ── Bottom drag bar ───────────────────────────────────────
    local BottomBar = Custom:Create("Frame", {
        AnchorPoint      = Vector2.new(0.5,1),
        BackgroundColor3 = Color3.fromRGB(160,160,160),
        BackgroundTransparency = 0.75,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5,0,1,-5*sc),
        Size             = UDim2.new(0,110*sc,0,4*sc),
        Name             = "BottomBar",
        ZIndex           = 5,
    }, Main)
    Custom:Create("UICorner", {CornerRadius = UDim.new(1,0)}, BottomBar)

    local BBHit = Custom:Create("TextButton", {
        Text             = "",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1,40*sc,1,18*sc),
        Position         = UDim2.new(0.5,0,0.5,0),
        AnchorPoint      = Vector2.new(0.5,0.5),
        ZIndex           = 6,
    }, BottomBar)
    BBHit.MouseEnter:Connect(function()
        TweenService:Create(BottomBar, TweenInfo.new(0.15),
            {BackgroundTransparency=0.35, Size=UDim2.new(0,150*sc,0,4*sc)}):Play()
    end)
    BBHit.MouseLeave:Connect(function()
        if not BBHit:GetAttribute("Dragging") then
            TweenService:Create(BottomBar, TweenInfo.new(0.2),
                {BackgroundTransparency=0.75, Size=UDim2.new(0,110*sc,0,4*sc)}):Play()
        end
    end)
    do
        local drag, ds, sp = false, nil, nil
        BBHit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; BBHit:SetAttribute("Dragging",true)
                ds = i.Position; sp = ShadowHolder.Position
                TweenService:Create(BottomBar, TweenInfo.new(0.1),
                    {BackgroundTransparency=0.15, BackgroundColor3=ACCENT_DIM}):Play()
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        drag = false; BBHit:SetAttribute("Dragging",false)
                        TweenService:Create(BottomBar, TweenInfo.new(0.2), {
                            BackgroundTransparency=0.75,
                            BackgroundColor3=Color3.fromRGB(160,160,160),
                            Size=UDim2.new(0,110*sc,0,4*sc)
                        }):Play()
                    end
                end)
            end
        end)
        BBHit.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - ds
                ShadowHolder.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
    end

    -- ── Resize handle ──────────────────────────────────────────
    local ResizeHandle = Custom:Create("Frame", {
        AnchorPoint      = Vector2.new(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Position         = UDim2.new(1,0,1,0),
        Size             = UDim2.new(0,22*sc,0,22*sc),
        Name             = "ResizeHandle",
        ZIndex           = 10,
    }, Main)
    local ResizeIcon = Custom:Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image       = "rbxassetid://7733992901",
        ImageColor3 = ACCENT_DIM,
        ImageTransparency = 0.45,
        Size        = UDim2.new(0,14*sc,0,14*sc),
        Position    = UDim2.new(1,-16*sc,1,-16*sc),
        ZIndex      = 11,
    }, ResizeHandle)
    do
        local res, si, ss = false, nil, nil
        ResizeHandle.InputBegan:Connect(function(i)
            if not CanResize then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                res = true; si = i.Position; ss = Shadow.AbsoluteSize
                TweenService:Create(ResizeIcon, TweenInfo.new(0.1), {ImageTransparency=0.05, ImageColor3=ACCENT}):Play()
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        res = false
                        TweenService:Create(ResizeIcon, TweenInfo.new(0.15), {ImageTransparency=0.45, ImageColor3=ACCENT_DIM}):Play()
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if res and CanResize and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d  = i.Position - si
                local nw = math.clamp(ss.X+d.X, WindowMinSize.X, WindowMaxSize.X)
                local nh = math.clamp(ss.Y+d.Y, WindowMinSize.Y, WindowMaxSize.Y)
                local ns = UDim2.fromOffset(nw,nh)
                Shadow.Size       = ns
                Main.Size         = ns
                ShadowHolder.Size = ns
                if not IsMaximized then SavedSize = ns end
            end
        end)
    end

    -- ── Dropdown overlay ────────────────────────────────────────
    local MoreBlur = Custom:Create("Frame", {
        AnchorPoint      = Vector2.new(1,1),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Position         = UDim2.new(1,8*sc,1,8*sc),
        Size             = UDim2.new(1,154*sc,1,54*sc),
        Visible          = false,
        Name             = "MoreBlur"
    }, Layers)
    Custom:Create("UICorner", {}, MoreBlur)

    local ConnectBtn = Custom:Create("TextButton", {
        Text             = "",
        BackgroundTransparency = 0.999,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1,0,1,0),
    }, MoreBlur)

    local DropdownSelect = Custom:Create("Frame", {
        AnchorPoint      = Vector2.new(1,0.5),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
        Position         = UDim2.new(1,172*sc,0.5,0),
        Size             = UDim2.new(0,160*sc,1,-16*sc),
        Name             = "DropdownSelect",
        ClipsDescendants = true,
    }, MoreBlur)
    Custom:Create("UICorner", {CornerRadius = UDim.new(0,3)}, DropdownSelect)
    Custom:Create("UIStroke", {Color = ACCENT_DIM, Thickness = 1.5, Transparency = 0.4}, DropdownSelect)

    ConnectBtn.Activated:Connect(function()
        if MoreBlur.Visible then
            local ti = TweenInfo.new(0.2)
            TweenService:Create(MoreBlur,        ti, {BackgroundTransparency=0.999}):Play()
            TweenService:Create(DropdownSelect,  ti, {Position=UDim2.new(1,172*sc,0.5,0)}):Play()
            task.wait(0.22); MoreBlur.Visible = false
        end
    end)

    local DropdownSelectReal = Custom:Create("Frame", {
        AnchorPoint      = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5,0,0.5,0),
        Size             = UDim2.new(1,-10*sc,1,-10*sc),
        Name             = "DropdownSelectReal"
    }, DropdownSelect)

    -- UIPageLayout must be parented to a GuiObject. A Folder causes the
    -- selected dropdown page to remain blank on some clients.
    local DropdownFolder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        Name = "DropdownFolder",
    }, DropdownSelectReal)
    local DropPageLayout = Custom:Create("UIPageLayout", {
        EasingDirection = Enum.EasingDirection.InOut,
        EasingStyle     = Enum.EasingStyle.Quad,
        TweenTime       = 0.01,
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Name            = "DropPageLayout"
    }, DropdownFolder)

    -- ============================================================
    -- CreateTab
    -- ============================================================
    local Tabs      = {}
    local CountTab  = 0
    local CountDD   = 0

    -- Compatible with Window:Tag({...}) and allows the FREE/PREMIUM pill
    -- to update after the window has been created.
    function Tabs:Tag(Config)
        SetWindowTag(Config)
    end

    function Tabs:SetTag(Config)
        SetWindowTag(Config)
    end

    function Tabs:CreateTab(Config)
        local _Name = Config[1] or Config.Name or ""
        local Icon  = Config[2] or Config.Icon or ""

        local ScrolLayers = Custom:Create("ScrollingFrame", {
            ScrollBarImageColor3 = Color3.fromRGB(80,80,80),
            ScrollBarThickness   = 0,
            Active               = true,
            LayoutOrder          = CountTab,
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            Size                 = UDim2.new(1,0,1,0),
            Name                 = "ScrolLayers",
        }, LayersFolder)
        Custom:Create("UIListLayout", {Padding=UDim.new(0,3*sc), SortOrder=Enum.SortOrder.LayoutOrder}, ScrolLayers)

        local Tab = Custom:Create("Frame", {
            BackgroundColor3     = Color3.fromRGB(255,255,255),
            BackgroundTransparency = CountTab==0 and 0.88 or 0.999,
            BorderSizePixel      = 0,
            LayoutOrder          = CountTab,
            Size                 = UDim2.new(1,0,0,30*sc),
            Name                 = "Tab",
        }, ScrollTab)
        Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, Tab)

        local TabBtn = Custom:Create("TextButton", {
            Text             = "",
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1,0,1,0),
            Name             = "TabButton",
        }, Tab)

        Custom:Create("TextLabel", {
            Font             = Enum.Font.GothamBold,
            Text             = _Name,
            TextColor3       = TEXT_HI,
            TextSize         = 12*sc,
            TextXAlignment   = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1,-6*sc,1,0),
            Position         = UDim2.new(0,28*sc,0,0),
            Name             = "TabName",
        }, Tab)

        local IconAsset = ResolveLucideIcon(Icon)
        if IconAsset then
            Custom:Create("ImageLabel", {
                Image = IconAsset,
                ImageColor3 = ACCENT,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0,7*sc,0,6*sc),
                Size = UDim2.new(0,18*sc,0,18*sc),
            }, Tab)
        else
            Custom:Create("ImageLabel", {
                Image            = Icon,
                ImageColor3      = ACCENT,
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0,8*sc,0,7*sc),
                Size             = UDim2.new(0,15*sc,0,15*sc),
            }, Tab)
        end

        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = _Name

            local CF = Custom:Create("Frame", {
                BackgroundColor3 = ACCENT,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0,2*sc,0,9*sc),
                Size             = UDim2.new(0,2*sc,0,12*sc),
                Name             = "ChooseFrame",
            }, Tab)
            Custom:Create("UICorner", {}, CF)
            Custom:Create("UIStroke", {Color=ACCENT, Thickness=1}, CF)
        end

        TabBtn.Activated:Connect(function()
            CircleClick(TabBtn, Player:GetMouse().X, Player:GetMouse().Y)
            local CF = nil
            for _, s in pairs(ScrollTab:GetChildren()) do
                for _, v in pairs(s:GetChildren()) do
                    if v.Name == "ChooseFrame" then CF = v; break end
                end
                if CF then break end
            end
            if CF and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, tf in pairs(ScrollTab:GetChildren()) do
                    if tf.Name == "Tab" then
                        TweenService:Create(tf, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.InOut),
                            {BackgroundTransparency=0.999}):Play()
                    end
                end
                TweenService:Create(Tab, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.InOut),
                    {BackgroundTransparency=0.88}):Play()
                TweenService:Create(CF, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),
                    {Position=UDim2.new(0,2*sc,0,9*sc+(33*sc*Tab.LayoutOrder))}):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = _Name
                TweenService:Create(CF, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),
                    {Size=UDim2.new(0,2*sc,0,20*sc)}):Play()
                task.wait(0.18)
                TweenService:Create(CF, TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),
                    {Size=UDim2.new(0,2*sc,0,12*sc)}):Play()
            end
        end)

        -- ── AddSection ──────────────────────────────────────────
        local Sections  = {}
        local CountSec  = 0

        function Sections:AddSection(Title, OpenSection, Icon)
            Title       = Title or ""
            OpenSection = OpenSection ~= nil and OpenSection or false

            local Section = Custom:Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                LayoutOrder      = CountSec,
                Size             = UDim2.new(1,0,0,30*sc),
                Name             = "Section"
            }, ScrolLayers)

            local SectionReal = Custom:Create("Frame", {
                AnchorPoint      = Vector2.new(0.5,0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BackgroundTransparency = 0.94,
                BorderSizePixel  = 0,
                LayoutOrder      = 1,
                Position         = UDim2.new(0.5,0,0,0),
                Size             = UDim2.new(1,1*sc,0,30*sc),
                Name             = "SectionReal"
            }, Section)
            Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, SectionReal)

            local SecBtn = Custom:Create("TextButton", {
                Text             = "",
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1,0,1,0),
                Name             = "SectionButton"
            }, SectionReal)

            local ChevFrame = Custom:Create("Frame", {
                AnchorPoint      = Vector2.new(1,0.5),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Position         = UDim2.new(1,-5*sc,0.5,0),
                Size             = UDim2.new(0,20*sc,0,20*sc),
            }, SectionReal)
            local ChevImg = Custom:Create("ImageLabel", {
                Image            = "rbxassetid://125609963478878",
                ImageColor3      = ACCENT_DIM,
                AnchorPoint      = Vector2.new(0.5,0.5),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5,0,0.5,0),
                Rotation         = -90,
                Size             = UDim2.new(1,4*sc,1,4*sc),
            }, ChevFrame)

            local SectionIcon = ResolveLucideIcon(Icon)
            if SectionIcon then
                Custom:Create("ImageLabel", {
                    Image            = SectionIcon,
                    ImageColor3      = ACCENT,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    Position         = UDim2.new(0,7*sc,0.5,-9*sc),
                    Size             = UDim2.new(0,18*sc,0,18*sc),
                }, SectionReal)
            end

            Custom:Create("TextLabel", {
                Font             = Enum.Font.GothamBold,
                Text             = Title,
                TextColor3       = TEXT_HI,
                TextSize         = 12*sc,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextYAlignment   = Enum.TextYAlignment.Top,
                AnchorPoint      = Vector2.new(0,0.5),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0,(SectionIcon and 30 or 10)*sc,0.5,0),
                Size             = UDim2.new(1,(SectionIcon and -70 or -50)*sc,0,13*sc),
                Name             = "SectionTitle"
            }, SectionReal)

            local SecDivide = Custom:Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(180,180,180),
                BorderSizePixel  = 0,
                AnchorPoint      = Vector2.new(0.5,0),
                Position         = UDim2.new(0.5,0,0,33*sc),
                Size             = UDim2.new(0,0,0,1),
                Name             = "SectionDivide"
            }, Section)
            Custom:Create("UICorner", {}, SecDivide)
            Custom:Create("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0,  Color3.fromRGB(20,20,20)),
                    ColorSequenceKeypoint.new(0.5, ACCENT),
                    ColorSequenceKeypoint.new(1,  Color3.fromRGB(20,20,20)),
                }
            }, SecDivide)

            local SectionAdd = Custom:Create("Frame", {
                AnchorPoint      = Vector2.new(0.5,0),
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                LayoutOrder      = 1,
                Position         = UDim2.new(0.5,0,0,38*sc),
                Size             = UDim2.new(1,0,0,0),
                Name             = "SectionAdd"
            }, Section)
            Custom:Create("UIListLayout", {Padding=UDim.new(0,3*sc), SortOrder=Enum.SortOrder.LayoutOrder}, SectionAdd)

            local function UpdateScrollCanvas()
                local h = 0
                for _, c in pairs(ScrolLayers:GetChildren()) do
                    if c.Name ~= "UIListLayout" then h += 3*sc+c.Size.Y.Offset end
                end
                ScrolLayers.CanvasSize = UDim2.new(0,0,0,h)
            end

            local function UpdateSectionSize()
                if OpenSection then
                    local h = 38*sc
                    for _, v in pairs(SectionAdd:GetChildren()) do
                        if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then h += v.Size.Y.Offset+3*sc end
                    end
                    TweenService:Create(ChevFrame, TweenInfo.new(0.1), {Rotation=90}):Play()
                    TweenService:Create(Section,   TweenInfo.new(0.1), {Size=UDim2.new(1,1*sc,0,h)}):Play()
                    TweenService:Create(SectionAdd, TweenInfo.new(0.1), {Size=UDim2.new(1,0,0,h-38*sc)}):Play()
                    TweenService:Create(SecDivide,  TweenInfo.new(0.1), {Size=UDim2.new(1,0,0,1)}):Play()
                    task.wait(0.5); UpdateScrollCanvas()
                end
            end

            local function ToggleSection()
                CircleClick(SecBtn, Player:GetMouse().X, Player:GetMouse().Y)
                if OpenSection then
                    TweenService:Create(ChevFrame, TweenInfo.new(0.1), {Rotation=0}):Play()
                    TweenService:Create(Section,   TweenInfo.new(0.1), {Size=UDim2.new(1,1*sc,0,30*sc)}):Play()
                    TweenService:Create(SecDivide, TweenInfo.new(0.1), {Size=UDim2.new(0,0,0,1)}):Play()
                    OpenSection = false; task.wait(0.12); UpdateScrollCanvas()
                else
                    OpenSection = true; UpdateSectionSize()
                end
            end
            SecBtn.Activated:Connect(ToggleSection)
            SectionAdd.ChildAdded:Connect(UpdateSectionSize)
            SectionAdd.ChildRemoved:Connect(UpdateSectionSize)
            UpdateScrollCanvas()

            -- ── Items ──────────────────────────────────────────
            local Item      = {}
            local ItemCount = 0

            local function MakeItemFrame(height)
                local f = Custom:Create("Frame", {
                    BackgroundColor3     = Color3.fromRGB(255,255,255),
                    BackgroundTransparency = 0.94,
                    BorderSizePixel      = 0,
                    LayoutOrder          = ItemCount,
                    Size                 = UDim2.new(1,0,0,height*sc),
                }, SectionAdd)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, f)
                return f
            end

            function Item:AddParagraph(Config)
                local Title   = Config[1] or Config.Title   or ""
                local Content = Config[2] or Config.Content or ""
                local SF      = {}
                local P       = MakeItemFrame(35)
                P.Name        = "Paragraph"

                local PT = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-16*sc,0,13*sc), Name="PT"
                }, P)
                local PC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,24*sc), Size=UDim2.new(1,-16*sc,0,12*sc), Name="PC"
                }, P)

                local function Resize()
                    PC.TextWrapped = false
                    local lines = math.ceil(PC.TextBounds.X / math.max(PC.AbsoluteSize.X,1))
                    PC.Size = UDim2.new(1,-16*sc,0,12*sc+(12*sc*lines))
                    P.Size  = UDim2.new(1,0,0, PC.AbsoluteSize.Y+33*sc)
                    PC.TextWrapped = true
                    UpdateSectionSize()
                end
                Resize()
                PC:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)

                function SF:Set(C)
                    PT.Text = C[1] or C.Title or ""; PC.Text = C[2] or C.Content or ""
                    Resize()
                end
                ItemCount += 1; return SF
            end

            function Item:AddSeperator(Config)
                local Title = Config[1] or Config.Title or ""
                local SF    = {}
                local S     = MakeItemFrame(30); S.Name = "Seperator"
                S.BackgroundColor3      = Color3.fromRGB(45,45,45)
                S.BackgroundTransparency= 0.1
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,6)}, S)
                local ST = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,12*sc,0,0), Size=UDim2.new(1,-16*sc,1,0),
                }, S)
                function SF:Set(C) ST.Text = C[1] or C.Title or "" end
                ItemCount += 1; return SF
            end

            function Item:AddLine()
                local L = Custom:Create("Frame", {
                    BackgroundColor3     = Color3.fromRGB(70,70,70),
                    BackgroundTransparency = 0.35,
                    BorderSizePixel      = 0,
                    LayoutOrder          = ItemCount,
                    Size                 = UDim2.new(1,0,0,6*sc),
                }, SectionAdd)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,3)}, L)
                ItemCount += 1; return {}
            end

            function Item:AddImage(Config)
                local Url    = Config[1] or Config.Url    or ""
                local Height = Config[2] or Config.Height or 80
                local Title  = Config[3] or Config.Title  or ""
                local SF     = {}

                local F = MakeItemFrame(Height*sc + (Title~="" and 22*sc or 4*sc))
                F.Name = "ImageItem"

                if Title ~= "" then
                    Custom:Create("TextLabel", {
                        Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_LO,
                        TextSize=11*sc, TextXAlignment=Enum.TextXAlignment.Left,
                        BackgroundTransparency=1, BorderSizePixel=0,
                        Position=UDim2.new(0,8*sc,0,4*sc), Size=UDim2.new(1,-16*sc,0,14*sc),
                    }, F)
                end

                local IL = Custom:Create("ImageLabel", {
                    Image            = Url,
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    ScaleType        = Enum.ScaleType.Fit,
                    Position         = UDim2.new(0,8*sc, 0, Title~="" and 20*sc or 4*sc),
                    Size             = UDim2.new(1,-16*sc,0, Height*sc),
                    Name             = "ImageLabel"
                }, F)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, IL)

                function SF:Set(url) IL.Image = url end
                ItemCount += 1; return SF
            end

            function Item:AddButton(Config)
                local Title    = Config[1] or Config.Title    or ""
                local Content  = Config[2] or Config.Content  or ""
                local Icon     = Config[3] or Config.Icon     or "rbxassetid://7734010488"
                local Callback = Config[4] or Config.Callback or function() end
                local SF       = {}

                local B  = MakeItemFrame(35); B.Name = "Button"
                Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-90*sc,0,13*sc), Name="BT"
                }, B)
                local BC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,23*sc), Size=UDim2.new(1,-90*sc,0,12*sc), Name="BC"
                }, B)
                local function UpdB()
                    BC.TextWrapped = false
                    BC.Size = UDim2.new(1,-90*sc,0,12*sc+(12*sc*(BC.TextBounds.X//math.max(BC.AbsoluteSize.X,1))))
                    B.Size  = UDim2.new(1,0,0, BC.AbsoluteSize.Y+33*sc)
                    BC.TextWrapped = true
                end
                UpdB()
                BC:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() UpdB(); UpdateSectionSize() end)

                local BB = Custom:Create("TextButton", {
                    Text="", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0)
                }, B)
                local IFrame = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(1,-12*sc,0.5,0), Size=UDim2.new(0,22*sc,0,22*sc)
                }, B)
                Custom:Create("ImageLabel", {
                    Image=Icon, ImageColor3=ACCENT, AnchorPoint=Vector2.new(0.5,0.5),
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(1,0,1,0)
                }, IFrame)
                BB.Activated:Connect(function()
                    CircleClick(BB, Player:GetMouse().X, Player:GetMouse().Y); Callback()
                end)
                ItemCount += 1; return SF
            end

            function Item:AddToggle(Config)
                local Title    = Config[1] or Config.Title    or ""
                local Content  = Config[2] or Config.Content  or ""
                local Default  = Config[3] or Config.Default  or false
                local Callback = Config[4] or Config.Callback or function() end
                local FT       = {Value = Default}

                -- Tạo key lưu: Tên của toggle
                local saveKey = "Toggle_" .. Title
                Default = NNVN_Hub:LoadValue(saveKey, Default)
                FT.Value = Default

                local T = MakeItemFrame(35); T.Name = "Toggle"
                local TT = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-90*sc,0,13*sc), Name="TT"
                }, T)
                local TC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,23*sc), Size=UDim2.new(1,-90*sc,0,12*sc), Name="TC"
                }, T)
                local function UpdT()
                    TC.TextWrapped = false
                    TC.Size = UDim2.new(1,-90*sc,0,12*sc+(12*sc*math.ceil(TC.TextBounds.X/math.max(TC.AbsoluteSize.X,1))))
                    T.Size  = UDim2.new(1,0,0, TC.AbsoluteSize.Y+33*sc)
                    TC.TextWrapped = true
                end
                UpdT()
                TC:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() UpdT(); UpdateSectionSize() end)

                local TB = Custom:Create("TextButton", {
                    Text="", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0)
                }, T)

                local Track = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=Color3.fromRGB(255,255,255),
                    BackgroundTransparency=0.9, BorderSizePixel=0,
                    Position=UDim2.new(1,-12*sc,0.5,0), Size=UDim2.new(0,30*sc,0,15*sc),
                }, T)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, Track)
                local TrkStroke = Custom:Create("UIStroke", {Color=ACCENT_DIM, Thickness=1.5, Transparency=0.7}, Track)

                local Knob = Custom:Create("Frame", {
                    BackgroundColor3=Color3.fromRGB(200,200,200), BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,0), Size=UDim2.new(0,14*sc,0,14*sc),
                }, Track)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,15)}, Knob)

                local function Animate(on)
                    local ti = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                    TweenService:Create(TT,       ti, {TextColor3 = on and ACCENT or TEXT_HI}):Play()
                    TweenService:Create(Knob,     ti, {Position   = on and UDim2.new(0,15*sc,0,0) or UDim2.new(0,0,0,0),
                                                       BackgroundColor3 = on and ACCENT or Color3.fromRGB(200,200,200)}):Play()
                    TweenService:Create(TrkStroke,ti, {Color=on and ACCENT or ACCENT_DIM, Transparency=on and 0.1 or 0.7}):Play()
                    TweenService:Create(Track,    ti, {BackgroundTransparency = on and 0.65 or 0.9}):Play()
                end

                TB.Activated:Connect(function()
                    CircleClick(TB, Player:GetMouse().X, Player:GetMouse().Y)
                    FT.Value = not FT.Value
                    FT:Set(FT.Value)
                end)
                function FT:Set(v)
                    FT.Value = v
                    Animate(v)
                    Callback(v)
                    NNVN_Hub:SaveValue(saveKey, v)
                end
                FT:Set(FT.Value)
                ItemCount += 1; return FT
            end

            function Item:AddSlider(Config)
                local Title    = Config[1] or Config.Title    or ""
                local Content  = Config[2] or Config.Content  or ""
                local Increment= Config[3] or Config.Increment or 1
                local Min      = Config[4] or Config.Min      or 0
                local Max      = Config[5] or Config.Max      or 100
                local Default  = Config[6] or Config.Default  or 50
                local Callback = Config[7] or Config.Callback or function() end
                local FS       = {Value = Default}

                local saveKey = "Slider_" .. Title
                Default = NNVN_Hub:LoadValue(saveKey, Default)
                FS.Value = Default

                local S = MakeItemFrame(35); S.Name = "Slider"
                Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-180*sc,0,13*sc),
                }, S)
                local SC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,23*sc), Size=UDim2.new(1,-180*sc,0,12*sc),
                }, S)
                local function UpdS()
                    SC.TextWrapped=false
                    SC.Size=UDim2.new(1,-180*sc,0,12*sc+(12*sc*math.floor(SC.TextBounds.X/math.max(SC.AbsoluteSize.X,1))))
                    S.Size=UDim2.new(1,0,0,SC.AbsoluteSize.Y+33*sc); SC.TextWrapped=true
                end
                UpdS(); SC:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() UpdS(); UpdateSectionSize() end)

                local InputFrame = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=ACCENT_DIM,
                    BackgroundTransparency=0.4, BorderSizePixel=0,
                    Position=UDim2.new(1,-155*sc,0.5,0), Size=UDim2.new(0,30*sc,0,19*sc),
                }, S)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,3)}, InputFrame)
                local TB = Custom:Create("TextBox", {
                    Font=Enum.Font.GothamBold, Text=tostring(Default), TextColor3=TEXT_HI,
                    TextSize=12*sc, TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0),
                }, InputFrame)

                local Track = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=Color3.fromRGB(255,255,255),
                    BackgroundTransparency=0.82, BorderSizePixel=0,
                    Position=UDim2.new(1,-18*sc,0.5,0), Size=UDim2.new(0,100*sc,0,3*sc),
                }, S)
                Custom:Create("UICorner", {}, Track)
                local Fill = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=ACCENT,
                    BorderSizePixel=0, Position=UDim2.new(0,0,0.5,0), Size=UDim2.new(0.5,0,0,3*sc),
                }, Track)
                Custom:Create("UICorner", {}, Fill)
                local Knob = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=ACCENT,
                    BorderSizePixel=0, Position=UDim2.new(1,3*sc,0.5,0), Size=UDim2.new(0,8*sc,0,8*sc),
                }, Fill)
                Custom:Create("UICorner", {}, Knob)
                Custom:Create("UIStroke", {Color=ACCENT_DIM}, Knob)

                local Dragging = false
                local function Round(n,f) local r=math.floor(n/f+(math.sign(n)*0.5))*f; if r<0 then r+=f end; return r end
                function FS:Set(v)
                    v=math.clamp(Round(v,Increment),Min,Max); FS.Value=v; TB.Text=tostring(v)
                    TweenService:Create(Fill,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                        {Size=UDim2.fromScale((v-Min)/(Max-Min),1)}):Play()
                    NNVN_Hub:SaveValue(saveKey, v)
                    Callback(v)
                end
                Track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        Dragging=true end
                end)
                Track.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        Dragging=false; Callback(FS.Value) end
                end)
                local _lx=nil
                UserInputService.InputChanged:Connect(function(i)
                    if Dragging then
                        local cx=i.Position.X
                        if cx~=_lx then _lx=cx
                            local sc2=math.clamp((cx-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
                            FS:Set(Min+((Max-Min)*sc2))
                        end
                    end
                end)
                TB:GetPropertyChangedSignal("Text"):Connect(function()
                    local v=TB.Text:gsub("[^%d]","")
                    if v~="" then TB.Text=tostring(math.min(tonumber(v) or 0,Max)) else TB.Text="0" end
                end)
                TB.FocusLost:Connect(function()
                    FS:Set(tonumber(TB.Text) or 0); Callback(FS.Value)
                end)
                FS:Set(Default)
                ItemCount+=1; return FS
            end

            function Item:AddInput(Config)
                local Title    = Config[1] or Config.Title    or ""
                local Content  = Config[2] or Config.Content  or ""
                local Default  = Config[3] or Config.Default  or ""
                local Callback = Config[4] or Config.Callback or function() end
                local FI       = {Value = Default}

                local saveKey = "Input_" .. Title
                Default = NNVN_Hub:LoadValue(saveKey, Default)
                FI.Value = Default

                local F = MakeItemFrame(35); F.Name = "Input"
                Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-180*sc,0,13*sc),
                }, F)
                local FC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,23*sc), Size=UDim2.new(1,-180*sc,0,12*sc),
                }, F)
                local function UpdI()
                    FC.TextWrapped=false
                    FC.Size=UDim2.new(1,-180*sc,0,12*sc+(12*sc*math.floor(FC.TextBounds.X/math.max(FC.AbsoluteSize.X,1))))
                    F.Size=UDim2.new(1,0,0,FC.AbsoluteSize.Y+33*sc); FC.TextWrapped=true
                end
                UpdI(); FC:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() UpdI(); UpdateSectionSize() end)

                local IBox = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=Color3.fromRGB(255,255,255),
                    BackgroundTransparency=0.94, BorderSizePixel=0,
                    ClipsDescendants=true, Position=UDim2.new(1,-7*sc,0.5,0), Size=UDim2.new(0,148*sc,0,28*sc),
                }, F)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, IBox)
                Custom:Create("UIStroke", {Color=ACCENT_DIM, Thickness=0.8, Transparency=0.5}, IBox)
                local ITB = Custom:Create("TextBox", {
                    Font=Enum.Font.GothamBold, PlaceholderColor3=TEXT_LO,
                    PlaceholderText=Custom:T("WriteInput"),
                    Text=Default, TextColor3=TEXT_HI, TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left,
                    AnchorPoint=Vector2.new(0,0.5), BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,6*sc,0.5,0), Size=UDim2.new(1,-10*sc,1,-8*sc),
                }, IBox)
                -- Đăng ký PlaceholderText để cập nhật ngôn ngữ (không đụng vào .Text)
                Custom:RegisterLanguageLabel(ITB, "WriteInput", "PlaceholderText")

                function FI:Set(v) ITB.Text=v; FI.Value=v; Callback(v); NNVN_Hub:SaveValue(saveKey, v) end
                ITB.FocusLost:Connect(function() FI:Set(ITB.Text) end)
                FI:Set(Default)
                ItemCount+=1; return FI
            end

            function Item:AddDropdown(Config)
                local Title    = Config[1] or Config.Title    or ""
                local Content  = Config[2] or Config.Content  or ""
                local Multi    = Config[3] or Config.Multi    or false
                local Options  = Config[4] or Config.Options  or {}
                local Default  = Config[5] or Config.Default  or {}
                local Callback = Config[6] or Config.Callback or function() end
                local FD       = {Value=Default, Options=Options}

                local saveKey = "Dropdown_" .. Title
                local loaded = NNVN_Hub:LoadValue(saveKey, nil)
                if loaded then
                    FD.Value = loaded
                end

                local D = MakeItemFrame(35); D.Name = "Dropdown"
                local DBtn = Custom:Create("TextButton", {
                    Text="", BackgroundTransparency=1, BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0), Name="ToggleButton"
                }, D)
                Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Title, TextColor3=TEXT_HI,
                    TextSize=13*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                    BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,10*sc), Size=UDim2.new(1,-180*sc,0,13*sc),
                }, D)
                local DC = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Content, TextColor3=TEXT_LO,
                    TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom,
                    TextWrapped=true, BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,10*sc,0,23*sc), Size=UDim2.new(1,-180*sc,0,12*sc),
                }, D)
                DC.Size=UDim2.new(1,-180*sc,0,12*sc+(12*sc*(DC.TextBounds.X//math.max(DC.AbsoluteSize.X,1))))
                DC.TextWrapped=true
                D.Size=UDim2.new(1,0,0,DC.AbsoluteSize.Y+33*sc)
                DC:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    DC.TextWrapped=false
                    DC.Size=UDim2.new(1,-180*sc,0,12*sc+(12*sc*(DC.TextBounds.X//math.max(DC.AbsoluteSize.X,1))))
                    D.Size=UDim2.new(1,0,0,DC.AbsoluteSize.Y+33*sc); DC.TextWrapped=true; UpdateSectionSize()
                end)

                local SOF = Custom:Create("Frame", {
                    AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=Color3.fromRGB(255,255,255),
                    BackgroundTransparency=0.94, BorderSizePixel=0,
                    Position=UDim2.new(1,-7*sc,0.5,0), Size=UDim2.new(0,148*sc,0,28*sc),
                    Name="SelectOptionsFrame", LayoutOrder=CountDD,
                }, D)
                Custom:Create("UICorner", {CornerRadius=UDim.new(0,4)}, SOF)
                Custom:Create("UIStroke", {Color=ACCENT_DIM, Thickness=0.8, Transparency=0.5}, SOF)

                DBtn.Activated:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible=true
                        DropPageLayout:JumpToIndex(SOF.LayoutOrder)
                        local ti=TweenInfo.new(0.12)
                        TweenService:Create(MoreBlur,       ti,{BackgroundTransparency=0.68}):Play()
                        TweenService:Create(DropdownSelect, ti,{Position=UDim2.new(1,-11*sc,0.5,0)}):Play()
                    end
                end)

                local SelLabel = Custom:Create("TextLabel", {
                    Font=Enum.Font.GothamBold, Text=Custom:T("SelectOptions"), TextColor3=TEXT_LO,
                    TextSize=11*sc, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
                    AnchorPoint=Vector2.new(0,0.5), BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(0,5*sc,0.5,0), Size=UDim2.new(1,-28*sc,1,-6*sc),
                }, SOF)
                -- Đăng ký để cập nhật ngôn ngữ
                Custom:RegisterLanguageLabel(SelLabel, "SelectOptions")

                Custom:Create("ImageLabel", {
                    Image="rbxassetid://90200523188815", ImageColor3=ACCENT_DIM,
                    AnchorPoint=Vector2.new(1,0.5), BackgroundTransparency=1, BorderSizePixel=0,
                    Position=UDim2.new(1,0,0.5,0), Size=UDim2.new(0,22*sc,0,22*sc),
                }, SOF)

                local ScrollSel = Custom:Create("ScrollingFrame", {
                    CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=0, Active=true,
                    LayoutOrder=CountDD, BackgroundTransparency=1, BorderSizePixel=0,
                    Size=UDim2.new(1,0,1,0), Name="ScrollSelect",
                }, DropdownFolder)
                local ScrollLayout = Custom:Create("UIListLayout", {
                    Padding=UDim.new(0,3*sc),
                    SortOrder=Enum.SortOrder.LayoutOrder,
                }, ScrollSel)

                local function UpdateCanvas()
                    ScrollSel.CanvasSize = UDim2.new(0,0,0,ScrollLayout.AbsoluteContentSize.Y + 4*sc)
                end
                ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

                local SearchBar = Custom:Create("TextBox", {
                    Font=Enum.Font.GothamBold, PlaceholderText=Custom:T("Search"),
                    PlaceholderColor3=TEXT_LO, Text="", TextColor3=TEXT_HI, TextSize=11*sc,
                    BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.88,
                    BorderSizePixel=0, Size=UDim2.new(1,0,0,20*sc), Name="SearchBar"
                }, ScrollSel)
                Custom:RegisterLanguageLabel(SearchBar, "Search", "PlaceholderText")

                SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                    local q=string.lower(SearchBar.Text)
                    for _, v in pairs(ScrollSel:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Option" then
                            local OT=v:FindFirstChild("OptionText")
                            if OT then v.Visible = string.find(string.lower(OT.Text),q)~=nil end
                        end
                    end
                end)

                local DropCnt = 0
                function FD:Clear()
                    for _, f in pairs(ScrollSel:GetChildren()) do
                        if f.Name=="Option" then f:Destroy() end
                    end
                    FD.Value={}; FD.Options={}; SelLabel.Text=Custom:T("SelectOptions")
                end

                function FD:Set(Val)
                    if type(Val) == "table" then
                        FD.Value = Val
                    elseif Val == nil or Val == "" then
                        FD.Value = {}
                    else
                        FD.Value = {Val}
                    end
                    for _, Op in pairs(ScrollSel:GetChildren()) do
                        if Op.Name~="UIListLayout" and Op.Name~="SearchBar" then
                            local found = table.find(FD.Value, Op:FindFirstChild("OptionText") and Op.OptionText.Text or "")
                            local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut)
                            TweenService:Create(Op,ti,{BackgroundTransparency=found and 0.88 or 0.999}):Play()
                            if Op:FindFirstChild("ChooseFrame") then
                                TweenService:Create(Op.ChooseFrame,ti,{Size=found and UDim2.new(0,2*sc,0,12*sc) or UDim2.new(0,0,0,0)}):Play()
                            end
                        end
                    end
                    local joined=table.concat(FD.Value,", ")
                    SelLabel.Text = joined~="" and joined or Custom:T("SelectOptions")
                    Callback(FD.Value)
                    NNVN_Hub:SaveValue(saveKey, FD.Value)
                end

                function FD:AddOption(Name)
                    Name = Name or "Option"
                    local Op = Custom:Create("Frame", {
                        BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.999,
                        BorderSizePixel=0, LayoutOrder=DropCnt, Size=UDim2.new(1,0,0,28*sc), Name="Option"
                    }, ScrollSel)
                    Custom:Create("UICorner", {CornerRadius=UDim.new(0,3)}, Op)
                    local OBtn = Custom:Create("TextButton", {
                        Text="", BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,0,1,0)
                    }, Op)
                    Custom:Create("TextLabel", {
                        Font=Enum.Font.GothamBold, Text=Name, TextColor3=TEXT_HI,
                        TextSize=12*sc, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                        BackgroundTransparency=1, BorderSizePixel=0,
                        Position=UDim2.new(0,8*sc,0,7*sc), Size=UDim2.new(1,-40*sc,0,13*sc), Name="OptionText"
                    }, Op)
                    local CF = Custom:Create("Frame", {
                        AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=ACCENT,
                        BorderSizePixel=0, Position=UDim2.new(0,2*sc,0.5,0), Size=UDim2.new(0,0,0,0), Name="ChooseFrame"
                    }, Op)
                    Custom:Create("UICorner", {}, CF)
                    OBtn.Activated:Connect(function()
                        CircleClick(OBtn, Player:GetMouse().X, Player:GetMouse().Y)
                        local selected = Op.BackgroundTransparency > 0.95
                        if Multi then
                            if selected then
                                if not table.find(FD.Value,Name) then table.insert(FD.Value,Name) end
                            else
                                for i,v in ipairs(FD.Value) do if v==Name then table.remove(FD.Value,i); break end end
                            end
                        else
                            FD.Value = {Name}
                        end
                        FD:Set(FD.Value)
                    end)
                    UpdateCanvas(); DropCnt+=1
                end

                function FD:Refresh(List, Sel)
                    FD:Clear()
                    for _, n in ipairs(List or {}) do FD:AddOption(n) end
                    FD.Options = List or {}
                    FD:Set(Sel or {})
                end
                FD:Refresh(FD.Options, FD.Value)
                ItemCount+=1; CountDD+=1; return FD
            end

            ItemCount+=1; return Item
        end

        CountTab+=1; return Sections
    end

    function Tabs:SetLanguage(lang) Custom:SetLanguage(lang) end
    return Tabs
end

function NNVN_Hub:SetLanguage(lang)
    Custom:SetLanguage(lang)
end

-- ============================================================
-- FuncsV3 helper (giữ nguyên)
-- ============================================================
local FuncsV3  = {}
local SaveConf = nil

local function Ck(v,t,d) return typeof(v)==t and v or d end
function FuncsV3:SetTable(t)     SaveConf = t end

function FuncsV3:Toggle(Tab,Name,Content,Default,CB)
    Name=Ck(Name,"string",tostring(Name)); Content=Ck(Content,"string",tostring(Content)); CB=Ck(CB,"function",function()end)
    local d = Default=="Save" and Ck(SaveConf and SaveConf[Name],"boolean",false) or Ck(Default,"boolean",false)
    return Tab:AddToggle({Title=Name,Content=Content,Default=d,Callback=CB})
end

function FuncsV3:Button(Tab,Name,Content,CB)
    Name=Ck(Name,"string",tostring(Name)); Content=Ck(Content,"string",tostring(Content)); CB=Ck(CB,"function",function()end)
    return Tab:AddButton({Title=Name,Content=Content,Icon="rbxassetid://16932740082",Callback=CB})
end

function FuncsV3:Dropdown(Tab,Name,Content,multi,opts,Default,CB)
    Name=Ck(Name,"string",tostring(Name)); Content=Ck(Content,"string",tostring(Content))
    multi=Ck(multi,"boolean",false); opts=Ck(opts,"table",{""}); CB=Ck(CB,"function",function()end)
    local d
    if Default=="Save" then
        d = (SaveConf and type(SaveConf[Name])=="table") and SaveConf[Name] or {(SaveConf and SaveConf[Name]) or ""}
    else
        local s=(SaveConf and SaveConf[Name]) or Default
        d = type(s)=="table" and s or {s or ""}
    end
    return Tab:AddDropdown({Title=Name,Content=Content,Multi=multi,Options=opts,Default=d,Callback=CB})
end

function FuncsV3:Textbox(Tab,Name,Content,Default,CB)
    Name=Ck(Name,"string",tostring(Name)); Content=Ck(Content,"string",tostring(Content)); CB=Ck(CB,"function",function()end)
    local d = Default=="Save" and Ck(SaveConf and SaveConf[Name],"string","") or Ck(Default,"string","")
    return Tab:AddInput({Title=Name,Content=Content,Default=d,Callback=CB})
end

NNVN_Hub.FuncsV3 = FuncsV3
if getgenv then getgenv().NNVN_Hub = NNVN_Hub end
_G.NNVN_Hub = NNVN_Hub
return NNVN_Hub
