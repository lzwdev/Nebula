-- Fruit Farm Script v13.1 - Fruits + Log + Manual TP + Toast + Manual Sea Select
-- Features: Fruit ESP, Auto Collect (Tween), Tween Speed Slider, Manual TP, Fruit Spawn Toast, Manual Sea

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game:GetService("Players") and game:GetService("Workspace") and game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ==================== NOCLIP ====================
_G.NoclipActive = true
local function EnableNoclip(c)
    if not c then return end
    pcall(function() for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
end
local function DisableNoclip(c)
    if not c then return end
    pcall(function() for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end)
end
LP.CharacterAdded:Connect(function(c) task.wait(0.1); if _G.NoclipActive then EnableNoclip(c) end end)
RunService.Stepped:Connect(function() if _G.NoclipActive and LP.Character then EnableNoclip(LP.Character) end end)

-- ==================== ISLANDS ====================
local Islands_FirstSea = {
    -- (leer gelassen - falls du die mal hast, hier eintragen)
}

local Islands_SecondSea = {
    {name="Haunted Ship",   pos=Vector3.new(962,   125, 32894)},
    {name="Dark Arena",     pos=Vector3.new(3964,  13,  -3473)},
    {name="Skull",          pos=Vector3.new(-2943, 116, -9964)},
    {name="Dog House",      pos=Vector3.new(-1973, 130, -66)},
    {name="Docks 2",        pos=Vector3.new(16,    39,  2708)},
    {name="Lava",           pos=Vector3.new(-5308, 285, -5523)},
    {name="Raid",           pos=Vector3.new(-6474, 85,  -4877)},
    {name="Snow",           pos=Vector3.new(1137,  429, -4738)},
    {name="Colloseum",      pos=Vector3.new(-1834, 45,  1666)},
    {name="Graveyard",      pos=Vector3.new(-5721, 126, -742)},
    {name="Lab",            pos=Vector3.new(-5545, 224, -5870)},
    {name="Mansion",        pos=Vector3.new(-518,  332, 591)},
    {name="Cafe",           pos=Vector3.new(-397,  73,  338)},
    {name="Docks 4",        pos=Vector3.new(-5850, 7,   -5053)},
    {name="Docks 1",        pos=Vector3.new(-968,  9,   1810)},
    {name="Winter Castle",  pos=Vector3.new(5522,  28,  -6369)},
    {name="Remote",         pos=Vector3.new(4779,  8,   2874)},
    {name="Docks 3",        pos=Vector3.new(-1940, 6,   -2607)},
}

local Islands_ThirdSea = {
    {name="Cake Land",         pos=Vector3.new(-2082,  70,  -12128)},
    {name="Turtle Mountain",   pos=Vector3.new(-12849, 844, -10731)},
    {name="Ice Cream Land",    pos=Vector3.new(-910,   59,  -10874)},
    {name="Tiki Outpost",      pos=Vector3.new(-16450, 528, 423)},
    {name="Turtle Mansion",    pos=Vector3.new(-12541, 332, -7835)},
    {name="Great Tree",        pos=Vector3.new(4348,   566, -6141)},
    {name="Hydra Town",        pos=Vector3.new(5291,   1005, 411)},
    {name="Haunted Castle",    pos=Vector3.new(-9505,  142, 5518)},
    {name="Port",              pos=Vector3.new(-334,   21,  5534)},
    {name="Peanut Island",     pos=Vector3.new(-2029,  10,  -9962)},
    {name="Turtle Entrance",   pos=Vector3.new(-10154, 332, -8336)},
    {name="Hydra Arena",       pos=Vector3.new(5030,   51,  -2026)},
    {name="Chocolate Island",  pos=Vector3.new(387,    127, -12734)},
    {name="Sea Castle",        pos=Vector3.new(-5493,  314, -2880)},
    {name="Turtle Center",     pos=Vector3.new(-12023, 332, -9170)},
}

-- ==================== SEA-DETECTION ====================
-- Priorität: 1) ManualSea   2) Sea.Value   3) Attribute   4) Workspace   5) Koordinaten

