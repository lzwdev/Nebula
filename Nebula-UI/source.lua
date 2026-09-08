-- =====================================================================
-- 🌟 NEBULA UI LIBRARY v1.0
-- Modern, Smooth, Bug-Free UI Library
-- =====================================================================

local Nebula = {}
Nebula.__index = Nebula

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Settings
local Settings = {
    AnimationSpeed = 0.16,
    CornerRadius = 10,
    AccentColor = Color3.fromRGB(151, 79, 255),
    AccentHover = Color3.fromRGB(172, 114, 255),
    AccentGlow = Color3.fromRGB(201, 155, 255),
    DarkColor = Color3.fromRGB(12, 8, 20),
    DarkerColor = Color3.fromRGB(18, 12, 30),
    LighterColor = Color3.fromRGB(32, 21, 52),
    Surface2 = Color3.fromRGB(24, 16, 40),
    TextColor = Color3.fromRGB(239, 242, 248),
    DimTextColor = Color3.fromRGB(185, 170, 214),
    BorderColor = Color3.fromRGB(82, 58, 122),
}

-- =====================================================================
-- UTILITY FUNCTIONS
-- =====================================================================
local function Create(className, properties)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        pcall(function() obj[prop] = value end)
    end
    return obj
end

local function Tween(obj, props, duration, easing, direction)
    duration = duration or Settings.AnimationSpeed
    easing = easing or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easing, direction), props)
    tween:Play()
    return tween
end

local function LerpColor(colorA, colorB, alpha)
    alpha = math.clamp(alpha or 0, 0, 1)
    return Color3.new(
        colorA.R + (colorB.R - colorA.R) * alpha,
        colorA.G + (colorB.G - colorA.G) * alpha,
        colorA.B + (colorB.B - colorA.B) * alpha
    )
end

local function AddCorner(obj, radius)
    radius = radius or Settings.CornerRadius
    local corner = Create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = obj})
    return corner
end

local function AddStroke(obj, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Color = color or Settings.AccentColor,
        Thickness = thickness or 1,
        Transparency = transparency or 0.82,
        Parent = obj
    })
    return stroke
end

local function ResolvePage(tab)
    if typeof(tab) == "Instance" then
        return tab
    end
    if type(tab) == "table" and tab.Page then
        return tab.Page
    end
    return tab
end

