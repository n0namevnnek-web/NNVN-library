--[[
    NNVN Hub — Full Example (API đúng)
    ================================
    API:
      Library:CreateWindow({ Title, Description, SizeUi, Language, MinSize, MaxSize, ["Tab Width"] })
      Window:CreateTab({ Name, Icon })
      Tab:AddSection(Title, OpenSection?)   -- KHÔNG phải CreateSection
      Section:AddParagraph / AddSeperator / AddLine / AddButton / AddToggle / AddSlider / AddInput / AddDropdown
      Library:SetNotification({ Title, Description, Content, Time, Delay })
      Library:SetLanguage("vi"|"en")
      Library.FuncsV3  -- helper + SaveConfig

    Cửa sổ:
      • 3 nút góc phải: Minimize (minus) | Maximize | Close (x)  — icon Lucide
      • Thanh dưới (BottomBar): kéo để di chuyển UI
      • Góc phải dưới: resize (thu phóng)
      • Chấm trắng bên tab: đánh dấu tab đang chọn
]]

-- ========= LOAD LIBRARY =========
-- Đổi sang link raw / readfile của bạn:
local Library = loadstring(game:HttpGet("YOUR_RAW_URL_NNVN_Hub.lua"))()
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
local Window = Library:CreateWindow({
    Title = "NNVN Hub",
    Description = "v1.0",
    ["Tab Width"] = 140,
    SizeUi = UDim2.fromOffset(720, 440),
    Language = "vi",
    MinSize = Vector2.new(480, 300),
    MaxSize = Vector2.new(1000, 650),
})

local F = Library.FuncsV3
F:SetTable(SaveConfig)

-- ========= TAB 1: CHÍNH =========
local MainTab = Window:CreateTab({
    Name = "Chính",
    Icon = "rbxassetid://7734053426",
})

-- ĐÚNG API: AddSection (không phải CreateSection)
local MainSection = MainTab:AddSection("Tính năng chính", true)

MainSection:AddParagraph({
    Title = "Hướng dẫn cửa sổ",
    Content = "• Kéo thanh trên hoặc thanh dưới (BottomBar) để di chuyển\n• Kéo góc phải dưới để thu phóng (resize)\n• Nút – thu nhỏ | maximize phóng to | x đóng\n• Chấm trắng = tab đang chọn",
})

MainSection:AddSeperator({ Title = "Nút & Toggle" })