local function GetAutoSea()
    -- 1) ReplicatedStorage.Sea.Value
    local sv = ReplicatedStorage:FindFirstChild("Sea")
    if sv and sv:IsA("ValueBase") then
        local ok, v = pcall(function() return sv.Value end)
        if ok and type(v) == "number" and v >= 1 and v <= 3 then
            return v, "Sea.Value"
        end
    end
    -- 1b) SeaName / SeaValue (alternative Namen)
    for _, nm in ipairs({"SeaName", "SeaValue", "CurrentSea", "Sea"}) do
        local o = ReplicatedStorage:FindFirstChild(nm)
        if o then
            local ok, v = pcall(function() return o.Value end)
            if ok then
                if type(v) == "number" and v >= 1 and v <= 3 then return v, "RS."..nm..".Value" end
                if type(v) == "string" then
                    if string.find(string.lower(v), "third") then return 3, "RS."..nm.."(str)" end
                    if string.find(string.lower(v), "second") then return 2, "RS."..nm.."(str)" end
                    if string.find(string.lower(v), "first") then return 1, "RS."..nm.."(str)" end
                end
            end
        end
    end
    -- 2) Player Attribute
    for _, an in ipairs({"Sea", "CurrentSea", "SeaLevel"}) do
        local a = LP:GetAttribute(an)
        if type(a) == "number" and a >= 1 and a <= 3 then return a, "LP:Attr("..an..")" end
        if type(a) == "string" then
            if string.find(string.lower(a), "third") then return 3, "LP:Attr("..an..")" end
            if string.find(string.lower(a), "second") then return 2, "LP:Attr("..an..")" end
            if string.find(string.lower(a), "first") then return 1, "LP:Attr("..an..")" end
        end
    end
    -- 3) Character Attribute
    if LP.Character then
        local cattr = LP.Character:GetAttribute("Sea")
        if type(cattr) == "number" and cattr >= 1 and cattr <= 3 then
            return cattr, "Char:Attr"
        end
    end
    -- 4) Workspace Marker
    if workspace:FindFirstChild("ThirdSea") or workspace:FindFirstChild("ThirdSeaIslands") then return 3, "WS.Marker" end
    if workspace:FindFirstChild("SecondSea") or workspace:FindFirstChild("SecondSeaIslands") then return 2, "WS.Marker" end
    -- 5) Koordinaten
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local p = char.HumanoidRootPart.Position
        for _, i in ipairs(Islands_ThirdSea) do
            if (p - i.pos).Magnitude < 800 then return 3, "Coord" end
        end
        for _, i in ipairs(Islands_SecondSea) do
            if (p - i.pos).Magnitude < 800 then return 2, "Coord" end
        end
    end
    return 0, "None"
end

-- Liefert die aktuelle Sea (ManualSea hat Vorrang)
local function GetCurrentSea()
    if _G.ManualSea and _G.ManualSea >= 1 and _G.ManualSea <= 3 then
        return _G.ManualSea, "Manual"
    end
    return GetAutoSea()
end

local function GetCurrentIslands()
    local sea = GetCurrentSea()
    if sea == 1 then return Islands_FirstSea end
    if sea == 2 then return Islands_SecondSea end
    if sea == 3 then return Islands_ThirdSea end
    return {}
end

local function GetNearestIsland(pos)
    local islands = GetCurrentIslands()
    if #islands == 0 then return "Unbekannt", 0 end
    local nearest, nearestDist = nil, math.huge
    for _, island in ipairs(islands) do
        local d = (island.pos - pos).Magnitude
        if d < nearestDist then
            nearestDist = d
            nearest = island
        end
    end
    if nearest then return nearest.name, nearestDist end
    return "Unbekannt", 0
end

local function GetSeaLabel()
    local sea = GetCurrentSea()
    if sea == 1 then return "🌊 First Sea" end
    if sea == 2 then return "🌊 Second Sea" end
    if sea == 3 then return "🌊 Third Sea" end
    return "🌊 Unknown Sea"
end

-- ==================== SETTINGS ====================
local SettingsFile = "FruitFarm_Settings.json"
local DefaultSettings = {
    FruitESP = false, Noclip = true, AutoFruit = false,
    TweenSpeed = 220, FruitNotify = true, ManualSea = 0
}
local function SaveSettings()
    local s = {
        FruitESP = _G.FruitESP, Noclip = _G.NoclipActive,
        AutoFruit = _G.AutoFruit, TweenSpeed = _G.TweenSpeed,
        FruitNotify = _G.FruitNotify, ManualSea = _G.ManualSea or 0
    }
    if writefile then pcall(function() writefile(SettingsFile, HttpService:JSONEncode(s)) end) end
end
local function LoadSettings()
    local s = DefaultSettings
    if readfile then pcall(function() local d=readfile(SettingsFile); local l=HttpService:JSONDecode(d); for k,v in pairs(l) do s[k]=v end end) end
    return s
end

-- ==================== VARIABLEN ====================
_G.FruitESP=false; _G.AutoFruit=false; _G.TweenSpeed=220; _G.FruitNotify=true; _G.ManualSea=0
local saved = LoadSettings()
_G.FruitESP=saved.FruitESP; _G.NoclipActive=saved.Noclip
_G.AutoFruit=saved.AutoFruit or false; _G.TweenSpeed=saved.TweenSpeed or 220
_G.FruitNotify = saved.FruitNotify ~= false; _G.ManualSea = saved.ManualSea or 0

local fruitEspObjects={}; local currentTween=nil; local minimized=false; local currentTab="Fruits"
local isFarmingFruit=false; local knownFruits={}; local notifyLog={}
local manualBusy=false

