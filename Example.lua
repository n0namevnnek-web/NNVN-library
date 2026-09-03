--[[
    NNVN Lib v1.4 — Example
    ProgressBar · Colorpicker · Tooltip · Tag · Acrylic
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/n0namevnnek-web/NNVN-library/main/NNVNLib.lua"
))()

Library.Default.Language = "en"

local Window = Library:MakeWindow({
    Title = "NNVN Hub",
    SubTitle = "v1.4",
    ScriptFolder = "NNVNHub",
    BackgroundImage = "10709752996",
    BackgroundImageTransparency = 0.8,
    Acrylic = true, -- frosted / blur-like panel
})

Window:NewMinimizer(Enum.KeyCode.RightControl)
Window:CreateOpenButton({
    Size = Library.IsMobile and 50 or 44,
    Position = UDim2.fromScale(0.1, 0.5),
    Corner = UDim.new(0, 14),
    Icon = "10734896206"
})

-- Tags on topbar
Window:AddTag({ Title = "BETA", Color = Color3.fromRGB(99, 102, 241) })
Window:AddTag({ Title = "v1.4" })

local Main = Window:MakeTab({ Title = "Main", Icon = "home" })
Main:AddSection("Combat")

local farmToggle = Main:AddToggle({
    Title = "Auto Farm",
    Description = "Automatically farm enemies",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(v) print("Auto Farm:", v) end
})
farmToggle:SetTooltip("Enable auto farm loop")

Main:AddSlider({
    Title = "Distance",
    Min = 10, Max = 200, Increment = 5, Default = 50,
    Flag = "Dist",
    Callback = function(v) print(v) end
})

-- ProgressBar
local bar = Main:AddProgressBar({
    Title = "Load Progress",
    Description = "Example progress",
    Min = 0, Max = 100, Default = 35
})
task.spawn(function()
    for i = 35, 100 do
        bar:SetValue(i)
        task.wait(0.05)
    end
end)

-- Colorpicker
Main:AddColorpicker({
    Title = "Accent Color",
    Description = "Pick a color (R/G/B)",
    Default = Color3.fromRGB(99, 102, 241),
    Flag = "AccentColor",
    Callback = function(c)
        print("Color:", c)
    end
})

Main:AddButton({
    Title = "Notify",
    Callback = function()
        Window:Notify({ Title = "NNVN", Content = "Hello v1.4!", Duration = 3 })
    end
}):SetTooltip("Show a notification")

local Settings = Window:MakeTab({ Title = "Settings", Icon = "settings" })
Settings:AddSection("Appearance")

Settings:AddDropdown({
    Title = "Theme",
    Options = Library:GetThemes(),
    Default = "Black",
    Flag = "Theme",
    Callback = function(t) Library:SetTheme(t) end
})

Settings:AddToggle({
    Title = "Acrylic",
    Description = "Frosted glass style",
    Default = true,
    Callback = function(v) Window:SetAcrylic(v) end
})

Settings:AddTextBox({
    Title = "Background Image ID",
    Description = "Number only",
    Placeholder = "10709752996",
    Flag = "BgId",
    Callback = function(t) Window:SetBackgroundImage(t) end
})

Settings:AddSlider({
    Title = "UI Scale",
    Min = Library:GetMinScale(), Max = Library:GetMaxScale(),
    Increment = 0.1, Default = 1,
    Callback = function(v) Library:SetUIScale(v) end
})

print("[NNVN] v1.4 loaded")