local function ShowLoadingScreen(config)
    local steps = config.Steps or {"Initializing UI...", "Loading components...", "Applying theme...", "Ready!"}
    local duration = config.Duration or 3
    local callback = config.Callback or function() end

    local SG = Create("ScreenGui", {
        Name = "NebulaLoading",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local bg = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    })

    local box = Create("Frame", {
        Parent = bg,
        BackgroundColor3 = Settings.DarkColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -160, 0.5, -70),
        Size = UDim2.new(0, 320, 0, 140),
    })
    AddCorner(box, 14)
    AddStroke(box, Settings.BorderColor, 1, 0.22)

    local title = Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 14),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Nebula UI",
        TextColor3 = Settings.AccentColor,
        TextSize = 18,
    })

    local stepLabel = Create("TextLabel", {
        Parent = box,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = steps[1],
        TextColor3 = Settings.DimTextColor,
        TextSize = 11,
    })

    local barBg = Create("Frame", {
        Parent = box,
        BackgroundColor3 = Settings.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 32, 0, 82),
        Size = UDim2.new(1, -64, 0, 8),
    })
    AddCorner(barBg, 4)

    local barFill = Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    })
    AddCorner(barFill, 4)

    Tween(bg, {BackgroundTransparency = 0.55}, 0.22)
    local stepTime = duration / math.max(#steps, 1)
    for i = 1, #steps do
        task.delay((i - 1) * stepTime, function()
            stepLabel.Text = steps[i]
            Tween(barFill, {Size = UDim2.new(i / #steps, 0, 1, 0)}, stepTime * 0.8)
        end)
    end

    task.delay(duration, function()
        Tween(bg, {BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        SG:Destroy()
        callback()
    end)
end

-- =====================================================================
-- DRAG SYSTEM
-- =====================================================================
local function MakeDraggable(frame, dragBar)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    dragBar = dragBar or frame
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =====================================================================
-- WINDOW CLASS
-- =====================================================================
function Nebula.CreateWindow(config)
    config = config or {}
    local title = config.Title or "Nebula UI"
    local showLoading = config.ShowLoading == true

    if CoreGui:FindFirstChild("NebulaUI") then
        CoreGui.NebulaUI:Destroy()
    end

    if showLoading then
        ShowLoadingScreen({
            Title = title,
            Steps = config.LoadingSteps or {"Initializing UI...", "Loading components...", "Applying theme...", "Ready!"},
            Duration = config.LoadingDuration or 3,
        })
    end

    local window = {}
    setmetatable(window, Nebula)

    local SG = Create("ScreenGui", {
        Name = "NebulaUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local Main = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = Settings.DarkColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        Active = true,
        ClipsDescendants = true,
    })
    AddCorner(Main, 12)
    AddStroke(Main, Settings.BorderColor, 1, 0.82)

    local Shadow = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -273, 0.5, -198),
        Size = UDim2.new(0, 550, 0, 400),
        ZIndex = -1,
    })
    AddCorner(Shadow, 12)

    local TitleBar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2,
    })
    AddCorner(TitleBar, 12)
    AddStroke(TitleBar, Settings.BorderColor, 1, 0.9)

    local TitleAccent = Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Settings.AccentGlow,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(TitleAccent, 4)

    local TitleMark = Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, -8),
        Size = UDim2.new(0, 4, 0, 16),
        ZIndex = 4,
    })
    AddCorner(TitleMark, 4)

    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Settings.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })

    local minimized = false

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -34, 0, 8),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    AddCorner(CloseBtn, 6)
    CloseBtn.MouseButton1Click:Connect(function() window:Destroy() end)

    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0, 8),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    AddCorner(MinBtn, 6)
    MinBtn.MouseButton1Click:Connect(function() window:Minimize() end)

    MakeDraggable(Main, TitleBar)
    MakeDraggable(Shadow, TitleBar)

    local TabContainer = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        ZIndex = 1,
    })
    AddStroke(TabContainer, Settings.BorderColor, 1, 0.9)

    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })

    Create("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })

    local ContentArea = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 42),
        Size = UDim2.new(1, -140, 1, -42),
        ZIndex = 1,
    })
    AddStroke(ContentArea, Settings.BorderColor, 1, 0.94)

    local PageContainer = Create("Frame", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
    })

    window.SG = SG
    window.Main = Main
    window.Shadow = Shadow
    window.TitleBar = TitleBar
    window.TabContainer = TabContainer
    window.PageContainer = PageContainer
    window.Tabs = {}
    window.Pages = {}
    window.currentTab = nil
    window.Minimized = false

    function window:Destroy()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(Shadow, {Size = UDim2.new(0, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.15)
        if SG and SG.Parent then
            SG:Destroy()
        end
    end

    function window:Minimize()
        self.Minimized = not self.Minimized
        if self.Minimized then
            Tween(Main, {Size = UDim2.new(0, 550, 0, 42)}, 0.22)
            Tween(Shadow, {Size = UDim2.new(0, 550, 0, 42)}, 0.22)
            MinBtn.Text = "+"
        else
            Tween(Main, {Size = UDim2.new(0, 550, 0, 400)}, 0.22)
            Tween(Shadow, {Size = UDim2.new(0, 550, 0, 400)}, 0.22)
            MinBtn.Text = "−"
        end
    end

    function window:Notify(notifyConfig)
        Nebula.Notify(self, notifyConfig)
    end

    Main.Size = UDim2.new(0, 0, 0, 0)
    Shadow.Size = UDim2.new(0, 0, 0, 0)
    Tween(Main, {Size = UDim2.new(0, 550, 0, 400)}, 0.32, Enum.EasingStyle.Back)
    Tween(Shadow, {Size = UDim2.new(0, 550, 0, 400)}, 0.32, Enum.EasingStyle.Back)

    return window
end

-- =====================================================================
-- CREATE TAB
-- =====================================================================
function Nebula:CreateTab(name, icon)
    icon = icon or ""
    
    local tabBtn = Create("TextButton", {
        Parent = self.TabContainer,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = icon .. "  " .. name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(tabBtn, 6)
    AddStroke(tabBtn, Settings.BorderColor, 1, 0.88)

    local activeBar = Create("Frame", {
        Parent = tabBtn,
        BackgroundColor3 = Settings.AccentGlow,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 6),
        Size = UDim2.new(0, 3, 1, -12),
        Visible = false,
        ZIndex = 3,
    })
    AddCorner(activeBar, 3)
    
    -- Create page
    local page = Create("ScrollingFrame", {
        Parent = self.PageContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 1,
    })
    
    local pageList = Create("UIListLayout", {
        Parent = page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    
    local pagePad = Create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })
    
    -- Tab click
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do p.Visible = false end
        for _, t in pairs(self.Tabs) do
            Tween(t.Button, {BackgroundColor3 = Settings.LighterColor}, 0.12)
            t.ActiveBar.Visible = false
        end
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = Settings.AccentColor}, 0.12)
        activeBar.Visible = true
        self.currentTab = name
    end)
    
    -- Select first tab
    if #self.Tabs == 0 then
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = Settings.AccentColor}, 0.1)
        activeBar.Visible = true
        self.currentTab = name
    end
    
    table.insert(self.Tabs, {Button = tabBtn, ActiveBar = activeBar})
    table.insert(self.Pages, page)
    
    return {Window = self, Page = page, Name = name, Button = tabBtn, ActiveBar = activeBar}