-- ==================== FRUIT ERKENNUNG ====================
local function GetFruits()
    local fruits={}
    pcall(function()
        for _, obj in pairs(workspace:GetChildren()) do
            if obj and obj:FindFirstChild("Handle") then
                local h = obj.Handle
                if h and h:IsA("BasePart") then
                    local isFruit = false
                    if obj:IsA("Tool") then isFruit = true end
                    if string.find(obj.Name, "Fruit") or string.find(obj.Name:lower(), "fruit") then isFruit = true end
                    if obj:GetAttribute("Fruit") then isFruit = true end
                    if isFruit then table.insert(fruits, obj) end
                end
            end
        end
    end)
    return fruits
end

-- ==================== TOAST NOTIFICATION ====================
local ToastGui = Instance.new("ScreenGui")
ToastGui.Name = "FruitFarmToasts"
ToastGui.Parent = CoreGui
ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToastGui.ResetOnSpawn = false

local toastContainer = Instance.new("Frame")
toastContainer.Size = UDim2.new(0, 320, 1, 0)
toastContainer.Position = UDim2.new(1, -330, 0, 0)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = ToastGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 8)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Top
toastLayout.Parent = toastContainer

local toastPad = Instance.new("UIPadding")
toastPad.PaddingTop = UDim.new(0, 20)
toastPad.Parent = toastContainer

local function ShowToast(title, subtitle, color, islandText)
    color = color or Color3.fromRGB(255, 150, 50)
    islandText = islandText or ""
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 300, 0, 95)
    toast.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(1, 20, 0, 0)
    toast.Parent = toastContainer
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 5, 1, 0)
    stripe.BackgroundColor3 = color
    stripe.BorderSizePixel = 0
    stripe.Parent = toast
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 15, 0, 14)
    icon.BackgroundColor3 = color
    icon.BackgroundTransparency = 0.85
    icon.Text = "🍎"
    icon.TextSize = 22
    icon.Font = Enum.Font.GothamBold
    icon.TextColor3 = Color3.fromRGB(255,255,255)
    icon.BorderSizePixel = 0
    icon.Parent = toast
    Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 0, 22)
    titleLbl.Position = UDim2.new(0, 65, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.TextSize = 14
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = toast

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -70, 0, 18)
    subLbl.Position = UDim2.new(0, 65, 0, 32)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = subtitle
    subLbl.TextColor3 = Color3.fromRGB(200,200,220)
    subLbl.TextSize = 11
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.TextTruncate = Enum.TextTruncate.AtEnd
    subLbl.Parent = toast

    local seaLbl = Instance.new("TextLabel")
    seaLbl.Size = UDim2.new(1, -70, 0, 16)
    seaLbl.Position = UDim2.new(0, 65, 0, 52)
    seaLbl.BackgroundTransparency = 1
    seaLbl.Text = islandText
    seaLbl.TextColor3 = color
    seaLbl.TextSize = 11
    seaLbl.Font = Enum.Font.GothamBold
    seaLbl.TextXAlignment = Enum.TextXAlignment.Left
    seaLbl.TextTruncate = Enum.TextTruncate.AtEnd
    seaLbl.Parent = toast

    local seaTag = Instance.new("TextLabel")
    seaTag.Size = UDim2.new(1, -70, 0, 14)
    seaTag.Position = UDim2.new(0, 65, 0, 68)
    seaTag.BackgroundTransparency = 1
    seaTag.Text = GetSeaLabel()
    seaTag.TextColor3 = Color3.fromRGB(150, 200, 255)
    seaTag.TextSize = 10
    seaTag.Font = Enum.Font.Gotham
    seaTag.TextXAlignment = Enum.TextXAlignment.Left
    seaTag.Parent = toast

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.Position = UDim2.new(0, 0, 1, -3)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = toast
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 0)}):Play()

    TweenService:Create(bar, TweenInfo.new(5, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 3)}):Play()

    task.delay(5, function()
        if toast and toast.Parent then
            local out = TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1})
            out:Play()
            for _,d in pairs(toast:GetDescendants()) do
                if d:IsA("TextLabel") then
                    TweenService:Create(d, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
                elseif d:IsA("Frame") then
                    TweenService:Create(d, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
                end
            end
            out.Completed:Wait()
            toast:Destroy()
        end
    end)
end

-- ==================== UI ====================
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="FruitFarmUI"; ScreenGui.Parent=CoreGui
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.ResetOnSpawn=false

local MainFrame=Instance.new("Frame")
MainFrame.Size=UDim2.new(0,340,0,540); MainFrame.Position=UDim2.new(0.5,-170,0.5,-270)
MainFrame.BackgroundColor3=Color3.fromRGB(15,15,25); MainFrame.BorderSizePixel=0
MainFrame.Active=true; MainFrame.Draggable=true; MainFrame.ClipsDescendants=true; MainFrame.Parent=ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,10)

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-34,0,8)
CloseBtn.BackgroundColor3=Color3.fromRGB(255,60,60); CloseBtn.BorderSizePixel=0
CloseBtn.Text="✕"; CloseBtn.TextColor3=Color3.fromRGB(255,255,255); CloseBtn.TextSize=16
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.ZIndex=10; CloseBtn.Parent=MainFrame
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8)
CloseBtn.MouseButton1Click:Connect(function()
    _G.FruitESP=false; _G.AutoFruit=false; _G.NoclipActive=false
    if currentTween then pcall(function() currentTween:Cancel() end); currentTween=nil end
    SaveSettings()
    for _,d in pairs(fruitEspObjects) do if d.BB then d.BB:Destroy() end end; fruitEspObjects={}
    ScreenGui:Destroy(); ToastGui:Destroy()
end)

