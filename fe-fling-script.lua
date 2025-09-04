--[[
    FE Fling Script for Roblox
    Author: Scripter
    Description: Advanced FE script for flinging other players using multiple methods
    
    Features:
    - Velocity-based flinging
    - CFrame manipulation
    - Network ownership exploitation
    - Safety checks and error handling
    - Multiple fling intensities
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    FlingPower = 50000,
    MaxFlingPower = 100000,
    MinFlingPower = 10000,
    FlingDuration = 0.5,
    SafetyChecks = true,
    AntiKick = true,
    AutoRespawn = true,
    DebugMode = false
}

-- Fling Methods
local FlingMethods = {
    VELOCITY = "Velocity",
    CFRAME = "CFrame",
    NETWORK = "Network",
    HYBRID = "Hybrid"
}

-- Current fling method
local CurrentMethod = FlingMethods.VELOCITY

-- Utility Functions
local function debugPrint(message)
    if Config.DebugMode then
        print("[FE Fling Debug]: " .. tostring(message))
    end
end

local function safeWait(duration)
    local start = tick()
    while tick() - start < duration do
        RunService.Heartbeat:Wait()
    end
end

local function getPlayerFromPartialName(partialName)
    partialName = partialName:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(partialName) or player.DisplayName:lower():find(partialName) then
            return player
        end
    end
    return nil
end

local function isValidTarget(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then
        return false
    end
    
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Check if target is too far away
    local distance = (RootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
    if distance > 100 then
        return false
    end
    
    return true
end

-- Fling Implementation Methods
local FlingImplementations = {}

-- Velocity-based flinging (Most reliable)
function FlingImplementations.Velocity(targetPlayer, power)
    debugPrint("Using Velocity method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Create BodyVelocity for flinging
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    -- Calculate fling direction (away from us)
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    direction = direction + Vector3.new(0, 0.5, 0) -- Add upward component
    
    bodyVelocity.Velocity = direction * power
    bodyVelocity.Parent = targetRootPart
    
    -- Remove after duration
    game:GetService("Debris"):AddItem(bodyVelocity, Config.FlingDuration)
    
    return true, "Velocity fling applied"
end

-- CFrame manipulation flinging
function FlingImplementations.CFrame(targetPlayer, power)
    debugPrint("Using CFrame method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Store original CFrame
    local originalCFrame = targetRootPart.CFrame
    
    -- Calculate fling position
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    local flingPosition = targetRootPart.Position + (direction * (power / 1000))
    flingPosition = flingPosition + Vector3.new(0, power / 2000, 0)
    
    -- Apply CFrame manipulation
    targetRootPart.CFrame = CFrame.new(flingPosition, flingPosition + direction)
    
    -- Create velocity for momentum
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = direction * (power / 2)
    bodyVelocity.Parent = targetRootPart
    
    game:GetService("Debris"):AddItem(bodyVelocity, Config.FlingDuration)
    
    return true, "CFrame fling applied"
end

-- Network ownership exploitation
function FlingImplementations.Network(targetPlayer, power)
    debugPrint("Using Network method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Try to gain network ownership
    targetRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    targetRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    safeWait(0.1)
    
    -- Apply network-based fling
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    direction = direction + Vector3.new(0, 0.3, 0)
    
    targetRootPart.AssemblyLinearVelocity = direction * (power / 10)
    targetRootPart.AssemblyAngularVelocity = Vector3.new(
        math.random(-50, 50),
        math.random(-50, 50),
        math.random(-50, 50)
    )
    
    return true, "Network fling applied"
end

-- Hybrid method combining multiple techniques
function FlingImplementations.Hybrid(targetPlayer, power)
    debugPrint("Using Hybrid method on " .. targetPlayer.Name)
    
    -- Apply velocity method first
    local success1, msg1 = FlingImplementations.Velocity(targetPlayer, power * 0.7)
    safeWait(0.1)
    
    -- Then apply network method
    local success2, msg2 = FlingImplementations.Network(targetPlayer, power * 0.5)
    safeWait(0.1)
    
    -- Finally apply CFrame method
    local success3, msg3 = FlingImplementations.CFrame(targetPlayer, power * 0.3)
    
    return (success1 or success2 or success3), "Hybrid fling applied"
end

-- Main Fling Function
local function flingPlayer(targetPlayer, method, power)
    method = method or CurrentMethod
    power = power or Config.FlingPower
    
    -- Clamp power to safe limits
    power = math.clamp(power, Config.MinFlingPower, Config.MaxFlingPower)
    
    -- Safety checks
    if Config.SafetyChecks and not isValidTarget(targetPlayer) then
        return false, "Invalid target or target too far away"
    end
    
    -- Get implementation
    local implementation = FlingImplementations[method]
    if not implementation then
        return false, "Invalid fling method: " .. tostring(method)
    end
    
    -- Execute fling
    local success, message = implementation(targetPlayer, power)
    
    if success then
        debugPrint("Successfully flung " .. targetPlayer.Name .. " using " .. method .. " method")
    else
        debugPrint("Failed to fling " .. targetPlayer.Name .. ": " .. message)
    end
    
    return success, message
end

-- Fling all players except self
local function flingAll(method, power)
    local flinged = 0
    local failed = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isValidTarget(player) then
            local success = flingPlayer(player, method, power)
            if success then
                flinged = flinged + 1
            else
                failed = failed + 1
            end
            safeWait(0.1) -- Small delay between flings
        end
    end
    
    debugPrint("Fling all completed: " .. flinged .. " successful, " .. failed .. " failed")
    return flinged, failed
end

-- Anti-kick protection
local function setupAntiKick()
    if not Config.AntiKick then return end
    
    -- Hook into potential kick events
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" and self == LocalPlayer then
            debugPrint("Kick attempt blocked!")
            return
        end
        
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Auto respawn on death
local function setupAutoRespawn()
    if not Config.AutoRespawn then return end
    
    LocalPlayer.CharacterRemoving:Connect(function()
        safeWait(1)
        if LocalPlayer.Parent then
            LocalPlayer:LoadCharacter()
        end
    end)
end

-- Command System
local Commands = {}

Commands["fling"] = function(args)
    if #args < 1 then
        return "Usage: fling <player> [method] [power]"
    end
    
    local targetName = args[1]
    local method = args[2] and args[2]:upper() or CurrentMethod
    local power = args[3] and tonumber(args[3]) or Config.FlingPower
    
    local targetPlayer = getPlayerFromPartialName(targetName)
    if not targetPlayer then
        return "Player not found: " .. targetName
    end
    
    local success, message = flingPlayer(targetPlayer, method, power)
    return success and ("Flung " .. targetPlayer.Name) or ("Failed: " .. message)
end

Commands["flingall"] = function(args)
    local method = args[1] and args[1]:upper() or CurrentMethod
    local power = args[2] and tonumber(args[2]) or Config.FlingPower
    
    local flinged, failed = flingAll(method, power)
    return "Fling all: " .. flinged .. " successful, " .. failed .. " failed"
end

Commands["method"] = function(args)
    if #args < 1 then
        return "Current method: " .. CurrentMethod .. "\nAvailable: VELOCITY, CFRAME, NETWORK, HYBRID"
    end
    
    local newMethod = args[1]:upper()
    if FlingMethods[newMethod] then
        CurrentMethod = newMethod
        return "Method changed to: " .. newMethod
    else
        return "Invalid method. Available: VELOCITY, CFRAME, NETWORK, HYBRID"
    end
end

Commands["power"] = function(args)
    if #args < 1 then
        return "Current power: " .. Config.FlingPower
    end
    
    local newPower = tonumber(args[1])
    if newPower and newPower >= Config.MinFlingPower and newPower <= Config.MaxFlingPower then
        Config.FlingPower = newPower
        return "Power set to: " .. newPower
    else
        return "Invalid power. Range: " .. Config.MinFlingPower .. " - " .. Config.MaxFlingPower
    end
end

Commands["help"] = function()
    return [[
FE Fling Script Commands:
- fling <player> [method] [power] - Fling a specific player
- flingall [method] [power] - Fling all players
- method [VELOCITY/CFRAME/NETWORK/HYBRID] - Change fling method
- power <number> - Set fling power (10000-100000)
- help - Show this help message

Methods:
- VELOCITY: Most reliable, uses BodyVelocity
- CFRAME: Uses CFrame manipulation
- NETWORK: Exploits network ownership
- HYBRID: Combines multiple methods
]]
end

-- Chat command handler
local function handleCommand(message)
    if not message:sub(1, 1) == "/" then return end
    
    local args = {}
    for word in message:sub(2):gmatch("%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then return end
    
    local command = args[1]:lower()
    table.remove(args, 1)
    
    local handler = Commands[command]
    if handler then
        local result = handler(args)
        if result then
            print("[FE Fling]: " .. result)
        end
    end
end

-- Initialize
local function initialize()
    print("FE Fling Script loaded!")
    print("Type /help for commands")
    
    -- Setup protections
    setupAntiKick()
    setupAutoRespawn()
    
    -- Connect chat handler
    LocalPlayer.Chatted:Connect(handleCommand)
    
    -- Update character references on respawn
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
        debugPrint("Character updated")
    end)
    
    debugPrint("Initialization complete")
end

-- Start the script
initialize()

-- Export functions for external use
_G.FEFling = {
    flingPlayer = flingPlayer,
    flingAll = flingAll,
    setMethod = function(method) CurrentMethod = method end,
    setPower = function(power) Config.FlingPower = power end,
    getConfig = function() return Config end,
    getMethods = function() return FlingMethods end
}

return _G.FEFling
