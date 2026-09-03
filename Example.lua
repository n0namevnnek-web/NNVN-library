--[[
    NNVN Hub — Full Example
    ========================
    API:
      Library:CreateWindow({ Title, Description, SizeUi?, Language, MinSize, MaxSize, ["Tab Width"] })
      Window:CreateTab({ Name, Icon })
      Tab:AddSection(Title, OpenSection?)
      Section:AddParagraph / AddSeperator / AddLine / AddButton / AddToggle / AddSlider / AddInput / AddDropdown
      Library:SetNotification({ Title, Description, Content, Time, Delay })
      Library:SetLanguage("vi"|"en")
      Library.FuncsV3  -- helper + SaveConfig

    Window controls:
      • Top-right: Minus (minimize) | Maximize | X (close)
      • Bottom bar: drag to move window
      • Bottom-right corner: resize
      • White dot on tab: indicates active tab
]]

-- ========= LOAD LIBRARY =========
-- Replace with your raw URL or readfile
local Library = loadstring(game:HttpGet("https://github.com/n0namevnnek-web/NNVN-library/raw/refs/heads/main/NNVNLib.lua"))()
-- local Library = loadstring(readfile("NNVN_Hub.lua"))()

-- ========= SAVE CONFIG =========
local SaveConfig = {
    ["Auto Farm"] = false,
    ["Speed Boost"] = true,
    ["WalkSpeed"] = 50,
    ["Weapon"] = {"Sword"},
    ["Player Name"] = "Player1",
}

-- ========= WINDOW =========
-- No fixed SizeUi → auto‑scale (PC 700×420, mobile 350×210)
local Window = Library:CreateWindow({
    Title = "NNVN Hub",
    Description = "v1.0",
    ["Tab Width"] = 140,
    Language = "en",                 -- default English
    MinSize = Vector2.new(480, 300),
    MaxSize = Vector2.new(1000, 650),
})

local F = Library.FuncsV3
F:SetTable(SaveConfig)

-- ========= TAB 1: MAIN =========
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://7734053426",
})

local MainSection = MainTab:AddSection("Core Features", true)

MainSection:AddParagraph({
    Title = "Window Guide",
    Content = "• Drag the top bar or bottom bar (BottomBar) to move\n• Drag the bottom‑right corner to resize\n• Buttons: – minimize | maximize | ✕ close\n• White dot = active tab",
})

MainSection:AddSeperator({ Title = "Buttons & Toggles" })

MainSection:AddButton({
    Title = "Test Notification",
    Content = "Show a notification at bottom‑right",
    Icon = "rbxassetid://16932740082",
    Callback = function()
        Library:SetNotification({
            Title = "NNVN Hub",
            Description = "Success",
            Content = "Notification OK!",
            Time = 0.4,
            Delay = 3,
        })
    end,
})

F:Button(MainSection, "Kill All (Demo)", "Just a demo callback", function()
    print("[NNVN] Kill All")
    Library:SetNotification({
        Title = "NNVN Hub",
        Description = "Info",
        Content = "Kill All called (demo)",
        Delay = 2,
    })
end)

F:Toggle(MainSection, "Auto Farm", "Enable/disable auto farming (saved)", "Save", function(v)
    SaveConfig["Auto Farm"] = v
    print("[NNVN] Auto Farm =", v)
end)

F:Toggle(MainSection, "Speed Boost", "Enable speed boost", "Save", function(v)
    SaveConfig["Speed Boost"] = v
    print("[NNVN] Speed Boost =", v)
end)

MainSection:AddLine()
MainSection:AddSeperator({ Title = "Slider & Input" })

MainSection:AddSlider({
    Title = "WalkSpeed",
    Content = "Adjust movement speed",
    Increment = 1,
    Min = 16,
    Max = 200,
    Default = SaveConfig["WalkSpeed"] or 50,
    Callback = function(v)
        SaveConfig["WalkSpeed"] = v
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

F:Textbox(MainSection, "Player Name", "Enter player name", "Save", function(text)
    SaveConfig["Player Name"] = text
    print("[NNVN] Player Name =", text)
end)

MainSection:AddInput({
    Title = "Webhook URL",
    Content = "Paste webhook (demo)",
    Default = "",
    Callback = function(text)
        print("[NNVN] Webhook =", text)
    end,
})

-- ========= TAB 2: COMBAT =========
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "rbxassetid://7733920644",
})

local CombatSec = CombatTab:AddSection("Weapons & Skills", true)

F:Dropdown(CombatSec, "Weapon", "Choose a weapon", false, {
    "Sword", "Gun", "Bow", "Magic Staff", "Dagger"
}, "Save", function(val)
    SaveConfig["Weapon"] = val
    print("[NNVN] Weapon =", table.concat(val, ", "))
end)