local MinBtn=Instance.new("TextButton")
MinBtn.Size=UDim2.new(0,28,0,28); MinBtn.Position=UDim2.new(1,-66,0,8)
MinBtn.BackgroundColor3=Color3.fromRGB(255,170,0); MinBtn.BorderSizePixel=0
MinBtn.Text="—"; MinBtn.TextColor3=Color3.fromRGB(255,255,255); MinBtn.TextSize=16
MinBtn.Font=Enum.Font.GothamBold; MinBtn.ZIndex=10; MinBtn.Parent=MainFrame
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,8)
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    TweenService:Create(MainFrame,TweenInfo.new(0.3),{Size=minimized and UDim2.new(0,340,0,45) or UDim2.new(0,340,0,540)}):Play()
end)

local TitleBar=Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,45); TitleBar.BackgroundColor3=Color3.fromRGB(20,20,35); TitleBar.BorderSizePixel=0; TitleBar.Parent=MainFrame
local TitleText=Instance.new("TextLabel")
TitleText.Size=UDim2.new(1,-80,1,0); TitleText.Position=UDim2.new(0,15,0,0); TitleText.BackgroundTransparency=1
TitleText.Text="🍎 Fruit Farm v13.1"; TitleText.TextColor3=Color3.fromRGB(255,255,255)
TitleText.TextSize=15; TitleText.Font=Enum.Font.GothamBlack; TitleText.TextXAlignment=Enum.TextXAlignment.Left; TitleText.Parent=TitleBar

local TabFrame=Instance.new("Frame")
TabFrame.Size=UDim2.new(1,0,0,38); TabFrame.Position=UDim2.new(0,0,0,45); TabFrame.BackgroundColor3=Color3.fromRGB(18,18,30)
TabFrame.BorderSizePixel=0; TabFrame.Parent=MainFrame
local TabSlider=Instance.new("Frame")
TabSlider.Size=UDim2.new(0.333,-4,0,3); TabSlider.Position=UDim2.new(0,3,1,-3)
TabSlider.BackgroundColor3=Color3.fromRGB(255,150,50); TabSlider.BorderSizePixel=0; TabSlider.Parent=TabFrame
Instance.new("UICorner",TabSlider).CornerRadius=UDim.new(0,2)

local function MakeTab(name,x)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0.333,-4,1,-4); b.Position=UDim2.new(x,2,0,2)
    b.BackgroundColor3=Color3.fromRGB(25,25,40); b.BorderSizePixel=0; b.Text=name
    b.TextColor3=Color3.fromRGB(150,150,170); b.TextSize=12; b.Font=Enum.Font.GothamBold; b.Parent=TabFrame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6); return b
end
local FruitsTab=MakeTab("Fruits",0); FruitsTab.BackgroundColor3=Color3.fromRGB(35,35,60); FruitsTab.TextColor3=Color3.fromRGB(255,255,255)
local SettingsTab=MakeTab("Settings",0.333); local LogTab=MakeTab("Log",0.666)

local ContentFrame=Instance.new("Frame")
ContentFrame.Size=UDim2.new(1,0,1,-88); ContentFrame.Position=UDim2.new(0,0,0,85); ContentFrame.BackgroundTransparency=1
ContentFrame.ClipsDescendants=true; ContentFrame.Parent=MainFrame

local function MakePage()
    local p=Instance.new("ScrollingFrame"); p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0
    p.ScrollBarThickness=3; p.ScrollBarImageColor3=Color3.fromRGB(80,80,100); p.CanvasSize=UDim2.new(0,0,0,600); p.Parent=ContentFrame
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,5); l.Parent=p
    local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); pad.PaddingTop=UDim.new(0,6); pad.Parent=p
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() p.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10) end)
    return p
end

local FruitsPage=MakePage(); FruitsPage.Position=UDim2.new(0,0,0,0)
local SettingsPage=MakePage(); SettingsPage.Position=UDim2.new(1,0,0,0)
local LogPage=MakePage(); LogPage.Position=UDim2.new(2,0,0,0)