end

-- =====================================================================
-- SECTIONS
-- =====================================================================
function Nebula:CreateSection(page, name)
    local resolvedPage = ResolvePage(page)
    local sectionName = name
    if type(name) == "table" then
        sectionName = name.Name or ""
    end

    local section = Create("Frame", {
        Parent = resolvedPage,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 1,
    })
    AddCorner(section, 6)
    AddStroke(section, Settings.BorderColor, 1, 0.9)
    
    local accent = Create("Frame", {
        Parent = section,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 2,
    })
    AddCorner(accent, 6)
    
    local label = Create("TextLabel", {
        Parent = section,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = sectionName or "",
        TextColor3 = Settings.AccentHover,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })

    local self = {Page = resolvedPage, Section = section}
    function self:CreateToggle(cfg) return Nebula.CreateToggle(resolvedPage, cfg) end
    function self:CreateButton(cfg) return Nebula.CreateButton(resolvedPage, cfg) end
    function self:CreateSlider(cfg) return Nebula.CreateSlider(resolvedPage, cfg) end
    function self:CreateDropdown(cfg) return Nebula.CreateDropdown(resolvedPage, cfg) end
    function self:CreateLabel(cfg) return Nebula.CreateLabel(resolvedPage, cfg) end
    function self:CreateTextBox(cfg) return Nebula.CreateTextBox(resolvedPage, cfg) end
    function self:CreateKeybind(cfg) return Nebula.CreateKeybind(resolvedPage, cfg) end
    function self:CreateCheckbox(cfg) return Nebula.CreateCheckbox(resolvedPage, cfg) end
    function self:CreateColorPicker(cfg) return Nebula.CreateColorPicker(resolvedPage, cfg) end
    function self:CreateProgressBar(cfg) return Nebula.CreateProgressBar(resolvedPage, cfg) end

    return self
end

