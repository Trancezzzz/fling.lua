--[[
    FE Fling Script GUI
    Author: Scripter
    Description: Modern GUI interface for the FE Fling Script
    
    Features:
    - Player selection with search
    - Method selection buttons
    - Power slider
    - Visual feedback
    - Hotkey support
    - Target highlighting
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Load the main fling script if not already loaded
if not _G.FEFling then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/fe-fling-script.lua"))()
end

-- GUI Configuration
local GUIConfig = {
    Theme = {
        Primary = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 162, 255),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Danger = Color3.fromRGB(231, 76, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200)
    },
    Animations = {
        Duration = 0.3,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out
    }
}

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FEFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try to parent to CoreGui, fallback to PlayerGui
local success = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = GUIConfig.Theme.Primary
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Add corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Add drop shadow effect
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 6, 1, 6)
Shadow.Position = UDim2.new(0, -3, 0, -3)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.8
Shadow.BorderSizePixel = 0
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = Shadow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = GUIConfig.Theme.Accent
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Fix corner for title bar
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = GUIConfig.Theme.Accent
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "FE Fling Script v2.0"
TitleText.TextColor3 = GUIConfig.Theme.Text
TitleText.TextScaled = true
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = GUIConfig.Theme.Danger
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = GUIConfig.Theme.Text
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = GUIConfig.Theme.Warning
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = GUIConfig.Theme.Text
MinimizeButton.TextScaled = true
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Player Selection Section
local PlayerSection = Instance.new("Frame")
PlayerSection.Name = "PlayerSection"
PlayerSection.Size = UDim2.new(1, 0, 0, 120)
PlayerSection.BackgroundColor3 = GUIConfig.Theme.Secondary
PlayerSection.BorderSizePixel = 0
PlayerSection.Parent = ContentFrame

local PlayerSectionCorner = Instance.new("UICorner")
PlayerSectionCorner.CornerRadius = UDim.new(0, 8)
PlayerSectionCorner.Parent = PlayerSection

-- Player Section Title
local PlayerTitle = Instance.new("TextLabel")
PlayerTitle.Name = "PlayerTitle"
PlayerTitle.Size = UDim2.new(1, -20, 0, 30)
PlayerTitle.Position = UDim2.new(0, 10, 0, 5)
PlayerTitle.BackgroundTransparency = 1
PlayerTitle.Text = "Target Selection"
PlayerTitle.TextColor3 = GUIConfig.Theme.Text
PlayerTitle.TextScaled = true
PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left
PlayerTitle.Font = Enum.Font.GothamBold
PlayerTitle.Parent = PlayerSection

-- Player Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -20, 0, 25)
SearchBox.Position = UDim2.new(0, 10, 0, 35)
SearchBox.BackgroundColor3 = GUIConfig.Theme.Primary
SearchBox.BorderSizePixel = 0
SearchBox.Text = "Search players..."
SearchBox.TextColor3 = GUIConfig.Theme.TextSecondary
SearchBox.TextScaled = true
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = PlayerSection

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBox

-- Player List
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Name = "PlayerList"
PlayerList.Size = UDim2.new(1, -20, 0, 50)
PlayerList.Position = UDim2.new(0, 10, 0, 65)
PlayerList.BackgroundColor3 = GUIConfig.Theme.Primary
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = GUIConfig.Theme.Accent
PlayerList.Parent = PlayerSection

local PlayerListCorner = Instance.new("UICorner")
PlayerListCorner.CornerRadius = UDim.new(0, 4)
PlayerListCorner.Parent = PlayerList

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.FillDirection = Enum.FillDirection.Horizontal
PlayerListLayout.Padding = UDim.new(0, 5)
PlayerListLayout.Parent = PlayerList

-- Method Selection Section
local MethodSection = Instance.new("Frame")
MethodSection.Name = "MethodSection"
MethodSection.Size = UDim2.new(1, 0, 0, 100)
MethodSection.Position = UDim2.new(0, 0, 0, 130)
MethodSection.BackgroundColor3 = GUIConfig.Theme.Secondary
MethodSection.BorderSizePixel = 0
MethodSection.Parent = ContentFrame

local MethodSectionCorner = Instance.new("UICorner")
MethodSectionCorner.CornerRadius = UDim.new(0, 8)
MethodSectionCorner.Parent = MethodSection

