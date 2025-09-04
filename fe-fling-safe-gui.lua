--[[
    FE Fling Script - Adonis-Safe GUI Edition
    All-in-one script with embedded functionality to avoid HTTP detection
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Embedded Fling System (Adonis-Safe)
local Config = {
    FlingPower = 50000,
    MaxFlingPower = 100000,
    MinFlingPower = 10000,
    FlingDuration = 0.5
}

local CurrentMethod = "HAT"
local selectedPlayer = nil
local currentPower = 50000

-- Safe utility functions
local function getPlayer(name)
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
            return player
        end
    end
end

local function getHat(character)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle then return handle end
        end
    end
end

local function getBodyParts(character)
    local parts = {}
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            table.insert(parts, child)
        end
    end
    return parts
end

local function isValidTarget(player)
    return player and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- Safe object creation
local function createObject(className, properties, parent, duration)
    local success, obj = pcall(function()
        return Instance.new(className)
    end)
    
    if not success then return nil end
    
    for prop, value in pairs(properties or {}) do
        pcall(function() obj[prop] = value end)
    end
    
    if parent then
        pcall(function() obj.Parent = parent end)
    end
    
    if duration then
        game:GetService("Debris"):AddItem(obj, duration)
    end
    
    return obj
end

-- Fling Methods
local function velocityFling(targetPlayer, power)
    local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then return false end
    
    local bodyVelocity = createObject("BodyVelocity", {
        MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    }, targetRootPart, Config.FlingDuration)
    
    if bodyVelocity then
        local direction = (targetRootPart.Position - RootPart.Position).Unit + Vector3.new(0, 0.5, 0)
        bodyVelocity.Velocity = direction * power
        return true
    end
    return false
end

local function hatFling(targetPlayer, power)
    local hat = getHat(targetPlayer.Character)
    if not hat then return false end
    
    local bodyVelocity = createObject("BodyVelocity", {
        MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    }, hat, Config.FlingDuration)
    
    if bodyVelocity then
        local direction = (hat.Position - RootPart.Position).Unit + Vector3.new(0, 0.7, 0)
        bodyVelocity.Velocity = direction * (power * 1.5)
        return true
    end
    return false
end

local function bodyPartFling(targetPlayer, power)
    local parts = getBodyParts(targetPlayer.Character)
    if #parts == 0 then return false end
    
    local success = false
    for i = 1, math.min(3, #parts) do
        local part = parts[i]
        local bodyVelocity = createObject("BodyVelocity", {
            MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        }, part, Config.FlingDuration)
        
        if bodyVelocity then
            local direction = (part.Position - RootPart.Position).Unit + Vector3.new(0, 0.4, 0)
            bodyVelocity.Velocity = direction * (power * 0.8)
            success = true
        end
    end
    return success
end

local function hybridFling(targetPlayer, power)
    local success = false
    if hatFling(targetPlayer, power * 0.6) then success = true end
    wait(0.05)
    if velocityFling(targetPlayer, power * 0.8) then success = true end
    wait(0.05)
    if bodyPartFling(targetPlayer, power * 0.5) then success = true end
    return success
end

-- Main fling function
local function flingPlayer(targetPlayer, method, power)
    if not isValidTarget(targetPlayer) then return false end
    
    power = math.clamp(power or currentPower, Config.MinFlingPower, Config.MaxFlingPower)
    method = method or CurrentMethod
    
    if method == "VELOCITY" then
        return velocityFling(targetPlayer, power)
    elseif method == "HAT" then
        return hatFling(targetPlayer, power)
    elseif method == "BODYPART" then
        return bodyPartFling(targetPlayer, power)
    elseif method == "HYBRID" then
        return hybridFling(targetPlayer, power)
    end
    
    return false
end

-- GUI Creation (Stealth Mode)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeFlingGUI"
ScreenGui.ResetOnSpawn = false

-- Try CoreGui first, fallback to PlayerGui
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Safe Fling v2.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- Player List
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -20, 0, 120)
PlayerList.Position = UDim2.new(0, 10, 0, 45)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 6
PlayerList.Parent = MainFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 5)
ListCorner.Parent = PlayerList

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.Parent = PlayerList

-- Method Buttons
local methods = {"VELOCITY", "HAT", "BODYPART", "HYBRID"}
local methodButtons = {}

for i, method in ipairs(methods) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 0, 30)
    btn.Position = UDim2.new((i-1) % 2 * 0.52, 0, 0, 175 + math.floor((i-1) / 2) * 35)
    btn.BackgroundColor3 = method == CurrentMethod and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)
    btn.Text = method
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    methodButtons[method] = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(methodButtons) do
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        CurrentMethod = method
    end)