-- =====================================================================
-- TOGGLE
-- =====================================================================
function Nebula:CreateToggle(page, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local toggleBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        ZIndex = 2,
    })
    AddCorner(toggleBg, 10)
    
    local toggleDot = Create("Frame", {
        Parent = toggleBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 3,
    })
    AddCorner(toggleDot, 7)
    
    local state = default
    
    local function updateToggle()
        if state then
            Tween(toggleBg, {BackgroundColor3 = Color3.fromRGB(64, 160, 96)}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(1, -17, 0.5, -7)}, 0.15)
        else
            Tween(toggleBg, {BackgroundColor3 = Color3.fromRGB(54, 58, 68)}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(0, 3, 0.5, -7)}, 0.15)
        end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
            callback(state)
        end
    end)
    
    return {Set = function(v) state = v; updateToggle() end, Value = state}
end

-- =====================================================================
-- BUTTON
-- =====================================================================
function Nebula:CreateButton(page, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or Settings.AccentColor
    
    local btn = Create("TextButton", {
        Parent = page,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    AddCorner(btn, 8)
    AddStroke(btn, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = LerpColor(color, Color3.fromRGB(255, 255, 255), 0.08)}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = color}, 0.1)
    end)
    
    -- Click animation
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {Size = UDim2.new(0.985, 0, 0, 31)}, 0.05)
        task.wait(0.05)
        Tween(btn, {Size = UDim2.new(1, 0, 0, 34)}, 0.05)
        callback()
    end)
    
    return btn
end

-- =====================================================================
-- SLIDER
-- =====================================================================
function Nebula:CreateSlider(page, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local suffix = config.Suffix or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = name .. ": " .. default .. suffix,
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local sliderBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(36, 38, 48),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -70, 0, 6),
        ZIndex = 2,
    })
    AddCorner(sliderBg, 3)
    
    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(sliderFill, 3)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(22, 24, 34),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -54, 0, 26),
        Size = UDim2.new(0, 44, 0, 18),
        Font = Enum.Font.Code,
        Text = tostring(default),
        TextColor3 = Color3.fromRGB(200, 255, 200),
        TextSize = 10,
        ZIndex = 2,
    })
    AddCorner(input, 4)
    AddStroke(input, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local function update(val)
        val = math.clamp(tonumber(val) or min, min, max)
        sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        label.Text = name .. ": " .. val .. suffix
        callback(val)
    end
    
    input.FocusLost:Connect(function() update(input.Text) end)
    
    sliderBg.InputBegan:Connect(function(ib)
        if ib.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local perc = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * perc)
                update(val)
                input.Text = tostring(val)
            end)
            UserInputService.InputEnded:Connect(function(ie)
                if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
            end)
        end
    end)
    
    return {Set = update, Value = default}
end

-- =====================================================================
-- DROPDOWN
-- =====================================================================
function Nebula:CreateDropdown(page, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local default = config.Default or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        ClipsDescendants = false,
        ZIndex = 5,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local dropBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(22, 24, 34),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -120, 0.5, -11),
        Size = UDim2.new(0, 110, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = default ~= "" and default or "Select...",
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    AddCorner(dropBtn, 6)
    AddStroke(dropBtn, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local dropList = Create("ScrollingFrame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(18, 20, 29),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -120, 0, 0),
        Size = UDim2.new(0, 110, 0, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 10,
    })
    AddCorner(dropList, 6)
    AddStroke(dropList, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local dropListLayout = Create("UIListLayout", {
        Parent = dropList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })
    
    local function refreshOptions(newOptions)
        for _, child in pairs(dropList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, opt in pairs(newOptions) do
            local optBtn = Create("TextButton", {
                Parent = dropList,
                BackgroundColor3 = Color3.fromRGB(22, 24, 34),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.Gotham,
                Text = opt,
                TextColor3 = Settings.TextColor,
                TextSize = 10,
                AutoButtonColor = false,
                ZIndex = 11,
            })
            AddCorner(optBtn, 4)
            AddStroke(optBtn, Color3.fromRGB(255, 255, 255), 1, 0.95)
            
            optBtn.MouseButton1Click:Connect(function()
                dropBtn.Text = opt
                dropList.Visible = false
                callback(opt)
            end)
            
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(44, 48, 60)}, 0.1)
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(22, 24, 34)}, 0.1)
            end)
        end
    end
    
    refreshOptions(options)
    
    dropBtn.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
        if dropList.Visible then
            dropList.Position = UDim2.new(1, -120, 0, 36)
        end
    end)
    
    return {Refresh = refreshOptions, Value = default}
