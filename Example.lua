--[[
    NNVN Hub - Example
    By N0NAMEVN
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/n0namevnnek-web/NNVN-library/main/NNVNLib.lua"
))()

local Window = Library:CreateWindow({
    Title = "NNVN Hub",
    SubTitle = "By N0NAMEVN",
})

-- ==================== MAIN ====================
local Main = Window:CreateTab({ Title = "Main" })

local PlayerSec = Main:CreateSection("Player")

PlayerSec:AddToggle({
    Title = "Speed Boost",
    Description = "Tăng tốc độ di chuyển",
    Default = false,
    Callback = function(v)
        print("Speed:", v)
    end
})

PlayerSec:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

PlayerSec:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end
})

PlayerSec:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) print("InfJump:", v) end
})

local CombatSec = Main:CreateSection("Combat")

CombatSec:AddToggle({
    Title = "Aimbot",
    Description = "Tự động nhắm",
    Default = false,
    Callback = function(v) print("Aimbot:", v) end
})

CombatSec:AddDropdown({
    Title = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Callback = function(v) print("Part:", v) end
})

CombatSec:AddButton({
    Title = "Kill All (Demo)",
    Callback = function()
        Library:Notify({ Title = "Demo", Content = "This is only a demo button!", Duration = 3 })
    end
})

-- ==================== VISUALS ====================
local Visual = Window:CreateTab({ Title = "Visuals" })

local EspSec = Visual:CreateSection("ESP")

EspSec:AddToggle({ Title = "Player ESP", Default = false, Callback = function(v) print(v) end })
EspSec:AddToggle({ Title = "Box ESP", Default = false, Callback = function(v) print(v) end })
EspSec:AddToggle({ Title = "Name ESP", Default = true, Callback = function(v) print(v) end })
EspSec:AddToggle({ Title = "Distance ESP", Default = true, Callback = function(v) print(v) end })

local WorldSec = Visual:CreateSection("World")
WorldSec:AddToggle({ Title = "Fullbright", Default = false, Callback = function(v) print(v) end })
WorldSec:AddToggle({ Title = "No Fog", Default = false, Callback = function(v) print(v) end })

-- ==================== DROPDOWN DEMO ====================
local DropTab = Window:CreateTab({ Title = "Dropdown" })
local DropSec = DropTab:CreateSection("Search Dropdown")

DropSec:AddParagraph("Hướng dẫn", "Click dropdown → gõ để search rất nhanh. Hỗ trợ Multi Select.")

DropSec:AddDropdown({
    Title = "Pet",
    Options = {"Dragon", "Phoenix", "Unicorn", "Wolf", "Tiger", "Lion", "Eagle", "Shark", "Cat", "Dog", "Fox", "Panda"},
    Default = "Dragon",
    Callback = function(v)
        Library:Notify({ Title = "Selected", Content = tostring(v), Duration = 2 })
    end
})

DropSec:AddDropdown({
    Title = "Weapons (Multi)",
    Options = {"Sword", "Gun", "Bow", "Staff", "Axe", "Spear"},
    Default = {"Sword"},
    Multi = true,
    Callback = function(v) print("Weapons:", v) end
})

-- ==================== UTILS ====================
local Utils = Window:CreateTab({ Title = "Utils" })
local InputSec = Utils:CreateSection("Input")

InputSec:AddTextBox({
    Title = "Player Name",
    Placeholder = "Enter username...",
    Callback = function(v) print("Name:", v) end
})

InputSec:AddTextBox({
    Title = "Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) print("Webhook:", v) end
})

local ActionSec = Utils:CreateSection("Actions")

ActionSec:AddButton({
    Title = "Copy JobId",
    Callback = function()
        if setclipboard then setclipboard(game.JobId) end
        Library:Notify({ Title = "Copied", Content = "JobId copied!", Duration = 2 })
    end
})

ActionSec:AddButton({
    Title = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

ActionSec:AddButton({
    Title = "Show Notify",
    Callback = function()
        Library:Notify({ Title = "NNVN Hub", Content = "Notification demo!", Duration = 3 })
    end
})

-- ==================== SETTINGS ====================
local Settings = Window:CreateTab({ Title = "Settings" })

local ThemeSec = Settings:CreateSection("Theme & Language")

ThemeSec:AddDropdown({
    Title = "Theme",
    Options = {"Default", "Dark", "Red", "Green", "Purple", "Cyan", "Orange"},
    Default = "Default",
    Callback = function(v)
        Window:SetTheme(v)
    end
})

ThemeSec:AddDropdown({
    Title = "Language",
    Options = {"en", "vi"},
    Default = "en",
    Callback = function(v)
        Window:SetLanguage(v)
    end
})

ThemeSec:AddParagraph("Info", "Default theme = Gray / White\nPC size lớn hơn, Mobile nhỏ hơn một chút.\nNút ⛶ = Fullscreen")

local DiscordSec = Settings:CreateSection("Discord")

DiscordSec:AddDiscordInvite({
    Title = "NNVN Community",
    Description = "Join our Discord!",
    Invite = "discord.gg/example",
})

local DangerSec = Settings:CreateSection("Danger Zone")

DangerSec:AddButton({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

print("[NNVN Hub] Example loaded!")