local function SwitchTab(tab)
    if currentTab==tab then return end; currentTab=tab
    local idx=({Fruits=0,Settings=1,Log=2})[tab] or 0
    local cols={Color3.fromRGB(255,150,50),Color3.fromRGB(150,80,255),Color3.fromRGB(255,80,180)}
    local x=idx*0.333
    TweenService:Create(TabSlider,TweenInfo.new(0.3),{Position=UDim2.new(x,3-idx,1,-3),BackgroundColor3=cols[idx+1]}):Play()
    local off=-idx
    TweenService:Create(FruitsPage,TweenInfo.new(0.35),{Position=UDim2.new(off,0,0,0)}):Play()
    TweenService:Create(SettingsPage,TweenInfo.new(0.35),{Position=UDim2.new(1+off,0,0,0)}):Play()
    TweenService:Create(LogPage,TweenInfo.new(0.35),{Position=UDim2.new(2+off,0,0,0)}):Play()
    local tabs={FruitsTab,SettingsTab,LogTab}
    for i,t in pairs(tabs) do local a=i==idx+1
        TweenService:Create(t,TweenInfo.new(0.2),{BackgroundColor3=a and Color3.fromRGB(35,35,60) or Color3.fromRGB(25,25,40),TextColor3=a and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,170)}):Play()
    end
end
FruitsTab.MouseButton1Click:Connect(function() SwitchTab("Fruits") end)
SettingsTab.MouseButton1Click:Connect(function() SwitchTab("Settings") end)
LogTab.MouseButton1Click:Connect(function() SwitchTab("Log") end)

-- ==================== UI ELEMENTS ====================
local function AddSection(p,n)
    local s=Instance.new("Frame"); s.Size=UDim2.new(1,0,0,28); s.BackgroundColor3=Color3.fromRGB(35,35,55); s.BorderSizePixel=0; s.Parent=p
    Instance.new("UICorner",s).CornerRadius=UDim.new(0,5)
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-10,1,0); t.Position=UDim2.new(0,10,0,0); t.BackgroundTransparency=1
    t.Text=n; t.TextColor3=Color3.fromRGB(200,200,230); t.TextSize=12; t.Font=Enum.Font.GothamBold; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=s
end

local function AddToggle(p,n,d,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,38); f.BackgroundColor3=Color3.fromRGB(25,25,40); f.BorderSizePixel=0; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local txt=Instance.new("TextLabel"); txt.Size=UDim2.new(0.6,-10,1,0); txt.Position=UDim2.new(0,10,0,0); txt.BackgroundTransparency=1
    txt.Text=n; txt.TextColor3=Color3.fromRGB(230,230,240); txt.TextSize=12; txt.Font=Enum.Font.Gotham; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=f
    local btn=Instance.new("Frame"); btn.Size=UDim2.new(0,44,0,22); btn.Position=UDim2.new(1,-52,0.5,-11)
    btn.BackgroundColor3=d and Color3.fromRGB(0,180,90) or Color3.fromRGB(60,60,80); btn.BorderSizePixel=0; btn.Parent=f
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,18,0,18); dot.Position=d and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
    dot.BackgroundColor3=Color3.fromRGB(255,255,255); dot.BorderSizePixel=0; dot.Parent=btn; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local on=d
    local function up()
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=on and Color3.fromRGB(0,180,90) or Color3.fromRGB(60,60,80)}):Play()
        TweenService:Create(dot,TweenInfo.new(0.2),{Position=on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
    end
    f.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then on=not on; up(); pcall(cb,on) end end)
end

local function AddLabel(p,t)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.BackgroundColor3=Color3.fromRGB(25,25,40); f.BorderSizePixel=0; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local d=Instance.new("Frame"); d.Size=UDim2.new(0,7,0,7); d.Position=UDim2.new(0,8,0.5,-3); d.BackgroundColor3=Color3.fromRGB(0,255,100); d.BorderSizePixel=0; d.Parent=f
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-22,1,0); l.Position=UDim2.new(0,18,0,0); l.BackgroundTransparency=1
    l.Text=t; l.TextColor3=Color3.fromRGB(200,200,220); l.TextSize=11; l.Font=Enum.Font.Gotham; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=f
    return l
end

local function AddButton(p,t,col,cb)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,38); b.BackgroundColor3=col or Color3.fromRGB(50,50,80); b.BorderSizePixel=0
    b.Text=t; b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=13; b.Font=Enum.Font.GothamBold; b.Parent=p
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5); b.MouseButton1Click:Connect(cb)
end

