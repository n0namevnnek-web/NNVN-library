# NNVN Lib v1.1

**Compact · Smooth · Sharp** Roblox UI Library.

## What's new in 1.1
- Default window **460×300** (was 550×380), tab width **130**
- Faster, smoother tweens (~0.15–0.22s, Quint Out)
- Crisper look: Gotham font, thinner strokes (0.8px), tighter padding, higher contrast theme
- Smaller controls (toggle, slider, textbox, dropdown)

## Features
- Dropdown **with Search**
- Background Image — enter **Asset ID only** (`rbxassetid://` auto-added)
- Themes · Flags save/load · Notifications · Dialogs
- Tabs, Sections, Toggle, Slider, TextBox, Button, Paragraph, Discord Invite
- Minimizer keybind, resizable window

## Quick start

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL/NNVNLib.lua"))()

Library.Default.BackgroundImage = "10709752996"  -- ID only
Library.Default.BackgroundImageTransparency = 0.72

local Window = Library:MakeWindow({
    Title = "My Hub",
    SubTitle = "v1.1",
    ScriptFolder = "MyHub",
    BackgroundImage = "10709752996",
    BackgroundImageTransparency = 0.7
})

Window:NewMinimizer(Enum.KeyCode.RightControl)

local Tab = Window:MakeTab({ Title = "Main", Icon = "home" })
Tab:AddToggle({
    Title = "Enable",
    Default = false,
    Flag = "Enable",
    Callback = function(v) print(v) end
})

-- Runtime background
Window:SetBackgroundImage("123456789")
Window:SetBackgroundImageTransparency(0.5)
```

## Files
- `NNVNLib.lua` — main library
- `Example.lua` — usage demo
