--[[
    NNVN Hub
    By N0NAMEVN
    Version: 1.0.0
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ==================== THEMES ====================
local Themes = {
    Default = { -- Gray White (default)
        Name = "Default",
        Accent = Color3.fromRGB(180, 180, 180),
        Background = Color3.fromRGB(22, 22, 24),
        Background2 = Color3.fromRGB(28, 28, 30),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(160, 160, 160),
        Stroke = Color3.fromRGB(55, 55, 58),
        Toggle = Color3.fromRGB(200, 200, 200),
        Scroll = Color3.fromRGB(100, 100, 105),
    },
    Dark = {
        Name = "Dark",
        Accent = Color3.fromRGB(88, 101, 242),
        Background = Color3.fromRGB(18, 18, 20),
        Background2 = Color3.fromRGB(25, 25, 28),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(170, 170, 175),
        Stroke = Color3.fromRGB(45, 45, 50),
        Toggle = Color3.fromRGB(88, 101, 242),
        Scroll = Color3.fromRGB(88, 101, 242),
    },
    Red = {
        Name = "Red",
        Accent = Color3.fromRGB(230, 50, 50),
        Background = Color3.fromRGB(20, 18, 18),
        Background2 = Color3.fromRGB(30, 22, 22),
        Text = Color3.fromRGB(255, 240, 240),
        TextDark = Color3.fromRGB(180, 150, 150),
        Stroke = Color3.fromRGB(60, 40, 40),
        Toggle = Color3.fromRGB(230, 50, 50),
        Scroll = Color3.fromRGB(200, 60, 60),
    },
    Green = {
        Name = "Green",
        Accent = Color3.fromRGB(50, 200, 100),
        Background = Color3.fromRGB(16, 20, 18),
        Background2 = Color3.fromRGB(22, 30, 25),
        Text = Color3.fromRGB(240, 255, 245),
        TextDark = Color3.fromRGB(150, 180, 160),
        Stroke = Color3.fromRGB(40, 60, 45),
        Toggle = Color3.fromRGB(50, 200, 100),
        Scroll = Color3.fromRGB(50, 180, 90),
    },
    Purple = {
        Name = "Purple",
        Accent = Color3.fromRGB(160, 90, 255),
        Background = Color3.fromRGB(20, 18, 28),
        Background2 = Color3.fromRGB(28, 24, 40),
        Text = Color3.fromRGB(245, 240, 255),
        TextDark = Color3.fromRGB(170, 160, 190),
        Stroke = Color3.fromRGB(50, 45, 70),
        Toggle = Color3.fromRGB(160, 90, 255),
        Scroll = Color3.fromRGB(140, 80, 220),
    },
    Cyan = {
        Name = "Cyan",
        Accent = Color3.fromRGB(0, 200, 220),
        Background = Color3.fromRGB(15, 20, 22),
        Background2 = Color3.fromRGB(20, 28, 32),
        Text = Color3.fromRGB(240, 250, 255),
        TextDark = Color3.fromRGB(150, 180, 190),
        Stroke = Color3.fromRGB(40, 55, 60),
        Toggle = Color3.fromRGB(0, 200, 220),
        Scroll = Color3.fromRGB(0, 180, 200),
    },
    Orange = {
        Name = "Orange",
        Accent = Color3.fromRGB(255, 140, 40),
        Background = Color3.fromRGB(22, 18, 15),
        Background2 = Color3.fromRGB(32, 25, 20),
        Text = Color3.fromRGB(255, 245, 235),
        TextDark = Color3.fromRGB(190, 160, 130),
        Stroke = Color3.fromRGB(60, 45, 35),
        Toggle = Color3.fromRGB(255, 140, 40),
        Scroll = Color3.fromRGB(230, 120, 30),
    },
}

local CurrentTheme = Themes.Default

-- ==================== LANGUAGE ====================
local Languages = {
    en = {
        Close = "Close",
        Minimize = "Minimize",
        Fullscreen = "Fullscreen",
        Search = "Search...",
        SelectOptions = "Select Options",
        Yes = "Yes",
        No = "No",
        Loaded = "NNVN Hub loaded successfully!",
        Theme = "Theme",
        Language = "Language",
    },
    vi = {
        Close = "Đóng",
        Minimize = "Thu nhỏ",
        Fullscreen = "Toàn màn hình",
        Search = "Tìm kiếm...",
        SelectOptions = "Chọn tùy chọn",
        Yes = "Có",
        No = "Không",
        Loaded = "NNVN Hub đã sẵn sàng!",
        Theme = "Chủ đề",
        Language = "Ngôn ngữ",
    },
}

local CurrentLang = "en"
local function L(key)
    return (Languages[CurrentLang] and Languages[CurrentLang][key]) or Languages.en[key] or key
end

-- ==================== UTILS ====================
local Custom = {}
Custom.ColorRGB = CurrentTheme.Accent

function Custom:Create(Name, Properties, Parent)
    local inst = Instance.new(Name)
    for i, v in pairs(Properties or {}) do
        inst[i] = v
    end
    if Parent then
        inst.Parent = Parent
    end
    return inst
end

function Custom:EnabledAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

Custom:EnabledAFK()

local function MakeDraggable(topbar, object)
    local dragging, dragStart, startPos = false, nil, nil
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://106471194043211"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Parent = Button
        local NewX = X - Button.AbsolutePosition.X
        local NewY = Y - Button.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
        local Tween = TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, Size, 0, Size),
            Position = UDim2.new(0.5, -Size / 2, 0.5, -Size / 2)
        })
        Tween:Play()
        Tween.Completed:Connect(function()
            for i = 1, 10 do
                Circle.ImageTransparency = Circle.ImageTransparency + 0.01
                task.wait(0.05)
            end
            Circle:Destroy()
        end)
    end)