end

-- =====================================================================
-- LABEL
-- =====================================================================
function Nebula:CreateLabel(page, config)
    config = config or {}
    local text = config.Text or "Label"
    local color = config.Color or Settings.TextColor
    local size = config.Size or 11
    
    local label = Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = color,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = config.Wrap or false,
    })
    
    return label
end

-- =====================================================================
-- TEXTBOX (INPUT)
-- =====================================================================
function Nebula:CreateTextBox(page, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    local default = config.Default or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 22, 31),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
        Text = default,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    AddCorner(input, 6)
    AddStroke(input, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(input.Text)
        end
    end)
    
    return input
end

-- =====================================================================
-- KEYBIND
-- =====================================================================
function Nebula:CreateKeybind(page, config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or "None"
    local callback = config.Callback or function() end
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 180, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local keyBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(22, 24, 34),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -80, 0.5, -10),
        Size = UDim2.new(0, 70, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "[" .. default .. "]",
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(keyBtn, 6)
    AddStroke(keyBtn, Color3.fromRGB(255, 255, 255), 1, 0.94)
    
    local currentKey = default
    local binding = false
    
    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "[...]"
        
        local conn = UserInputService.InputBegan:Connect(function(input)
            if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false
                currentKey = input.KeyCode.Name
                keyBtn.Text = "[" .. currentKey .. "]"
                callback(currentKey)
                conn:Disconnect()
            end
        end)
    end)
    
    return {Set = function(k) currentKey = k; keyBtn.Text = "[" .. k .. "]" end, Value = currentKey}
end

-- =====================================================================
-- CHECKBOX
-- =====================================================================
function Nebula:CreateCheckbox(page, config)
    config = config or {}
    local name = config.Name or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Settings.BorderColor, 1, 0.9)

    local box = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default and Settings.AccentColor or Settings.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = default and "✓" or "",
        TextColor3 = Settings.TextColor,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(box, 4)

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })

    local state = default
    local function update(v)
        state = v
        Tween(box, {BackgroundColor3 = state and Settings.AccentColor or Settings.DarkerColor}, 0.12)
        box.Text = state and "✓" or ""
        callback(state)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update(not state)
        end
    end)

    return {Set = update, Get = function() return state end, Value = state}
end