CombatSec:AddDropdown({
    Title = "Skills (Multi)",
    Content = "Select multiple skills + search",
    Multi = true,
    Options = {"Slash", "Fireball", "Heal", "Dash", "Shield"},
    Default = {"Slash"},
    Callback = function(val)
        print("[NNVN] Skills =", table.concat(val, ", "))
    end,
})

CombatSec:AddToggle({
    Title = "Auto Attack",
    Content = "Automatically attack nearest enemy",
    Default = false,
    Callback = function(v) print("[NNVN] Auto Attack =", v) end,
})

CombatSec:AddSlider({
    Title = "Attack Range",
    Content = "Attack range in studs",
    Increment = 1,
    Min = 5,
    Max = 100,
    Default = 25,
    Callback = function(v) print("[NNVN] Range =", v) end,
})

-- ========= TAB 3: SETTINGS =========
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "rbxassetid://7734053495",
})

local LangSec = SettingsTab:AddSection("Language & Interface", true)

LangSec:AddParagraph({
    Title = "What is BottomBar?",
    Content = "The long bar at the bottom of the window is the BottomBar (drag handle). Drag it to move the UI. The bottom‑right corner is the resize handle.",
})

-- Dropdown to switch language (replaces two separate buttons)
LangSec:AddDropdown({
    Title = "Language",
    Content = "Choose interface language",
    Multi = false,
    Options = {"English", "Tiếng Việt"},
    Default = {"English"},
    Callback = function(val)
        local lang = val[1]
        if lang == "Tiếng Việt" then
            Library:SetLanguage("vi")
            Library:SetNotification({
                Title = "NNVN Hub",
                Description = "Ngôn ngữ",
                Content = "Đã chuyển sang Tiếng Việt",
                Delay = 2,
            })
        else
            Library:SetLanguage("en")
            Library:SetNotification({
                Title = "NNVN Hub",
                Description = "Language",
                Content = "Switched to English",
                Delay = 2,
            })
        end
    end,
})

LangSec:AddSeperator({ Title = "Other" })

LangSec:AddButton({
    Title = "Print SaveConfig",
    Content = "Print current config to console",
    Callback = function()
        print("===== SaveConfig =====")
        for k, v in pairs(SaveConfig) do
            if type(v) == "table" then
                print(k, "=", table.concat(v, ", "))
            else
                print(k, "=", v)
            end
        end
    end,
})

LangSec:AddButton({
    Title = "Notify x3",
    Content = "Test stacked notifications",
    Callback = function()
        for i = 1, 3 do
            task.spawn(function()
                Library:SetNotification({
                    Title = "NNVN Hub",
                    Description = "Test #" .. i,
                    Content = "Notification number " .. i,
                    Delay = 3 + i,
                })
            end)
            task.wait(0.15)
        end
    end,
})

-- ========= TAB 4: EXTRA =========
local ExtraTab = Window:CreateTab({
    Name = "Extra",
    Icon = "rbxassetid://7733715400",
})

local ExtraSec = ExtraTab:AddSection("All Components", true)

ExtraSec:AddParagraph({
    Title = "Paragraph",
    Content = "Long descriptive text. Text wraps automatically.",
})

ExtraSec:AddSeperator({ Title = "Separator Title" })
ExtraSec:AddLine()

ExtraSec:AddButton({
    Title = "Button",
    Content = "Standard button",
    Callback = function() print("Button clicked") end,
})

ExtraSec:AddToggle({
    Title = "Toggle",
    Content = "On/off switch",
    Default = true,
    Callback = function(v) print("Toggle =", v) end,
})

ExtraSec:AddSlider({
    Title = "Slider",
    Content = "Drag or type a number",
    Increment = 5,
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(v) print("Slider =", v) end,
})

ExtraSec:AddInput({
    Title = "Input",
    Content = "Text input field",
    Default = "Hello NNVN",
    Callback = function(t) print("Input =", t) end,
})

ExtraSec:AddDropdown({
    Title = "Dropdown Single",
    Content = "Select one option",
    Multi = false,
    Options = {"A", "B", "C", "D"},
    Default = {"A"},
    Callback = function(v) print("Dropdown =", table.concat(v, ",")) end,
})

ExtraSec:AddDropdown({
    Title = "Dropdown Multi",
    Content = "Select multiple + search",
    Multi = true,
    Options = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"},
    Default = {"Red", "Blue"},
    Callback = function(v) print("Multi =", table.concat(v, ",")) end,
})

-- ========= STARTUP NOTIFICATION =========
print("[NNVN Hub] Example loaded!")
Library:SetNotification({
    Title = "NNVN Hub",
    Description = "Ready",
    Content = "UI ready. Drag BottomBar / resize corner to test!",
    Delay = 4,
})