-- Method Section Title
local MethodTitle = Instance.new("TextLabel")
MethodTitle.Name = "MethodTitle"
MethodTitle.Size = UDim2.new(1, -20, 0, 25)
MethodTitle.Position = UDim2.new(0, 10, 0, 5)
MethodTitle.BackgroundTransparency = 1
MethodTitle.Text = "Fling Method"
MethodTitle.TextColor3 = GUIConfig.Theme.Text
MethodTitle.TextScaled = true
MethodTitle.TextXAlignment = Enum.TextXAlignment.Left
MethodTitle.Font = Enum.Font.GothamBold
MethodTitle.Parent = MethodSection

-- Method Buttons Container
local MethodButtons = Instance.new("Frame")
MethodButtons.Name = "MethodButtons"
MethodButtons.Size = UDim2.new(1, -20, 0, 60)
MethodButtons.Position = UDim2.new(0, 10, 0, 30)
MethodButtons.BackgroundTransparency = 1
MethodButtons.Parent = MethodSection

local MethodButtonsLayout = Instance.new("UIGridLayout")
MethodButtonsLayout.CellSize = UDim2.new(0.48, 0, 0.45, 0)
MethodButtonsLayout.CellPadding = UDim2.new(0.02, 0, 0.1, 0)
MethodButtonsLayout.Parent = MethodButtons

-- Power Control Section
local PowerSection = Instance.new("Frame")
PowerSection.Name = "PowerSection"
PowerSection.Size = UDim2.new(1, 0, 0, 80)
PowerSection.Position = UDim2.new(0, 0, 0, 240)
PowerSection.BackgroundColor3 = GUIConfig.Theme.Secondary
PowerSection.BorderSizePixel = 0
PowerSection.Parent = ContentFrame

local PowerSectionCorner = Instance.new("UICorner")
PowerSectionCorner.CornerRadius = UDim.new(0, 8)
PowerSectionCorner.Parent = PowerSection

-- Power Section Title
local PowerTitle = Instance.new("TextLabel")
PowerTitle.Name = "PowerTitle"
PowerTitle.Size = UDim2.new(0.7, 0, 0, 25)
PowerTitle.Position = UDim2.new(0, 10, 0, 5)
PowerTitle.BackgroundTransparency = 1
PowerTitle.Text = "Fling Power: 50000"
PowerTitle.TextColor3 = GUIConfig.Theme.Text
PowerTitle.TextScaled = true
PowerTitle.TextXAlignment = Enum.TextXAlignment.Left
PowerTitle.Font = Enum.Font.GothamBold
PowerTitle.Parent = PowerSection

-- Power Slider
local PowerSlider = Instance.new("Frame")
PowerSlider.Name = "PowerSlider"
PowerSlider.Size = UDim2.new(1, -20, 0, 20)
PowerSlider.Position = UDim2.new(0, 10, 0, 35)
PowerSlider.BackgroundColor3 = GUIConfig.Theme.Primary
PowerSlider.BorderSizePixel = 0
PowerSlider.Parent = PowerSection

local PowerSliderCorner = Instance.new("UICorner")
PowerSliderCorner.CornerRadius = UDim.new(0, 10)
PowerSliderCorner.Parent = PowerSlider

local PowerSliderFill = Instance.new("Frame")
PowerSliderFill.Name = "Fill"
PowerSliderFill.Size = UDim2.new(0.4, 0, 1, 0)
PowerSliderFill.BackgroundColor3 = GUIConfig.Theme.Accent
PowerSliderFill.BorderSizePixel = 0
PowerSliderFill.Parent = PowerSlider

local PowerSliderFillCorner = Instance.new("UICorner")
PowerSliderFillCorner.CornerRadius = UDim.new(0, 10)
PowerSliderFillCorner.Parent = PowerSliderFill

local PowerSliderHandle = Instance.new("Frame")
PowerSliderHandle.Name = "Handle"
PowerSliderHandle.Size = UDim2.new(0, 20, 0, 20)
PowerSliderHandle.Position = UDim2.new(0.4, -10, 0, 0)
PowerSliderHandle.BackgroundColor3 = GUIConfig.Theme.Text
PowerSliderHandle.BorderSizePixel = 0
PowerSliderHandle.Parent = PowerSlider

local PowerSliderHandleCorner = Instance.new("UICorner")
PowerSliderHandleCorner.CornerRadius = UDim.new(0, 10)
PowerSliderHandleCorner.Parent = PowerSliderHandle

-- Action Buttons Section
local ActionSection = Instance.new("Frame")
ActionSection.Name = "ActionSection"
ActionSection.Size = UDim2.new(1, 0, 0, 80)
ActionSection.Position = UDim2.new(0, 0, 0, 330)
ActionSection.BackgroundColor3 = GUIConfig.Theme.Secondary
ActionSection.BorderSizePixel = 0
ActionSection.Parent = ContentFrame

