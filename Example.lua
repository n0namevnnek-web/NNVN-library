--[[
    NNVN Hub - Full Example
    Version: v1.0.0
    
    HƯỚNG DẪN LOAD:
    
    Cách 1 - Host lên GitHub (khuyên dùng):
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/n0namevnnek-web/NNVN-library/main/NNVN-Library.lua"))()
    
    Cách 2 - Dùng readfile (Synapse, Script-Ware, Wave, Fluxus...):
        local Library = loadstring(readfile("NNVN-Library.lua"))()
    
    Cách 3 - Paste thẳng library vào:
        local Library = loadstring([[   ... paste toàn bộ NNVN-Library.lua ... ]])()
]]

-- ==================== LOAD LIBRARY ====================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/n0namevnnek-web/NNVN-library/main/NNVNLib.lua"
))()

-- ==================== TẠO WINDOW ====================
local Window = Library:MakeWindow({
    Title = "NNVN Hub",
    SubTitle = "v1.0.0 | Full Example",
    ScriptFolder = "NNVNHub" -- dùng để lưu flags + settings
})

-- Set background image (chỉ cần truyền ID số, library tự ghép rbxassetid://)
-- Window:SetBackgroundImage(1234567890) -- bỏ comment và thay ID thật nếu muốn

-- Minimize bằng phím
Window:NewMinimizer(Enum.KeyCode.RightControl)

-- ==================== TAB 1: MAIN ====================
local MainTab = Window:MakeTab({
    Title = "Main",
    Icon = "home"
})

-- Section có thể thu phóng (click để đóng/mở)
local PlayerSection = MainTab:AddSection("Player Settings")

MainTab:AddToggle({
    Title = "Speed Boost",
    Description = "Tăng tốc độ di chuyển",
    Default = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        print("Speed Boost:", Value)
    end
})

MainTab:AddSlider({
    Title = "WalkSpeed",
    Description = "Chỉnh tốc độ đi bộ",
    Min = 16,
    Max = 200,
    Increment = 1,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        print("WalkSpeed set to:", Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})

MainTab:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 300,
    Increment = 5,
    Default = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then 
            hum.JumpPower = Value 
        end
    end
})

MainTab:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
    Callback = function(Value)
        print("Infinite Jump:", Value)
    end
})

-- Section thứ 2 (cũng collapsible)
local CombatSection = MainTab:AddSection("Combat")

MainTab:AddToggle({
    Title = "Aimbot",
    Description = "Tự động nhắm",
    Default = false,
    Flag = "Aimbot",
    Callback = function(Value)
        print("Aimbot:", Value)
    end
})

MainTab:AddDropdown({
    Title = "Aimbot Bone",
    Description = "Chọn xương nhắm",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Flag = "AimbotBone",
    Callback = function(Value)
        print("Aimbot Bone:", Value)
    end
})

MainTab:AddSlider({
    Title = "Aim Smooth",
    Min = 0,
    Max = 1,
    Increment = 0.05,
    Default = 0.3,
    Flag = "AimSmooth",
    Callback = function(Value)
        print("Smooth:", Value)
    end
})

MainTab:AddButton({
    Title = "Kill All (Demo)",
    Description = "Chỉ là ví dụ, không thực sự kill",
    Callback = function()
        Window:Notify({
            Title = "Kill All",
            Content = "Đây chỉ là demo button!",
            Duration = 3
        })
    end
})

-- ==================== TAB 2: VISUALS ====================
local VisualTab = Window:MakeTab({
    Title = "Visuals",
    Icon = "eye"
})

VisualTab:AddSection("ESP")

VisualTab:AddToggle({
    Title = "Player ESP",
    Default = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        print("Player ESP:", Value)
    end
})

VisualTab:AddToggle({
    Title = "Box ESP",
    Default = false,
    Flag = "BoxESP",
    Callback = function(Value)
        print("Box ESP:", Value)
    end
})

VisualTab:AddToggle({
    Title = "Name ESP",
    Default = true,
    Flag = "NameESP",
    Callback = function(Value)
        print("Name ESP:", Value)
    end
})

VisualTab:AddToggle({
    Title = "Distance ESP",
    Default = true,
    Flag = "DistESP",
    Callback = function(Value)
        print("Distance ESP:", Value)
    end
})

VisualTab:AddSection("World")

VisualTab:AddToggle({
    Title = "Fullbright",
    Default = false,
    Flag = "Fullbright",
    Callback = function(Value)
        print("Fullbright:", Value)
    end
})

VisualTab:AddToggle({
    Title = "No Fog",
    Default = false,
    Flag = "NoFog",
    Callback = function(Value)
        print("No Fog:", Value)
    end
})