local function AddSlider(p, labelText, minV, maxV, initV, cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,52); f.BackgroundColor3=Color3.fromRGB(25,25,40); f.BorderSizePixel=0; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-20,0,20); lbl.Position=UDim2.new(0,10,0,4); lbl.BackgroundTransparency=1
    lbl.Text=labelText.."  ("..initV..")"; lbl.TextColor3=Color3.fromRGB(230,230,240); lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=f

    local track=Instance.new("Frame"); track.Size=UDim2.new(1,-20,0,6); track.Position=UDim2.new(0,10,0,34)
    track.BackgroundColor3=Color3.fromRGB(50,50,70); track.BorderSizePixel=0; track.Parent=f
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame"); fill.Size=UDim2.new((initV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(255,150,50); fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16)
    knob.Position=UDim2.new((initV-minV)/(maxV-minV),-8,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local dragging=false
    local function updateFromX(mx)
        local abs=track.AbsolutePosition.X
        local w=track.AbsoluteSize.X
        local rel=math.clamp((mx-abs)/w,0,1)
        local val=math.floor(minV + rel*(maxV-minV) + 0.5)
        fill.Size=UDim2.new(rel,0,1,0)
        knob.Position=UDim2.new(rel,-8,0.5,-8)
        lbl.Text=labelText.."  ("..val..")"
        pcall(cb,val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; updateFromX(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

local statusLabel, fruitLabel, notifyLabel, seaLabel
local function SetStatus(t) if statusLabel then statusLabel.Text=t end end
local function SetFruit(t) if fruitLabel then fruitLabel.Text=t end end
local function SetNotify(t) if notifyLabel then notifyLabel.Text=t end end

-- ==================== UI AUFBAU ====================
AddSection(FruitsPage,"🍎 Fruit Farm")
AddToggle(FruitsPage,"Fruit ESP",_G.FruitESP,function(v)
    _G.FruitESP=v; SaveSettings()
    if not v then for _,d in pairs(fruitEspObjects) do if d.BB then d.BB:Destroy() end end; fruitEspObjects={} end
end)
AddToggle(FruitsPage,"Auto Collect Fruit (Tween)",_G.AutoFruit,function(v) _G.AutoFruit=v; SaveSettings() end)
AddToggle(FruitsPage,"Fruit Spawn Notify (Toast + Island)",_G.FruitNotify,function(v) _G.FruitNotify=v; SaveSettings() end)

AddSection(FruitsPage,"⚙️ Tween Geschwindigkeit (Auto Collect)")
AddSlider(FruitsPage,"Tween Speed",150,300,_G.TweenSpeed,function(v) _G.TweenSpeed=v; SaveSettings() end)

AddSection(FruitsPage,"🎯 Manueller Fruit TP (Teleport)")
AddButton(FruitsPage,"➡️ Teleport zur nächsten Fruit (und zurück)",Color3.fromRGB(0,150,120),function()
    if manualBusy then SetStatus("Schon aktiv...") return end
    task.spawn(function()
        manualBusy=true
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not r then manualBusy=false; return end
        local savedCFrame = r.CFrame
        SetStatus("Position gemerkt, suche Fruit...")
        local fruits=GetFruits()
        if #fruits==0 then SetStatus("Keine Fruit gefunden"); manualBusy=false; return end
        local myPos=r.Position
        local best,bestD=nil,math.huge
        for _,f in pairs(fruits) do
            local h=f:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then
                local d=(h.Position-myPos).Magnitude
                if d<bestD then bestD=d; best=f end
            end
        end
        if not best then SetStatus("Keine Fruit gefunden"); manualBusy=false; return end
        local h=best:FindFirstChild("Handle")
        local island = GetNearestIsland(h.Position)
        SetStatus("TP zu "..best.Name.." ("..island..")...")
        r.CFrame = CFrame.new(h.Position - Vector3.new(0,5,0))
        task.wait(0.3)
        if best and best.Parent then
            local fruitName=string.gsub(best.Name," Fruit","")
            fruitName=fruitName.."-"..fruitName
            pcall(function()
                local tool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit",fruitName,tool)
            end)
            SetStatus("Collected: "..best.Name.." @ "..island)
            task.wait(0.3)
        end
        SetStatus("Teleport zurück...")
        local r2=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r2 then r2.CFrame = savedCFrame end
        SetStatus("Zurück! ✔")
        manualBusy=false
    end)
end)

AddSection(FruitsPage,"📊 Status")
statusLabel=AddLabel(FruitsPage,"Status: Idle")
fruitLabel=AddLabel(FruitsPage,"Fruits: 0")
seaLabel=AddLabel(FruitsPage,"Sea: ...")

-- SETTINGS TAB
AddSection(SettingsPage,"ℹ️ Info")
AddLabel(SettingsPage,"Fruit Farm v13.1")

AddSection(SettingsPage,"🌊 Sea Auswahl (manuell)")
AddButton(SettingsPage,"Set Sea 1 (First)",Color3.fromRGB(100,100,160),function()
    _G.ManualSea=1; SaveSettings(); SetStatus("Sea: Manual First Sea")
end)
AddButton(SettingsPage,"Set Sea 2 (Second)",Color3.fromRGB(60,120,180),function()
    _G.ManualSea=2; SaveSettings(); SetStatus("Sea: Manual Second Sea")
end)
AddButton(SettingsPage,"Set Sea 3 (Third)",Color3.fromRGB(60,160,120),function()
    _G.ManualSea=3; SaveSettings(); SetStatus("Sea: Manual Third Sea")
end)
AddButton(SettingsPage,"Auto Detect (Manual aus)",Color3.fromRGB(120,80,160),function()
    _G.ManualSea=0; SaveSettings(); SetStatus("Sea: Auto Detect")
end)

AddSection(SettingsPage,"🔍 Debug")
AddButton(SettingsPage,"Print Sea-Objekte",Color3.fromRGB(80,80,80),function()
    print("=== ReplicatedStorage Sea-Kandidaten ===")
    for _,c in ipairs(ReplicatedStorage:GetChildren()) do
        local n = c.Name
        if string.find(string.lower(n), "sea") or string.find(string.lower(n), "world") or string.find(string.lower(n), "island") then
            local val = "?"
            pcall(function() val = tostring(c.Value) end)
            print(" - "..n.." ["..c.ClassName.."] Value="..val)
        end
    end
    print("=== Player Attributes ===")
    for k,v in pairs(LP:GetAttributes()) do print(" - "..k.." = "..tostring(v)) end
    print("=== Workspace Sea-Marker ===")
    for _,c in ipairs(workspace:GetChildren()) do
        local n = c.Name
        if string.find(string.lower(n), "sea") or string.find(string.lower(n), "island") then
            print(" - "..n.." ["..c.ClassName.."]")
        end
    end
end)
AddButton(SettingsPage,"Auto-Detect testen",Color3.fromRGB(80,120,200),function()
    local s, m = GetAutoSea()
    SetStatus("Auto Sea: "..s.." via "..m)
    print("Auto Sea = "..s.." (Methode: "..m..")")
end)

AddToggle(SettingsPage,"Noclip",_G.NoclipActive,function(v)
    _G.NoclipActive=v; SaveSettings()
    if not v and LP.Character then DisableNoclip(LP.Character) elseif v and LP.Character then EnableNoclip(LP.Character) end
end)
AddButton(SettingsPage,"💾 Save Settings",Color3.fromRGB(50,180,50),function() SaveSettings() end)
AddButton(SettingsPage,"🗑️ Unload",Color3.fromRGB(255,60,60),function()
    _G.FruitESP=false; _G.AutoFruit=false; _G.NoclipActive=false
    if currentTween then pcall(function() currentTween:Cancel() end); currentTween=nil end; SaveSettings()
    for _,d in pairs(fruitEspObjects) do if d.BB then d.BB:Destroy() end end; fruitEspObjects={}
    ScreenGui:Destroy(); ToastGui:Destroy()
end)

-- LOG TAB
AddSection(LogPage,"🔔 Fruit Spawn Log")
notifyLabel=AddLabel(LogPage,"Warte auf Fruits...")
AddSection(LogPage,"📜 Verlauf")
local logContainer = Instance.new("Frame")
logContainer.Size = UDim2.new(1,0,0,400); logContainer.BackgroundColor3 = Color3.fromRGB(20,20,32)
logContainer.BorderSizePixel = 0; logContainer.Parent = LogPage
Instance.new("UICorner",logContainer).CornerRadius = UDim.new(0,5)
local logLayout = Instance.new("UIListLayout"); logLayout.Padding = UDim.new(0,3); logLayout.Parent = logContainer
local logPad = Instance.new("UIPadding"); logPad.PaddingLeft=UDim.new(0,6); logPad.PaddingTop=UDim.new(0,6); logPad.Parent = logContainer
logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    logContainer.Size = UDim2.new(1,0,0,math.max(80, logLayout.AbsoluteContentSize.Y+12))
end)

local function AddLogEntry(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-12,0,22); l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = Color3.fromRGB(255,200,120); l.TextSize = 11
    l.Font = Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = logContainer
end

-- ==================== FRUIT ESP ====================
local function CreateFruitESP(f)
    if not f or fruitEspObjects[f] then return end
    local h=f:FindFirstChild("Handle"); if not h or not h:IsA("BasePart") then return end
    pcall(function()
        local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,240,0,32); bb.Adornee=h; bb.AlwaysOnTop=true; bb.StudsOffset=Vector3.new(0,2,0); bb.Parent=h
        local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.5; bg.BorderSizePixel=0; bg.Parent=bb
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,4)
        local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
        l.Text=f.Name; l.TextColor3=Color3.fromRGB(255,100,100); l.TextScaled=true; l.Font=Enum.Font.GothamBold; l.Parent=bb
        fruitEspObjects[f]={BB=bb,Lbl=l}
    end)