local ActionSectionCorner = Instance.new("UICorner")
ActionSectionCorner.CornerRadius = UDim.new(0, 8)
ActionSectionCorner.Parent = ActionSection

-- Action Buttons
local FlingButton = Instance.new("TextButton")
FlingButton.Name = "FlingButton"
FlingButton.Size = UDim2.new(0.48, 0, 0, 35)
FlingButton.Position = UDim2.new(0, 10, 0, 10)
FlingButton.BackgroundColor3 = GUIConfig.Theme.Success
FlingButton.BorderSizePixel = 0
FlingButton.Text = "FLING TARGET"
FlingButton.TextColor3 = GUIConfig.Theme.Text
FlingButton.TextScaled = true
FlingButton.Font = Enum.Font.GothamBold
FlingButton.Parent = ActionSection

local FlingButtonCorner = Instance.new("UICorner")
FlingButtonCorner.CornerRadius = UDim.new(0, 6)
FlingButtonCorner.Parent = FlingButton

local FlingAllButton = Instance.new("TextButton")
FlingAllButton.Name = "FlingAllButton"
FlingAllButton.Size = UDim2.new(0.48, 0, 0, 35)
FlingAllButton.Position = UDim2.new(0.52, 0, 0, 10)
FlingAllButton.BackgroundColor3 = GUIConfig.Theme.Danger
FlingAllButton.BorderSizePixel = 0
FlingAllButton.Text = "FLING ALL"
FlingAllButton.TextColor3 = GUIConfig.Theme.Text
FlingAllButton.TextScaled = true
FlingAllButton.Font = Enum.Font.GothamBold
FlingAllButton.Parent = ActionSection

local FlingAllButtonCorner = Instance.new("UICorner")
FlingAllButtonCorner.CornerRadius = UDim.new(0, 6)
FlingAllButtonCorner.Parent = FlingAllButton

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready"
StatusLabel.TextColor3 = GUIConfig.Theme.Success
StatusLabel.TextScaled = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = ActionSection

-- GUI Logic Variables
local selectedPlayer = nil
local currentMethod = "VELOCITY"
local currentPower = 50000
local isMinimized = false

-- Utility Functions
local function createMethodButton(methodName, position)
    local button = Instance.new("TextButton")
    button.Name = methodName .. "Button"
    button.BackgroundColor3 = GUIConfig.Theme.Primary
    button.BorderSizePixel = 0
    button.Text = methodName
    button.TextColor3 = GUIConfig.Theme.Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = MethodButtons
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button
end

local function createPlayerButton(player)
    local button = Instance.new("TextButton")
    button.Name = player.Name
    button.Size = UDim2.new(0, 80, 1, 0)
    button.BackgroundColor3 = GUIConfig.Theme.Primary
    button.BorderSizePixel = 0
    button.Text = player.DisplayName
    button.TextColor3 = GUIConfig.Theme.Text
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = PlayerList
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button
end

local function updateStatus(message, color)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or GUIConfig.Theme.Success
    
    -- Fade effect
    local tween = TweenService:Create(
        StatusLabel,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )
    tween:Play()
    
    -- Auto-clear after 3 seconds
    wait(3)
    local fadeTween = TweenService:Create(
        StatusLabel,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0.5}
    )
    fadeTween:Play()
end

local function updatePlayerList(searchTerm)
    -- Clear existing buttons
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    searchTerm = searchTerm and searchTerm:lower() or ""
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local name = player.Name:lower()
            local displayName = player.DisplayName:lower()
            
            if searchTerm == "" or name:find(searchTerm) or displayName:find(searchTerm) then
                local button = createPlayerButton(player)
                
                button.MouseButton1Click:Connect(function()
                    -- Deselect previous
                    if selectedPlayer then
                        for _, btn in pairs(PlayerList:GetChildren()) do
                            if btn:IsA("TextButton") and btn.Name == selectedPlayer.Name then
                                btn.BackgroundColor3 = GUIConfig.Theme.Primary
                            end
                        end
                    end
                    
                    -- Select new
                    selectedPlayer = player
                    button.BackgroundColor3 = GUIConfig.Theme.Accent
                    updateStatus("Selected: " .. player.DisplayName, GUIConfig.Theme.Success)
                end)
            end
        end
    end
    
    -- Update canvas size
    PlayerList.CanvasSize = UDim2.new(0, PlayerListLayout.AbsoluteContentSize.X, 0, 0)
end

local function updatePowerSlider(value)
    local percentage = (value - 10000) / (100000 - 10000)
    PowerSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    PowerSliderHandle.Position = UDim2.new(percentage, -10, 0, 0)
    PowerTitle.Text = "Fling Power: " .. tostring(math.floor(value))
    currentPower = value
