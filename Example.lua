--[[
    NNVN Lib v1.4.3 — Example
    Redz-style Darker · WindUI Tags · User panel (Anonymous) bottom-left
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/n0namevnnek-web/NNVN-library/main/NNVNLib.lua"
))()

Library.Default.Language = "en"

local Window = Library:MakeWindow({
    Title = "NNVN Hub",
    SubTitle = "v1.4.3",
    ScriptFolder = "NNVNHub",
    BackgroundImage = "10709752996",
    BackgroundImageTransparency = 0.72,
    Acrylic = false,
    -- WindUI-style user panel (bottom-left of sidebar)
    User = {
        Enabled = true,
        Anonymous = true, -- true = hide real name/avatar
        Callback = function()
            Window:Notify({
                Title = "User",
                Content = "Clicked profile (Anonymous = " .. tostring(Window.User.Anonymous) .. ")",
                Duration = 2.5
            })
        end
    }
})

Window:NewMinimizer(Enum.KeyCode.RightControl)
Window:CreateOpenButton({
    Size = Library.IsMobile and 50 or 44,
    Position = UDim2.fromScale(0.1, 0.5),
    Corner = UDim.new(0, 14),
    Icon = "10734896206"
})

-- WindUI-style tags (top center)
Window:AddTag({ Title = "BETA" })
Window:AddTag({ Title = "v1.4.3", Color = Color3.fromRGB(88, 101, 242) })

local Main = Window:MakeTab({ Title = "Main", Icon = "home" })
Main:AddSection("Combat")

Main:AddToggle({
    Title = "Auto Farm",
    Description = "Automatically farm enemies",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(v) print(v) end
}):SetTooltip("Enable auto farm")

Main:AddSlider({
    Title = "Distance",
    Min = 10, Max = 200, Increment = 5, Default = 50,
    Flag = "Dist",
    Callback = function(v) print(v) end
})

local bar = Main:AddProgressBar({
    Title = "Progress",
    Min = 0, Max = 100, Default = 40
})

Main:AddColorpicker({
    Title = "Accent",
    Default = Color3.fromRGB(88, 101, 242),
    Flag = "Accent",
    Callback = function(c) print(c) end
})

Main:AddButton({
    Title = "Notify",
    Callback = function()
        Window:Notify({ Title = "NNVN", Content = "Redz-style Darker UI", Duration = 3 })
    end
})

Main:AddButton({
    Title = "Toggle Anonymous",
    Description = "Show / hide real player name",
    Callback = function()
        Window.User:ToggleAnonymous()
        Window:Notify({
            Title = "Anonymous",
            Content = tostring(Window.User.Anonymous),
            Duration = 2
        })
    end
})

local Settings = Window:MakeTab({ Title = "Settings", Icon = "settings" })
Settings:AddSection("Appearance")

Settings:AddDropdown({
    Title = "Theme",
    Options = Library:GetThemes(),
    Default = "Darker",
    Flag = "Theme",
    Callback = function(t) Library:SetTheme(t) end
})

Settings:AddToggle({
    Title = "Acrylic",
    Description = "Frosted overlay (bg image stays)",
    Default = false,
    Callback = function(v) Window:SetAcrylic(v) end
})

Settings:AddToggle({
    Title = "Show User Panel",
    Description = "Bottom-left player info",
    Default = true,
    Callback = function(v)
        if v then Window.User:Enable() else Window.User:Disable() end
    end
})

Settings:AddToggle({
    Title = "Anonymous",
    Description = "Hide real name & avatar",
    Default = true,
    Callback = function(v) Window.User:SetAnonymous(v) end
})

Settings:AddTextBox({
    Title = "Background Image ID",
    Description = "Number only — works with or without Acrylic",
    Placeholder = "10709752996",
    Flag = "BgId",
    Callback = function(t) Window:SetBackgroundImage(t) end
})

Settings:AddSlider({
    Title = "Bg Transparency",
    Min = 0, Max = 1, Increment = 0.05, Default = 0.72,
    Callback = function(v) Window:SetBackgroundImageTransparency(v) end
})

Settings:AddSlider({
    Title = "UI Scale",
    Min = Library:GetMinScale(), Max = Library:GetMaxScale(),
    Increment = 0.1, Default = 1,
    Callback = function(v) Library:SetUIScale(v) end
})

print("[NNVN] v1.4.3 loaded | Theme:", Library:GetCurrentTheme().Name)