end

local function UpdateFruitESP()
    local h=LP.Character and LP.Character:FindFirstChild("Head"); if not h then return end
    local p=h.Position
    local activeFruits=GetFruits()
    local activeSet={}
    for _,f in pairs(activeFruits) do activeSet[f]=true end
    for f,e in pairs(fruitEspObjects) do
        if not activeSet[f] then
            if e.BB then e.BB:Destroy() end; fruitEspObjects[f]=nil
        end
    end
    for _,f in pairs(activeFruits) do
        if _G.FruitESP then
            if not fruitEspObjects[f] then CreateFruitESP(f) end
            local e=fruitEspObjects[f]
            local hd=f:FindFirstChild("Handle")
            if e and e.Lbl and hd then
                local d=math.floor((p-hd.Position).Magnitude/3+0.5)
                local island = GetNearestIsland(hd.Position)
                e.Lbl.Text=f.Name.." ("..d.."m) | "..island
            end
        end
    end
end

-- ==================== FRUIT SPAWN NOTIFY ====================
local function NotifyFruit(fruit)
    if not _G.FruitNotify then return end
    local name=fruit.Name
    local t=os.date("%H:%M:%S")

    local pos = nil
    local h = fruit:FindFirstChild("Handle")
    if h and h:IsA("BasePart") then pos = h.Position end

    local island = "Unbekannt"
    if pos then island = GetNearestIsland(pos) end

    local seaNum, _ = GetCurrentSea()
    local seaTag = (seaNum == 2 and "2nd Sea") or (seaNum == 3 and "3rd Sea") or (seaNum == 1 and "1st Sea") or "Unknown"
    local entry = "["..t.."] "..name.." spawned near "..island.." ("..seaTag..")"

    table.insert(notifyLog,1,entry)
    if #notifyLog>30 then table.remove(notifyLog) end
    SetNotify(entry)
    AddLogEntry(entry)

    ShowToast("Fruit spawned!", name, Color3.fromRGB(255, 150, 50), "📍 near "..island)
    print("🔔 "..entry)