end

-- Create method buttons
local methods = {"VELOCITY", "CFRAME", "NETWORK", "HYBRID"}
local methodButtons = {}

for i, method in ipairs(methods) do
    local button = createMethodButton(method)
    methodButtons[method] = button
    
    button.MouseButton1Click:Connect(function()
        -- Deselect all
        for _, btn in pairs(methodButtons) do
            btn.BackgroundColor3 = GUIConfig.Theme.Primary
        end
        
        -- Select this one
        button.BackgroundColor3 = GUIConfig.Theme.Accent
        currentMethod = method
        updateStatus("Method: " .. method, GUIConfig.Theme.Success)
    end)
end

-- Set default method
methodButtons["VELOCITY"].BackgroundColor3 = GUIConfig.Theme.Accent

-- Power slider functionality
local dragging = false
PowerSliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouse = LocalPlayer:GetMouse()
        local sliderPos = PowerSlider.AbsolutePosition.X
        local sliderSize = PowerSlider.AbsoluteSize.X
        local mouseX = mouse.X
        
        local percentage = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)
        local value = 10000 + (percentage * (100000 - 10000))
        
        updatePowerSlider(value)
    end
end)

-- Search functionality
SearchBox.FocusGained:Connect(function()
    if SearchBox.Text == "Search players..." then
        SearchBox.Text = ""
        SearchBox.TextColor3 = GUIConfig.Theme.Text
    end
end)

SearchBox.FocusLost:Connect(function()
    if SearchBox.Text == "" then
        SearchBox.Text = "Search players..."
        SearchBox.TextColor3 = GUIConfig.Theme.TextSecondary
    end
end)

SearchBox.Changed:Connect(function()
    if SearchBox.Text ~= "Search players..." then
        updatePlayerList(SearchBox.Text)
    end
end)

-- Button functionality
FlingButton.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        updateStatus("No player selected!", GUIConfig.Theme.Danger)
        return
    end
    
    if not _G.FEFling then
        updateStatus("Fling script not loaded!", GUIConfig.Theme.Danger)
        return
    end
    
    local success, message = _G.FEFling.flingPlayer(selectedPlayer, currentMethod, currentPower)
    if success then
        updateStatus("Flung " .. selectedPlayer.DisplayName, GUIConfig.Theme.Success)
    else
        updateStatus("Failed: " .. message, GUIConfig.Theme.Danger)
    end
end)

FlingAllButton.MouseButton1Click:Connect(function()
    if not _G.FEFling then
        updateStatus("Fling script not loaded!", GUIConfig.Theme.Danger)
        return
    end
    
    local flinged, failed = _G.FEFling.flingAll(currentMethod, currentPower)
    updateStatus("Flung " .. flinged .. " players", GUIConfig.Theme.Success)
end)

-- Window controls
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    local targetSize = isMinimized and UDim2.new(0, 400, 0, 40) or UDim2.new(0, 400, 0, 500)
    local targetPos = isMinimized and UDim2.new(0.5, -200, 0, 20) or UDim2.new(0.5, -200, 0.5, -250)
    
    local tween = TweenService:Create(
        MainFrame,
        TweenInfo.new(GUIConfig.Animations.Duration, GUIConfig.Animations.EasingStyle, GUIConfig.Animations.EasingDirection),
        {Size = targetSize, Position = targetPos}
    )
    tween:Play()
    
    ContentFrame.Visible = not isMinimized
    MinimizeButton.Text = isMinimized and "+" or "-"
end)

-- Hotkey support
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- Quick fling selected player
        if selectedPlayer and _G.FEFling then
            _G.FEFling.flingPlayer(selectedPlayer, currentMethod, currentPower)
            updateStatus("Quick fling: " .. selectedPlayer.DisplayName, GUIConfig.Theme.Success)
        end
    elseif input.KeyCode == Enum.KeyCode.G then
        -- Toggle GUI visibility
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Initialize
updatePlayerList()
updatePowerSlider(50000)

-- Update player list when players join/leave
Players.PlayerAdded:Connect(function()
    wait(1)
    updatePlayerList(SearchBox.Text ~= "Search players..." and SearchBox.Text or nil)
end)

Players.PlayerRemoving:Connect(function()
    wait(1)
    updatePlayerList(SearchBox.Text ~= "Search players..." and SearchBox.Text or nil)
end)

-- Initial status
updateStatus("GUI Loaded - Press G to toggle", GUIConfig.Theme.Success)

print("FE Fling GUI loaded!")
print("Hotkeys: F = Quick fling, G = Toggle GUI")

return ScreenGui
