--[[
    NNVN Lib v1.3 — Example
    Vietnamese · Color themes · Open button · Config
]]

local Library = loadstring(readfile("NNVNLib.lua"))()

Library.Default.Language = "en"

local Window = Library:MakeWindow({
    Title = "NNVN Hub",
    SubTitle = "v1.3",
    ScriptFolder = "NNVNHub",
    BackgroundImage = "10709752996",
    BackgroundImageTransparency = 0.75
})

-- Phim tat + nut mo menu bo goc muot
Window:NewMinimizer(Enum.KeyCode.RightControl)
local OpenBtn = Window:CreateOpenButton({
    Size = Library.IsMobile and 50 or 44,
    Position = UDim2.fromScale(0.1, 0.5),
    Corner = UDim.new(0, 14),
    Icon = "10734896206"
})

local Main = Window:MakeTab({ Title = Library:T("Main"), Icon = "home" })
Main:AddSection(Library:T("Combat"))
Main:AddToggle({
    Title = "Auto Farm",
    Description = "Tu dong farm quai",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(v) print(v) end
})
Main:AddSlider({
    Title = "Distance",
    Min = 10, Max = 200, Increment = 5, Default = 50,
    Flag = "Dist",
    Callback = function(v) print(v) end
})
Main:AddButton({
    Title = "Teleport",
    Callback = function() print("tp") end
})

local Settings = Window:MakeTab({ Title = Library:T("Settings"), Icon = "settings" })
Settings:AddSection(Library:T("Appearance"))

Settings:AddDropdown({
    Title = Library:T("Theme"),
    Description = "Amber, Rose, Emerald, Rainbow, ...",
    Options = Library:GetThemes(),
    Default = "Black",
    Flag = "Theme",
    Callback = function(t) Library:SetTheme(t) end
})

do
    local names, map = {}, {}
    for _, info in ipairs(Library:GetLanguages()) do
        table.insert(names, info.Name)
        map[info.Name] = info.Code
    end
    Settings:AddDropdown({
        Title = Library:T("Language"),
        Options = names,
        Default = (Library.Languages[Library:GetLanguage()] or {}).Name or "Tiếng Việt",
        Flag = "Language",
        Callback = function(name)
            if map[name] then
                Library:SetLanguage(map[name])
                Window:Notify({ Title = "NNVN", Content = Library:T("SaveConfig"), Duration = 2 })
            end
        end
    })
end

Settings:AddTextBox({
    Title = Library:T("BackgroundImage"),
    Description = Library:T("BackgroundImageDesc"),
    Placeholder = "10709752996",
    Flag = "BgId",
    Callback = function(t) Window:SetBackgroundImage(t) end
})

Settings:AddSlider({
    Title = Library:T("BackgroundTransparency"),
    Min = 0, Max = 1, Increment = 0.05, Default = 0.75,
    Flag = "BgT",
    Callback = function(v) Window:SetBackgroundImageTransparency(v) end
})

Settings:AddSlider({
    Title = Library:T("UIScale"),
    Min = Library:GetMinScale(), Max = Library:GetMaxScale(),
    Increment = 0.1, Default = 1,
    Callback = function(v) Library:SetUIScale(v) end
})

Settings:AddParagraph(Library:T("SaveConfig"), "Theme · Language · Size · Background")

local Misc = Window:MakeTab({ Title = Library:T("Misc") })
Misc:AddDropdown({
    Title = "Items",
    Options = { "A", "B", "C", "D", "E", "F", "G", "H" },
    Default = "A",
    Flag = "Item",
    Callback = print
})
Misc:AddButton({
    Title = Library:T("Notify"),
    Callback = function()
        Window:Notify({ Title = "NNVN", Content = Library:T("SaveConfig"), Duration = 3 })
    end
})

print("Themes:", table.concat(Library:GetThemes(), ", "))
print("Lang:", Library:GetLanguage(), "Mobile:", Library.IsMobile)