VisualTab:AddDropdown({
    Title = "Skybox",
    Options = {"Default", "Night", "Galaxy", "Sunset", "Custom"},
    Default = "Default",
    MultiSelect = false,
    Flag = "Skybox",
    Callback = function(Value)
        print("Skybox:", Value)
    end
})

-- ==================== TAB 3: DROPDOWN & SEARCH ====================
local DropdownTab = Window:MakeTab({
    Title = "Dropdown Demo",
    Icon = "list"
})

DropdownTab:AddSection("Dropdown với Search")

DropdownTab:AddParagraph("Hướng dẫn", "Click vào dropdown → sẽ hiện search box. Gõ để lọc option rất nhanh.")

DropdownTab:AddDropdown({
    Title = "Chọn Pet (Search được)",
    Description = "Dropdown có search sẵn",
    Options = {
        "Dragon", "Phoenix", "Unicorn", "Wolf", "Tiger", "Lion",
        "Eagle", "Shark", "Whale", "Dinosaur", "Robot", "Alien",
        "Cat", "Dog", "Bunny", "Fox", "Bear", "Panda"
    },
    Default = "Dragon",
    Flag = "SelectedPet",
    Callback = function(Value)
        print("Selected Pet:", Value)
        Window:Notify({
            Title = "Pet Selected",
            Content = "Bạn đã chọn: " .. tostring(Value),
            Duration = 2
        })
    end
})

DropdownTab:AddDropdown({
    Title = "Multi Select Weapons",
    Description = "Chọn nhiều vũ khí cùng lúc",
    Options = {"Sword", "Gun", "Bow", "Staff", "Axe", "Spear", "Dagger", "Hammer"},
    Default = {"Sword", "Gun"},
    MultiSelect = true,
    Flag = "Weapons",
    Callback = function(Value)
        print("Weapons:", Value)
    end
})

DropdownTab:AddSection("Dynamic Dropdown")

local DynamicDropdown = DropdownTab:AddDropdown({
    Title = "Dynamic Options",
    Options = {"Option A", "Option B"},
    Default = "Option A",
    Flag = "Dynamic",
    Callback = function(Value)
        print("Dynamic:", Value)
    end
})

DropdownTab:AddButton({
    Title = "Add Random Option",
    Callback = function()
        local newOpt = "Option " .. string.char(65 + math.random(0, 25)) .. math.random(10, 99)
        DynamicDropdown:Add(newOpt)
        Window:Notify({Title = "Added", Content = newOpt, Duration = 2})
    end
})

DropdownTab:AddButton({
    Title = "Clear All Options",
    Callback = function()
        DynamicDropdown:Clear()
        Window:Notify({Title = "Cleared", Content = "Đã xóa hết options", Duration = 2})
    end
})

-- ==================== TAB 4: INPUT & UTILS ====================
local UtilsTab = Window:MakeTab({
    Title = "Utils",
    Icon = "settings"
})

UtilsTab:AddSection("TextBox & Input")

UtilsTab:AddTextBox({
    Title = "Player Name",
    Description = "Nhập tên người chơi",
    Default = "",
    Placeholder = "Enter username...",
    Flag = "TargetName",
    Callback = function(Value)
        print("Target Name:", Value)
    end
})

UtilsTab:AddTextBox({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Flag = "Webhook",
    Callback = function(Value)
        print("Webhook:", Value)
    end
})

UtilsTab:AddSection("Buttons & Actions")

UtilsTab:AddButton({
    Title = "Copy JobId",
    Callback = function()
        setclipboard(game.JobId)
        Window:Notify({
            Title = "Copied",
            Content = "JobId đã copy vào clipboard!",
            Duration = 3
        })
    end
})

UtilsTab:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

UtilsTab:AddButton({
    Title = "Server Hop",
    Callback = function()
        Window:Notify({
            Title = "Server Hop",
            Content = "Đang tìm server khác...",
            Duration = 3
        })
    end
})

UtilsTab:AddSection("Notifications Demo")

UtilsTab:AddButton({
    Title = "Show Notify (3s)",
    Callback = function()
        Window:Notify({
            Title = "Success",
            Content = "Đây là thông báo bình thường kéo dài 3 giây",
            Duration = 3
        })
    end
})

UtilsTab:AddButton({
    Title = "Show Notify (5s + Icon)",
    Callback = function()
        Window:Notify({
            Title = "Warning",
            Content = "Thông báo có icon và thời gian dài hơn",
            Icon = "rbxassetid://10709752996",
            Duration = 5
        })
    end
})

UtilsTab:AddSection("Dialog Demo")