end

-- ==================== LIBRARY ====================
local NNVN = {}
NNVN.Unloaded = false
NNVN.Version = "1.0.0"
NNVN.Author = "N0NAMEVN"

-- Open / Close floating button
local function CreateOpenClose()
    local ScreenGui = Custom:Create("ScreenGui", {
        Name = "NNVN_OpenClose",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    }, RunService:IsStudio() and Player.PlayerGui or (gethui and gethui() or game:GetService("CoreGui")))

    local Btn = Custom:Create("ImageButton", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 28),
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0.08, 0, 0.12, 0),
        Size = UDim2.new(0, 48, 0, 48),
        Image = "rbxassetid://136890595976124",
        Visible = false,
        Name = "OpenBtn",
    }, ScreenGui)

    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, Btn)
    Custom:Create("UIStroke", { Color = CurrentTheme.Accent, Thickness = 1.2 }, Btn)

    local dragging, dragStart, startPos = false, nil, nil
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return Btn
end

local OpenCloseBtn = CreateOpenClose()

-- ==================== NOTIFICATION ====================
function NNVN:Notify(Config)
    Config = Config or {}
    local Title = Config.Title or Config[1] or "NNVN Hub"
    local Content = Config.Content or Config.Description or Config[2] or ""
    local Duration = Config.Duration or Config.Time or 4

    local Gui = Custom:Create("ScreenGui", {
        Name = "NNVN_Notify",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    }, RunService:IsStudio() and Player.PlayerGui or (gethui and gethui() or game:GetService("CoreGui")))

    local Frame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = CurrentTheme.Background,
        Position = UDim2.new(1, 20, 0, 20),
        Size = UDim2.new(0, 280, 0, 70),
        Name = "Notify",
    }, Gui)

    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Frame)
    Custom:Create("UIStroke", { Color = CurrentTheme.Stroke, Thickness = 1 }, Frame)

    local AccentBar = Custom:Create("Frame", {
        BackgroundColor3 = CurrentTheme.Accent,
        Size = UDim2.new(0, 4, 1, 0),
        Name = "Accent",
    }, Frame)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, AccentBar)

    local TitleLbl = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -24, 0, 18),
    }, Frame)

    local ContentLbl = Custom:Create("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = Content,
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 32),
        Size = UDim2.new(1, -24, 0, 30),
    }, Frame)

    TweenService:Create(Frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -20, 0, 20)
    }):Play()

    task.delay(Duration, function()
        local t = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 20, 0, 20)
        })
        t:Play()
        t.Completed:Connect(function()
            Gui:Destroy()
        end)
    end)