end

-- Power Slider
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Size = UDim2.new(1, -20, 0, 20)
PowerLabel.Position = UDim2.new(0, 10, 0, 255)
PowerLabel.BackgroundTransparency = 1
PowerLabel.Text = "Power: " .. currentPower
PowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerLabel.TextScaled = true
PowerLabel.Font = Enum.Font.Gotham
PowerLabel.Parent = MainFrame

local PowerSlider = Instance.new("Frame")
PowerSlider.Size = UDim2.new(1, -20, 0, 15)
PowerSlider.Position = UDim2.new(0, 10, 0, 280)
PowerSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PowerSlider.BorderSizePixel = 0
PowerSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 7)
SliderCorner.Parent = PowerSlider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.4, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = PowerSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 7)
FillCorner.Parent = SliderFill

-- Action Buttons
local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0.48, 0, 0, 35)
FlingBtn.Position = UDim2.new(0, 10, 0, 310)
FlingBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
FlingBtn.Text = "FLING TARGET"
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.TextScaled = true
FlingBtn.Font = Enum.Font.GothamBold
FlingBtn.BorderSizePixel = 0
FlingBtn.Parent = MainFrame

local FlingCorner = Instance.new("UICorner")
FlingCorner.CornerRadius = UDim.new(0, 5)
FlingCorner.Parent = FlingBtn

local FlingAllBtn = Instance.new("TextButton")
FlingAllBtn.Size = UDim2.new(0.48, 0, 0, 35)
FlingAllBtn.Position = UDim2.new(0.52, 0, 0, 310)
FlingAllBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
FlingAllBtn.Text = "FLING ALL"
FlingAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingAllBtn.TextScaled = true
FlingAllBtn.Font = Enum.Font.GothamBold
FlingAllBtn.BorderSizePixel = 0
FlingAllBtn.Parent = MainFrame

local FlingAllCorner = Instance.new("UICorner")
FlingAllCorner.CornerRadius = UDim.new(0, 5)
FlingAllCorner.Parent = FlingAllBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 355)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready - Adonis Safe Mode"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 385)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "HAT method recommended\nPress G to toggle GUI"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

-- Functions
local function updateStatus(message, color)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 255, 100)
end

local function updatePlayerList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = player.DisplayName
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = PlayerList
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 3)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                for _, b in pairs(PlayerList:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                selectedPlayer = player
                updateStatus("Selected: " .. player.DisplayName, Color3.fromRGB(100, 255, 100))
            end)
        end
    end
    
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

-- Power Slider Functionality
local dragging = false

PowerSlider.InputBegan:Connect(function(input)
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
        local value = Config.MinFlingPower + (percentage * (Config.MaxFlingPower - Config.MinFlingPower))
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        PowerLabel.Text = "Power: " .. math.floor(value)
        currentPower = value
    end
end)

-- Button Functions
FlingBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        updateStatus("No player selected!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if flingPlayer(selectedPlayer, CurrentMethod, currentPower) then
        updateStatus("Flung " .. selectedPlayer.DisplayName, Color3.fromRGB(100, 255, 100))
    else
        updateStatus("Fling failed - try different method", Color3.fromRGB(255, 150, 100))
    end
end)

FlingAllBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isValidTarget(player) then
            if flingPlayer(player, CurrentMethod, currentPower) then
                count = count + 1
            end
            wait(0.1)
        end
    end
    updateStatus("Flung " .. count .. " players", Color3.fromRGB(100, 255, 100))
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.F and selectedPlayer then
        flingPlayer(selectedPlayer, CurrentMethod, currentPower)
        updateStatus("Quick fling: " .. selectedPlayer.DisplayName, Color3.fromRGB(100, 255, 100))
    end
end)

-- Initialize
updatePlayerList()
updateStatus("Loaded - No HTTP requests", Color3.fromRGB(100, 255, 100))

-- Update player list when players join/leave
Players.PlayerAdded:Connect(function()
    wait(1)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function()
    wait(1)
    updatePlayerList()
end)

-- Update character reference on respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)

print("Safe Fling GUI loaded - No external dependencies!")
print("Hotkeys: G = Toggle GUI, F = Quick fling selected player")