end

task.spawn(function()
    while task.wait(1) do
        if _G.FruitNotify then
            local current=GetFruits()
            for _,f in pairs(current) do
                if not knownFruits[f] then
                    knownFruits[f]=true
                    NotifyFruit(f)
                end
            end
            local activeSet={}
            for _,f in pairs(current) do activeSet[f]=true end
            for f in pairs(knownFruits) do
                if not activeSet[f] and not f.Parent then knownFruits[f]=nil end
            end
        end
    end
end)

-- ==================== SEA-DETECTION LOOP ====================
task.spawn(function()
    while task.wait(2) do
        local sea, method = GetCurrentSea()
        if seaLabel then
            seaLabel.Text = "Sea: "..GetSeaLabel().."  ["..method.."]"
        end
    end
end)

-- ==================== MAIN ESP LOOP ====================
task.spawn(function()
    while task.wait(0.3) do
        if _G.FruitESP then UpdateFruitESP(); SetFruit("Fruits: "..#GetFruits()) end
    end
end)

-- ==================== AUTO COLLECT FRUIT (TWEEN, KEIN 200-STUDS-LIMIT) ====================
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFruit and not manualBusy then
            pcall(function()
                if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local r = LP.Character.HumanoidRootPart
                local pp = r.Position
                local fruits = GetFruits()
                if #fruits == 0 then return end

                -- Immer die NÄCHSTE Fruit nehmen (egal wie weit weg)
                local best, bestDist = nil, math.huge
                for _, fruit in ipairs(fruits) do
                    local h = fruit:FindFirstChild("Handle")
                    if h and h:IsA("BasePart") then
                        local d = (h.Position - pp).Magnitude
                        if d < bestDist then bestDist = d; best = fruit end
                    end
                end

                if not best then return end
                local h = best:FindFirstChild("Handle")
                if not h then return end

                isFarmingFruit = true
                local island = GetNearestIsland(h.Position)
                SetStatus("Tweening to "..best.Name.." @ "..island.." ("..math.floor(bestDist).."m)")

                local dur = math.max(bestDist / _G.TweenSpeed, 0.2)
                local t = TweenService:Create(r, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(h.Position - Vector3.new(0,5,0))})
                t:Play(); t.Completed:Wait()
                task.wait(0.3)

                if best and best.Parent then
                    local fruitName = string.gsub(best.Name, " Fruit", "")
                    fruitName = fruitName.."-"..fruitName
                    pcall(function()
                        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
                    end)
                    SetStatus("Collected: "..best.Name.." @ "..island)
                    task.wait(0.3)
                end
                isFarmingFruit = false
            end)
        end
    end
end)

-- ==================== INIT ====================
task.wait(1)
SetFruit("Fruits: "..#GetFruits())
SetNotify("Warte auf Fruits...")

task.spawn(function()
    local sea, method = GetCurrentSea()
    if seaLabel then
        seaLabel.Text = "Sea: "..GetSeaLabel().."  ["..method.."]"
    end
    local seaName = (sea == 2 and "2nd Sea") or (sea == 3 and "3rd Sea") or (sea == 1 and "1st Sea") or "Unknown Sea"
    ShowToast("Fruit Farm bereit", seaName.." ("..method..")", Color3.fromRGB(0, 200, 100))
    print("✅ Fruit Farm v13.1 loaded! Sea "..sea.." ("..seaName..") via "..method)
    if _G.ManualSea == 0 then
        print("💡 Tipp: Wenn Sea falsch erkannt wird, öffne Settings → Set Sea 2 / 3")
    end
end)