end

-- ==================== CREATE WINDOW ====================
function NNVN:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "NNVN Hub"
    local SubTitle = Config.SubTitle or Config.Description or "By N0NAMEVN"
    local TabWidth = Config.TabWidth or (isMobile and 100 or 130)

    -- Responsive size
    local SizeUi
    if isMobile then
        SizeUi = Config.Size or UDim2.fromOffset(360, 280)
    else
        SizeUi = Config.Size or UDim2.fromOffset(580, 380)
    end

    local Window = {}
    local isFullscreen = false
    local savedSize, savedPos

    local ScreenGui = Custom:Create("ScreenGui", {
        Name = "NNVNHub",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    }, RunService:IsStudio() and Player.PlayerGui or (gethui and gethui() or game:GetService("CoreGui")))

    -- Main Shadow / Holder
    local Holder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        Size = SizeUi,
        Position = UDim2.new(0.5, -SizeUi.X.Offset / 2, 0.5, -SizeUi.Y.Offset / 2),
        Name = "Holder",
    }, ScreenGui)

    local Main = Custom:Create("Frame", {
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0.05,
        Size = UDim2.fromScale(1, 1),
        Name = "Main",
    }, Holder)

    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, Main)
    Custom:Create("UIStroke", { Color = CurrentTheme.Stroke, Thickness = 1.4 }, Main)

    -- ========== TOP BAR ==========
    local TopBar = Custom:Create("Frame", {
        BackgroundColor3 = CurrentTheme.Background2,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 36),
        Name = "TopBar",
    }, Main)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, TopBar)

    -- Title
    local TitleLabel = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 160, 1, 0),
    }, TopBar)

    -- SubTitle / Tag (rectangular like WindUI)
    local Tag = Custom:Create("Frame", {
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.85,
        Position = UDim2.new(0, TitleLabel.TextBounds.X + 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        Name = "Tag",
    }, TopBar)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Tag)
    Custom:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, Tag)

    local TagLabel = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = SubTitle,
        TextColor3 = CurrentTheme.Accent,
        TextSize = 11,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
    }, Tag)

    -- Buttons on top right
    local BtnHolder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 100, 0, 26),
    }, TopBar)

    local function MakeTopBtn(text, order)
        local b = Custom:Create("TextButton", {
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = CurrentTheme.Text,
            TextSize = 14,
            BackgroundColor3 = CurrentTheme.Background2,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, (order - 1) * 30, 0, 0),
            AutoButtonColor = false,
        }, BtnHolder)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
        return b
    end

    local FullscreenBtn = MakeTopBtn("⛶", 1)
    local MinBtn = MakeTopBtn("−", 2)
    local CloseBtn = MakeTopBtn("×", 3)

    -- Fullscreen
    FullscreenBtn.MouseButton1Click:Connect(function()
        if not isFullscreen then
            savedSize = Holder.Size
            savedPos = Holder.Position
            Holder.Size = UDim2.new(1, -20, 1, -20)
            Holder.Position = UDim2.new(0, 10, 0, 10)
            isFullscreen = true
            FullscreenBtn.Text = "⛶"
        else
            Holder.Size = savedSize
            Holder.Position = savedPos
            isFullscreen = false
            FullscreenBtn.Text = "⛶"
        end
    end)

    -- Minimize
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Main.Visible = not minimized
        OpenCloseBtn.Visible = minimized
    end)

    OpenCloseBtn.MouseButton1Click:Connect(function()
        minimized = false
        Main.Visible = true
        OpenCloseBtn.Visible = false
    end)

    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        OpenCloseBtn.Parent:Destroy()
        if Window.Anonymous then
            Window.Anonymous:Destroy()
        end
        NNVN.Unloaded = true
    end)

    MakeDraggable(TopBar, Holder)

    -- ========== TABS SIDE ==========
    local TabFrame = Custom:Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 44),
        Size = UDim2.new(0, TabWidth, 1, -52),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Scroll,
        Name = "Tabs",
    }, Main)

    Custom:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, TabFrame)

    -- ========== CONTENT ==========
    local ContentFrame = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, TabWidth + 16, 0, 44),
        Size = UDim2.new(1, -(TabWidth + 24), 1, -52),
        Name = "Content",
    }, Main)

    -- ========== ANONYMOUS TAG (corner like WindUI) ==========
    local AnonGui = Custom:Create("ScreenGui", {
        Name = "NNVN_Anonymous",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, RunService:IsStudio() and Player.PlayerGui or (gethui and gethui() or game:GetService("CoreGui")))

    local AnonFrame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, -12),
        Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0.25,
        Name = "Anonymous",
    }, AnonGui)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, AnonFrame)
    Custom:Create("UIStroke", { Color = CurrentTheme.Stroke, Thickness = 1 }, AnonFrame)
    Custom:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, AnonFrame)

    local AnonLabel = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = "NNVN Hub  •  By N0NAMEVN",
        TextColor3 = CurrentTheme.TextDark,
        TextSize = 11,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
    }, AnonFrame)

    Window.Anonymous = AnonGui

    -- ========== TAB SYSTEM ==========
    local Tabs = {}
    local CurrentTab = nil
    local TabCount = 0

    function Window:CreateTab(Config)
        Config = type(Config) == "string" and { Title = Config } or (Config or {})
        local TabTitle = Config.Title or Config.Name or "Tab"
        local TabIcon = Config.Icon or ""

        TabCount += 1
        local order = TabCount

        local TabBtn = Custom:Create("TextButton", {
            Font = Enum.Font.GothamBold,
            Text = "  " .. TabTitle,
            TextColor3 = CurrentTheme.TextDark,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CurrentTheme.Background2,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, 32),
            LayoutOrder = order,
            AutoButtonColor = false,
            Name = TabTitle,
        }, TabFrame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, TabBtn)

        local Indicator = Custom:Create("Frame", {
            BackgroundColor3 = CurrentTheme.Accent,
            Size = UDim2.new(0, 3, 0, 16),
            Position = UDim2.new(0, 4, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Name = "Indicator",
        }, TabBtn)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Indicator)

        -- Page
        local Page = Custom:Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Scroll,
            Visible = false,
            Name = TabTitle .. "_Page",
        }, ContentFrame)

        local PageLayout = Custom:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, Page)

        Custom:Create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 8),
        }, Page)

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 16)
        end)

        local function Select()
            if CurrentTab then
                CurrentTab.Btn.BackgroundTransparency = 1
                CurrentTab.Btn.TextColor3 = CurrentTheme.TextDark
                CurrentTab.Indicator.BackgroundTransparency = 1
                CurrentTab.Page.Visible = false
            end
            CurrentTab = { Btn = TabBtn, Page = Page, Indicator = Indicator }
            TabBtn.BackgroundTransparency = 0.6
            TabBtn.TextColor3 = CurrentTheme.Text
            Indicator.BackgroundTransparency = 0
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(Select)

        if TabCount == 1 then
            Select()
        end

        -- Update tab canvas
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabCount * 36)

        -- ========== SECTION ==========
        local Sections = {}
        local SectionCount = 0

        function Sections:CreateSection(Name)
            SectionCount += 1
            local SecOrder = SectionCount

            local Section = Custom:Create("Frame", {
                BackgroundColor3 = CurrentTheme.Background2,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, 36),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = SecOrder,
                Name = "Section",
            }, Page)
            Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Section)

            local SecLayout = Custom:Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Section)

            Custom:Create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }, Section)

            -- Header (collapsible)
            local Header = Custom:Create("TextButton", {
                Font = Enum.Font.GothamBold,
                Text = "  " .. (Name or "Section"),
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = 0,
                AutoButtonColor = false,
            }, Section)

            local Chevron = Custom:Create("TextLabel", {
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = CurrentTheme.TextDark,
                TextSize = 10,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -4, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
            }, Header)

            local ContentHolder = Custom:Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1,
                Name = "Content",
            }, Section)

            local ContentLayout = Custom:Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, ContentHolder)

            local open = true
            Header.MouseButton1Click:Connect(function()
                open = not open
                ContentHolder.Visible = open
                Chevron.Text = open and "▼" or "▶"
            end)

            local ItemCount = 0
            local Item = {}

            local function AddItemBase(height)
                ItemCount += 1
                local f = Custom:Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Background,
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(1, 0, 0, height or 36),
                    LayoutOrder = ItemCount,
                }, ContentHolder)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, f)
                return f
            end

            -- Toggle
            function Item:AddToggle(cfg)
                cfg = cfg or {}
                local title = cfg.Title or cfg.Name or "Toggle"
                local desc = cfg.Description or cfg.Content or ""
                local default = cfg.Default or false
                local callback = cfg.Callback or function() end

                local frame = AddItemBase(desc ~= "" and 48 or 36)
                local state = default

                local lbl = Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, desc ~= "" and 6 or 0),
                    Size = UDim2.new(1, -60, 0, 18),
                }, frame)

                if desc ~= "" then
                    Custom:Create("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = desc,
                        TextColor3 = CurrentTheme.TextDark,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 26),
                        Size = UDim2.new(1, -60, 0, 16),
                    }, frame)
                end

                local toggleBg = Custom:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 38, 0, 20),
                    BackgroundColor3 = state and CurrentTheme.Toggle or CurrentTheme.Stroke,
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, toggleBg)

                local circle = Custom:Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                }, toggleBg)
                Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, circle)

                local function Set(v)
                    state = v
                    TweenService:Create(toggleBg, TweenInfo.new(0.2), {
                        BackgroundColor3 = state and CurrentTheme.Toggle or CurrentTheme.Stroke
                    }):Play()
                    TweenService:Create(circle, TweenInfo.new(0.2), {
                        Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                    }):Play()
                    callback(state)
                end

                local btn = Custom:Create("TextButton", {
                    Text = "",
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                }, frame)
                btn.MouseButton1Click:Connect(function()
                    Set(not state)
                end)

                return { Set = Set, Value = function() return state end }
            end

            -- Button
            function Item:AddButton(cfg)
                cfg = cfg or {}
                local title = cfg.Title or cfg.Name or "Button"
                local callback = cfg.Callback or function() end

                local frame = AddItemBase(34)
                local btn = Custom:Create("TextButton", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    BackgroundColor3 = CurrentTheme.Background2,
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, -16, 1, -8),
                    Position = UDim2.new(0, 8, 0, 4),
                    AutoButtonColor = false,
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)

                btn.MouseButton1Click:Connect(function()
                    CircleClick(btn, Player:GetMouse().X, Player:GetMouse().Y)
                    callback()
                end)
            end

            -- Slider
            function Item:AddSlider(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Slider"
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local default = cfg.Default or min
                local callback = cfg.Callback or function() end

                local frame = AddItemBase(50)
                Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 4),
                    Size = UDim2.new(1, -60, 0, 16),
                }, frame)

                local valueLbl = Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = tostring(default),
                    TextColor3 = CurrentTheme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 4),
                    Size = UDim2.new(0, 40, 0, 16),
                }, frame)

                local barBg = Custom:Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Stroke,
                    Position = UDim2.new(0, 10, 0, 28),
                    Size = UDim2.new(1, -20, 0, 6),
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, barBg)

                local barFill = Custom:Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Accent,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                }, barBg)
                Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)

                local sliding = false
                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                        local val = math.floor(min + (max - min) * rel + 0.5)
                        barFill.Size = UDim2.new(rel, 0, 1, 0)
                        valueLbl.Text = tostring(val)
                        callback(val)
                    end
                end)
            end

            -- TextBox
            function Item:AddTextBox(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Input"
                local default = cfg.Default or ""
                local placeholder = cfg.Placeholder or "..."
                local callback = cfg.Callback or function() end

                local frame = AddItemBase(36)
                Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                }, frame)

                local boxBg = Custom:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0.5, 0, 0, 24),
                    BackgroundColor3 = CurrentTheme.Stroke,
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, boxBg)

                local box = Custom:Create("TextBox", {
                    Font = Enum.Font.Gotham,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = CurrentTheme.TextDark,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    ClearTextOnFocus = false,
                }, boxBg)

                box.FocusLost:Connect(function()
                    callback(box.Text)
                end)
            end

            -- Dropdown (with Search)
            function Item:AddDropdown(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Dropdown"
                local options = cfg.Options or {}
                local default = cfg.Default or (options[1] or "")
                local multi = cfg.Multi or false
                local callback = cfg.Callback or function() end

                local frame = AddItemBase(36)
                Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                }, frame)

                local dropBtn = Custom:Create("TextButton", {
                    Font = Enum.Font.Gotham,
                    Text = type(default) == "table" and table.concat(default, ", ") or tostring(default),
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0.5, 0, 0, 24),
                    BackgroundColor3 = CurrentTheme.Stroke,
                    AutoButtonColor = false,
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, dropBtn)
                Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 6) }, dropBtn)

                -- Dropdown popup
                local popup = Custom:Create("Frame", {
                    BackgroundColor3 = CurrentTheme.Background,
                    Size = UDim2.new(0, 180, 0, 0),
                    Visible = false,
                    ZIndex = 50,
                    Name = "DropPopup",
                }, ScreenGui)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, popup)
                Custom:Create("UIStroke", { Color = CurrentTheme.Stroke, Thickness = 1 }, popup)

                local search = Custom:Create("TextBox", {
                    Font = Enum.Font.Gotham,
                    PlaceholderText = L("Search"),
                    PlaceholderColor3 = CurrentTheme.TextDark,
                    Text = "",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    BackgroundColor3 = CurrentTheme.Background2,
                    Size = UDim2.new(1, -12, 0, 26),
                    Position = UDim2.new(0, 6, 0, 6),
                    ClearTextOnFocus = false,
                    ZIndex = 51,
                }, popup)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, search)

                local list = Custom:Create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 36),
                    Size = UDim2.new(1, -8, 1, -42),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ZIndex = 51,
                }, popup)

                local listLayout = Custom:Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                }, list)

                local selected = multi and (type(default) == "table" and default or { default }) or default

                local function RefreshList(filter)
                    for _, c in pairs(list:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    local count = 0
                    for _, opt in ipairs(options) do
                        if filter == "" or string.find(string.lower(opt), string.lower(filter)) then
                            count += 1
                            local optBtn = Custom:Create("TextButton", {
                                Font = Enum.Font.Gotham,
                                Text = "  " .. opt,
                                TextColor3 = CurrentTheme.Text,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                BackgroundColor3 = CurrentTheme.Background2,
                                BackgroundTransparency = 0.5,
                                Size = UDim2.new(1, 0, 0, 26),
                                ZIndex = 52,
                                AutoButtonColor = false,
                            }, list)
                            Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, optBtn)

                            optBtn.MouseButton1Click:Connect(function()
                                if multi then
                                    local idx = table.find(selected, opt)
                                    if idx then
                                        table.remove(selected, idx)
                                    else
                                        table.insert(selected, opt)
                                    end
                                    dropBtn.Text = #selected > 0 and table.concat(selected, ", ") or L("SelectOptions")
                                    callback(selected)
                                else
                                    selected = opt
                                    dropBtn.Text = opt
                                    popup.Visible = false
                                    callback(opt)
                                end
                            end)
                        end
                    end
                    list.CanvasSize = UDim2.new(0, 0, 0, count * 28)
                    popup.Size = UDim2.new(0, 180, 0, math.min(36 + count * 28 + 8, 200))
                end

                search:GetPropertyChangedSignal("Text"):Connect(function()
                    RefreshList(search.Text)
                end)

                dropBtn.MouseButton1Click:Connect(function()
                    if popup.Visible then
                        popup.Visible = false
                    else
                        local abs = dropBtn.AbsolutePosition
                        local absSize = dropBtn.AbsoluteSize
                        popup.Position = UDim2.new(0, abs.X - 20, 0, abs.Y + absSize.Y + 4)
                        search.Text = ""
                        RefreshList("")
                        popup.Visible = true
                    end
                end)

                -- close when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if popup.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local p = input.Position
                        local abs = popup.AbsolutePosition
                        local size = popup.AbsoluteSize
                        if p.X < abs.X or p.X > abs.X + size.X or p.Y < abs.Y or p.Y > abs.Y + size.Y then
                            if not (p.X >= dropBtn.AbsolutePosition.X and p.X <= dropBtn.AbsolutePosition.X + dropBtn.AbsoluteSize.X
                                and p.Y >= dropBtn.AbsolutePosition.Y and p.Y <= dropBtn.AbsolutePosition.Y + dropBtn.AbsoluteSize.Y) then
                                popup.Visible = false
                            end
                        end
                    end
                end)
            end

            -- Paragraph
            function Item:AddParagraph(title, content)
                local frame = AddItemBase(0)
                frame.AutomaticSize = Enum.AutomaticSize.Y
                Custom:Create("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                }, frame)

                Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title or "",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                }, frame)

                if content and content ~= "" then
                    Custom:Create("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = content,
                        TextColor3 = CurrentTheme.TextDark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 20),
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, frame)
                end
            end

            -- Discord Invite (API)
            function Item:AddDiscordInvite(cfg)
                cfg = cfg or {}
                local invite = cfg.Invite or cfg.Code or ""
                local title = cfg.Title or "Discord"
                local desc = cfg.Description or ""

                local frame = AddItemBase(80)

                local nameLbl = Custom:Create("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -24, 0, 18),
                }, frame)

                local infoLbl = Custom:Create("TextLabel", {
                    Font = Enum.Font.Gotham,
                    Text = desc ~= "" and desc or "Loading...",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 28),
                    Size = UDim2.new(1, -24, 0, 16),
                }, frame)

                local joinBtn = Custom:Create("TextButton", {
                    Font = Enum.Font.GothamBold,
                    Text = "Join Server",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                    Size = UDim2.new(1, -24, 0, 24),
                    Position = UDim2.new(0, 12, 1, -32),
                    AutoButtonColor = false,
                }, frame)
                Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, joinBtn)

                joinBtn.MouseButton1Click:Connect(function()
                    local code = invite:match("discord%.gg/(.+)") or invite:match("discord%.com/invite/(.+)") or invite
                    if setclipboard then
                        setclipboard("https://discord.gg/" .. code)
                    end
                    NNVN:Notify({ Title = "Discord", Content = "Link copied to clipboard!", Duration = 3 })
                end)

                -- Fetch Discord API
                task.spawn(function()
                    local code = invite:match("discord%.gg/(.+)") or invite:match("discord%.com/invite/(.+)") or invite
                    local ok, data = pcall(function()
                        return HttpService:JSONDecode(game:HttpGet("https://discord.com/api/v9/invites/" .. code .. "?with_counts=true"))
                    end)
                    if ok and data then
                        local name = data.guild and data.guild.name or title
                        local online = data.approximate_presence_count or 0
                        local members = data.approximate_member_count or 0
                        nameLbl.Text = name
                        infoLbl.Text = online .. " Online  •  " .. members .. " Members"
                    else
                        infoLbl.Text = desc ~= "" and desc or "discord.gg/" .. code
                    end
                end)
            end

            return Item
        end

        return Sections
    end

    -- Theme changer helper
    function Window:SetTheme(name)
        if Themes[name] then
            CurrentTheme = Themes[name]
            Custom.ColorRGB = CurrentTheme.Accent
            -- Note: full live theme switch would require rebuilding UI
            NNVN:Notify({ Title = "Theme", Content = "Theme set to " .. name .. " (reopen UI to fully apply)", Duration = 3 })
        end
    end

    function Window:SetLanguage(lang)
        if Languages[lang] then
            CurrentLang = lang
            NNVN:Notify({ Title = "Language", Content = "Language set to " .. lang, Duration = 2 })
        end
    end

    function Window:Destroy()
        ScreenGui:Destroy()
        if OpenCloseBtn and OpenCloseBtn.Parent then
            OpenCloseBtn.Parent:Destroy()
        end
        if Window.Anonymous then
            Window.Anonymous:Destroy()
        end
        NNVN.Unloaded = true
    end

    -- Notify loaded
    task.defer(function()
        NNVN:Notify({
            Title = "NNVN Hub",
            Content = L("Loaded"),
            Duration = 4,
        })
    end)

    return Window
end

-- Compatibility aliases
NNVN.MakeWindow = NNVN.CreateWindow
NNVN.New = NNVN.CreateWindow

return NNVN