-- =====================================================================
-- COLOR PICKER
-- =====================================================================
function Nebula:CreateColorPicker(page, config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Settings.AccentColor
    local callback = config.Callback or function() end

    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Settings.BorderColor, 1, 0.9)

    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })

    local preview = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(preview, 10)

    local popup = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 20,
    })
    AddCorner(popup, 8)
    AddStroke(popup, Settings.BorderColor, 1, 0.9)

    local values = {math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)}
    local colors = {"R", "G", "B"}

    local function applyColor()
        local color = Color3.fromRGB(values[1], values[2], values[3])
        preview.BackgroundColor3 = color
        callback(color)
        return color
    end

    for i = 1, 3 do
        local row = Create("Frame", {
            Parent = popup,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
        })

        Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(0, 16, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = colors[i],
            TextColor3 = Settings.TextColor,
            TextSize = 10,
            ZIndex = 21,
        })

        local bg = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Settings.Surface2,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 28, 0.5, -3),
            Size = UDim2.new(1, -74, 0, 6),
            ZIndex = 21,
        })
        AddCorner(bg, 3)

        local fill = Create("Frame", {
            Parent = bg,
            BackgroundColor3 = Settings.AccentGlow,
            BorderSizePixel = 0,
            Size = UDim2.new(values[i] / 255, 0, 1, 0),
            ZIndex = 22,
        })
        AddCorner(fill, 3)

        local input = Create("TextBox", {
            Parent = row,
            BackgroundColor3 = Settings.DarkerColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -40, 0.5, -8),
            Size = UDim2.new(0, 34, 0, 16),
            Font = Enum.Font.Code,
            Text = tostring(values[i]),
            TextColor3 = Settings.TextColor,
            TextSize = 9,
            ZIndex = 21,
        })
        AddCorner(input, 4)

        bg.InputBegan:Connect(function(ib)
            if ib.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn = RunService.RenderStepped:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    local perc = math.clamp((mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    values[i] = math.floor(perc * 255)
                    fill.Size = UDim2.new(perc, 0, 1, 0)
                    input.Text = tostring(values[i])
                    applyColor()
                end)
                UserInputService.InputEnded:Connect(function(ie)
                    if ie.UserInputType == Enum.UserInputType.MouseButton1 then
                        conn:Disconnect()
                    end
                end)
            end
        end)

        input.FocusLost:Connect(function()
            values[i] = math.clamp(tonumber(input.Text) or 0, 0, 255)
            fill.Size = UDim2.new(values[i] / 255, 0, 1, 0)
            applyColor()
        end)
    end

    preview.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
        if popup.Visible then
            Tween(popup, {Size = UDim2.new(1, 0, 0, 75)}, 0.18, Enum.EasingStyle.Sine)
        else
            Tween(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        end
    end)

    applyColor()
    return {Set = function(c) preview.BackgroundColor3 = c; callback(c) end, Get = function() return preview.BackgroundColor3 end, Value = preview.BackgroundColor3}
end

-- =====================================================================
-- PROGRESS BAR
-- =====================================================================
function Nebula:CreateProgressBar(page, config)
    config = config or {}
    local value = config.Value or 0
    local max = config.Max or 100

    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    AddStroke(frame, Settings.BorderColor, 1, 0.9)

    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 2),
        Size = UDim2.new(1, -24, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = (config.Name or "Progress") .. ": " .. math.floor((value / max) * 100) .. "%",
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })

    local bg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Settings.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 20),
        Size = UDim2.new(1, -24, 0, 10),
        ZIndex = 2,
    })
    AddCorner(bg, 5)

    local fill = Create("Frame", {
        Parent = bg,
        BackgroundColor3 = config.Color or Settings.AccentGlow,
        BorderSizePixel = 0,
        Size = UDim2.new(value / max, 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(fill, 5)

    return {
        Set = function(v)
            value = math.clamp(v, 0, max)
            Tween(fill, {Size = UDim2.new(value / max, 0, 1, 0)}, 0.22)
            label.Text = (config.Name or "Progress") .. ": " .. math.floor((value / max) * 100) .. "%"
        end,
        Get = function() return value end,
        Value = value,
    }
end

-- =====================================================================
-- NOTIFICATION
-- =====================================================================
function Nebula:Notify(config)
    config = config or {}
    local title = config.Title or "Nebula"
    local content = config.Content or ""
    local duration = config.Duration or 4
    
    local notif = Create("Frame", {
        Parent = self.SG,
        BackgroundColor3 = Settings.DarkColor,
        BorderColor3 = Settings.AccentColor,
        BorderSizePixel = 1,
        Position = UDim2.new(1, 0, 0.8, 0),
        Size = UDim2.new(0, 280, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        ClipsDescendants = true,
        ZIndex = 100,
    })
    AddCorner(notif, 10)
    AddStroke(notif, Color3.fromRGB(255, 255, 255), 1, 0.92)
    
    local titleLabel = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Settings.AccentColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    
    local contentLabel = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.Gotham,
        Text = content,
        TextColor3 = Settings.DimTextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    
    -- Animate in
    notif.Size = UDim2.new(0, 0, 0, 0)
    Tween(notif, {Position = UDim2.new(1, -10, 0.8, -50), Size = UDim2.new(0, 280, 0, 50)}, 0.3, Enum.EasingStyle.Back)
    
    -- Animate out
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 0, 0.8, 0), Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.2)
        notif:Destroy()
    end)
end

return Nebula