MainSection:AddButton({
    Title = "Test Notification",
    Content = "Hiện thông báo góc dưới bên trái",
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

F:Button(MainSection, "Kill All (Demo)", "Chỉ là ví dụ callback", function()
    print("[NNVN] Kill All")
    Library:SetNotification({
        Title = "NNVN Hub",
        Description = "Info",
        Content = "Đã gọi Kill All (demo)",
        Delay = 2,
    })
end)

F:Toggle(MainSection, "Auto Farm", "Bật/tắt auto farm (lưu config)", "Save", function(v)
    SaveConfig["Auto Farm"] = v
    print("[NNVN] Auto Farm =", v)
end)

F:Toggle(MainSection, "Speed Boost", "Tăng tốc độ", "Save", function(v)
    SaveConfig["Speed Boost"] = v
    print("[NNVN] Speed Boost =", v)
end)

MainSection:AddLine()
MainSection:AddSeperator({ Title = "Slider & Input" })

MainSection:AddSlider({
    Title = "WalkSpeed",
    Content = "Chỉnh tốc độ đi",
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

F:Textbox(MainSection, "Player Name", "Nhập tên người chơi", "Save", function(text)
    SaveConfig["Player Name"] = text
    print("[NNVN] Player Name =", text)
end)

MainSection:AddInput({
    Title = "Webhook URL",
    Content = "Dán webhook (demo)",
    Default = "",
    Callback = function(text)
        print("[NNVN] Webhook =", text)
    end,
})

-- ========= TAB 2: CHIẾN ĐẤU =========
local CombatTab = Window:CreateTab({
    Name = "Chiến đấu",
    Icon = "rbxassetid://7733920644",
})

local CombatSec = CombatTab:AddSection("Vũ khí & Skill", true)

F:Dropdown(CombatSec, "Weapon", "Chọn vũ khí", false, {
    "Sword", "Gun", "Bow", "Magic Staff", "Dagger"
}, "Save", function(val)
    SaveConfig["Weapon"] = val
    print("[NNVN] Weapon =", table.concat(val, ", "))
end)

CombatSec:AddDropdown({
    Title = "Skills (Multi)",
    Content = "Chọn nhiều skill + search",
    Multi = true,
    Options = {"Slash", "Fireball", "Heal", "Dash", "Shield"},
    Default = {"Slash"},
    Callback = function(val)
        print("[NNVN] Skills =", table.concat(val, ", "))
    end,
})

CombatSec:AddToggle({
    Title = "Auto Attack",
    Content = "Tự động đánh quái gần nhất",
    Default = false,
    Callback = function(v) print("[NNVN] Auto Attack =", v) end,
})

CombatSec:AddSlider({
    Title = "Attack Range",
    Content = "Phạm vi tấn công",
    Increment = 1,
    Min = 5,
    Max = 100,
    Default = 25,
    Callback = function(v) print("[NNVN] Range =", v) end,
})

-- ========= TAB 3: CÀI ĐẶT =========
local SettingsTab = Window:CreateTab({
    Name = "Cài đặt",
    Icon = "rbxassetid://7734053495",
})

local LangSec = SettingsTab:AddSection("Ngôn ngữ & Giao diện", true)

LangSec:AddParagraph({
    Title = "BottomBar là gì?",
    Content = "Thanh dài dưới đáy cửa sổ = BottomBar (thanh kéo). Kéo nó để di chuyển UI. Góc phải dưới = ResizeHandle (thu phóng).",
})

LangSec:AddButton({
    Title = "Tiếng Việt",
    Content = "Đổi sang tiếng Việt",
    Callback = function()
        Library:SetLanguage("vi")
        Library:SetNotification({
            Title = "NNVN Hub",
            Description = "Ngôn ngữ",
            Content = "Đã chuyển sang Tiếng Việt",
            Delay = 2,
        })
    end,
})

LangSec:AddButton({
    Title = "English",
    Content = "Switch to English",
    Callback = function()
        Library:SetLanguage("en")
        Library:SetNotification({
            Title = "NNVN Hub",
            Description = "Language",
            Content = "Switched to English",
            Delay = 2,
        })
    end,
})

LangSec:AddSeperator({ Title = "Khác" })

LangSec:AddButton({
    Title = "Print SaveConfig",
    Content = "In config ra console",
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
    Content = "Test stack notification",
    Callback = function()
        for i = 1, 3 do
            task.spawn(function()
                Library:SetNotification({
                    Title = "NNVN Hub",
                    Description = "Test #" .. i,
                    Content = "Thông báo số " .. i,
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

local ExtraSec = ExtraTab:AddSection("Tất cả component", true)

ExtraSec:AddParagraph({
    Title = "Paragraph",
    Content = "Ghi chú / hướng dẫn dài. Text tự wrap.",
})

ExtraSec:AddSeperator({ Title = "Separator Title" })
ExtraSec:AddLine()

ExtraSec:AddButton({
    Title = "Button",
    Content = "Nút thường",
    Callback = function() print("Button") end,
})

ExtraSec:AddToggle({
    Title = "Toggle",
    Content = "Công tắc",
    Default = true,
    Callback = function(v) print("Toggle", v) end,
})

ExtraSec:AddSlider({
    Title = "Slider",
    Content = "Kéo hoặc nhập số",
    Increment = 5,
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(v) print("Slider", v) end,
})

ExtraSec:AddInput({
    Title = "Input",
    Content = "Ô nhập text",
    Default = "Hello NNVN",
    Callback = function(t) print("Input", t) end,
})

ExtraSec:AddDropdown({
    Title = "Dropdown Single",
    Content = "Chọn 1",
    Multi = false,
    Options = {"A", "B", "C", "D"},
    Default = {"A"},
    Callback = function(v) print("DD", table.concat(v, ",")) end,
})

ExtraSec:AddDropdown({
    Title = "Dropdown Multi",
    Content = "Chọn nhiều + search",
    Multi = true,
    Options = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange"},
    Default = {"Red", "Blue"},
    Callback = function(v) print("Multi", table.concat(v, ",")) end,
})

print("[NNVN Hub] Example loaded!")
Library:SetNotification({
    Title = "NNVN Hub",
    Description = "Ready",
    Content = "UI sẵn sàng. Kéo BottomBar / resize góc để thử!",
    Delay = 4,
})