UtilsTab:AddButton({
    Title = "Open Confirm Dialog",
    Callback = function()
        Window:Dialog({
            Title = "Xác nhận hành động",
            Content = "Bạn có chắc muốn thực hiện hành động này không? Hành động không thể hoàn tác.",
            Options = {
                {
                    Title = "Đồng ý",
                    Callback = function()
                        Window:Notify({Title = "OK", Content = "Bạn đã chọn Đồng ý", Duration = 2})
                    end
                },
                {
                    Title = "Hủy",
                    Callback = function()
                        Window:Notify({Title = "Canceled", Content = "Đã hủy", Duration = 2})
                    end
                }
            }
        })
    end
})

-- ==================== TAB 5: THEME & UI ====================
local UITab = Window:MakeTab({
    Title = "UI Settings",
    Icon = "palette"
})

UITab:AddSection("Theme")

UITab:AddDropdown({
    Title = "Theme",
    Options = Library:GetThemes(),
    Default = Library:GetCurrentTheme().Name,
    Flag = "Theme",
    Callback = function(Value)
        Library:SetTheme(Value)
        Window:Notify({Title = "Theme", Content = "Đã đổi theme thành " .. Value, Duration = 2})
    end
})

UITab:AddSection("Background Image")

UITab:AddTextBox({
    Title = "Background Image ID",
    Description = "Chỉ cần nhập số ID (library tự thêm rbxassetid://)",
    Placeholder = "1234567890",
    Flag = "BgImageId",
    Callback = function(Value)
        if Value and Value ~= "" then
            Window:SetBackgroundImage(Value)
            Window:Notify({Title = "Background", Content = "Đã set background image!", Duration = 2})
        else
            Window:SetBackgroundImage(nil)
        end
    end
})

UITab:AddButton({
    Title = "Remove Background Image",
    Callback = function()
        Window:SetBackgroundImage(nil)
        Window:Notify({Title = "Background", Content = "Đã xóa ảnh nền", Duration = 2})
    end
})

UITab:AddSection("UI Scale")

UITab:AddSlider({
    Title = "UI Scale",
    Min = 0.6,
    Max = 1.6,
    Increment = 0.05,
    Default = 1,
    Flag = "UIScale",
    Callback = function(Value)
        Library:SetUIScale(Value)
    end
})

UITab:AddSection("Window Controls")

UITab:AddButton({
    Title = "Minimize Window",
    Callback = function()
        Window:Minimize()
    end
})

UITab:AddButton({
    Title = "Set Title Random",
    Callback = function()
        Window:SetTitle("NNVN Hub - " .. math.random(1000, 9999))
    end
})

UITab:AddButton({
    Title = "Set SubTitle",
    Callback = function()
        Window:SetSubTitle("Updated at " .. os.date("%H:%M:%S"))
    end
})

-- ==================== TAB 6: MISC ====================
local MiscTab = Window:MakeTab({
    Title = "Misc",
    Icon = "more-horizontal"
})

MiscTab:AddSection("Discord")

MiscTab:AddDiscordInvite({
    Title = "Join Community",
    Description = "Tham gia server Discord để nhận update và support!",
    Logo = "rbxassetid://10709752996",
    Invite = "https://discord.gg/example",
    Online = 1250,
    Members = 8500
})

MiscTab:AddSection("Paragraphs")

MiscTab:AddParagraph("Thông tin", "Đây là NNVN Hub với các tính năng:\n• Section thu phóng\n• Background image dễ dùng\n• Size nhỏ hơn + nền trong suốt hơn\n• Dropdown có search sẵn")

MiscTab:AddParagraph("Cách dùng Flag", "Mọi Toggle/Slider/Dropdown/TextBox đều hỗ trợ Flag. Giá trị sẽ tự động lưu vào ScriptFolder và load lại khi mở script lần sau.")

MiscTab:AddSection("Danger Zone")

MiscTab:AddButton({
    Title = "Destroy UI",
    Description = "Đóng và xóa toàn bộ UI",
    Callback = function()
        Window:Dialog({
            Title = "Destroy UI?",
            Content = "Bạn có chắc muốn đóng UI không?",
            Options = {
                {
                    Title = "Yes, Destroy",
                    Callback = function()
                        Library:Destroy()
                    end
                },
                {
                    Title = "No"
                }
            }
        })
    end
})

-- ==================== NOTIFY KHI LOAD XONG ====================
Window:Notify({
    Title = "Loaded Successfully",
    Content = "NNVN Hub đã sẵn sàng! Hãy khám phá các tab.",
    Duration = 5
})

print("[NNVN Hub] Example loaded successfully!")
