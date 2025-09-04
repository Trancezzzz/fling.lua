--[[
    FE Fling Script for Roblox - Enhanced Edition
    Author: Scripter
    Description: Advanced FE script with hat/body part flinging and crash prevention
    
    Features:
    - Velocity-based flinging
    - Hat manipulation flinging
    - Body part flinging
    - Network ownership exploitation
    - Crash prevention and memory management
    - Safety checks and error handling
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

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
    DebugMode = false,
    MaxConcurrentFlings = 3,
    MemoryCleanupInterval = 30
}

-- Fling Methods
local FlingMethods = {
    VELOCITY = "Velocity",
    CFRAME = "CFrame",
    NETWORK = "Network",
    HYBRID = "Hybrid",
    HAT = "Hat",
    BODYPART = "BodyPart"
}

-- Current fling method
local CurrentMethod = FlingMethods.VELOCITY

-- Memory management
local activeFlings = {}
local cleanupConnections = {}
local memoryCleanupTimer = 0

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

-- Memory cleanup function to prevent crashes
local function cleanupMemory()
    -- Clean up old fling objects
    for i = #activeFlings, 1, -1 do
        local fling = activeFlings[i]
        if tick() - fling.startTime > Config.FlingDuration * 2 then
            if fling.object and fling.object.Parent then
                fling.object:Destroy()
            end
            table.remove(activeFlings, i)
        end
    end
    
    -- Clean up old connections
    for i = #cleanupConnections, 1, -1 do
        local conn = cleanupConnections[i]
        if conn.connection and conn.connection.Connected then
            if tick() - conn.startTime > 60 then -- Clean up after 60 seconds
                conn.connection:Disconnect()
                table.remove(cleanupConnections, i)
            end
        else
            table.remove(cleanupConnections, i)
        end
    end
    
    -- Force garbage collection if too many objects
    if #activeFlings > Config.MaxConcurrentFlings * 2 then
        collectgarbage("collect")
    end
end

-- Safe object creation with cleanup tracking
local function createSafeObject(className, properties, parent, duration)
    if #activeFlings >= Config.MaxConcurrentFlings then
        cleanupMemory()
        return nil
    end
    
    local obj = Instance.new(className)
    
    -- Apply properties safely
    for prop, value in pairs(properties or {}) do
        pcall(function()
            obj[prop] = value
        end)
    end
    
    if parent then
        obj.Parent = parent
    end
    
    -- Track for cleanup
    local flingData = {
        object = obj,
        startTime = tick()
    }
    table.insert(activeFlings, flingData)
    
    -- Auto cleanup
    if duration then
        Debris:AddItem(obj, duration)
    end
    
    return obj
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

-- Get hat or accessory from character
local function getHatOrAccessory(character)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                return handle
            end
        end
    end
    return nil
end

-- Get body parts for flinging
local function getBodyParts(character)
    local parts = {}
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            table.insert(parts, child)
        end
    end
    return parts
end

-- Velocity-based flinging (Most reliable)
function FlingImplementations.Velocity(targetPlayer, power)
    debugPrint("Using Velocity method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Create BodyVelocity for flinging with safe object creation
    local bodyVelocity = createSafeObject("BodyVelocity", {
        MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    }, targetRootPart, Config.FlingDuration)
    
    if not bodyVelocity then
        return false, "Failed to create BodyVelocity (memory limit)"
    end
    
    -- Calculate fling direction (away from us)
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    direction = direction + Vector3.new(0, 0.5, 0) -- Add upward component
    
    bodyVelocity.Velocity = direction * power
    
    return true, "Velocity fling applied"
end

-- Hat-based flinging (More effective on some games)
function FlingImplementations.Hat(targetPlayer, power)
    debugPrint("Using Hat method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Find hat or accessory
    local hat = getHatOrAccessory(targetCharacter)
    if not hat then
        return false, "Target has no hat or accessory"
    end
    
    -- Create BodyVelocity on hat
    local bodyVelocity = createSafeObject("BodyVelocity", {
        MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    }, hat, Config.FlingDuration)
    
    if not bodyVelocity then
        return false, "Failed to create BodyVelocity on hat"
    end
    
    -- Calculate fling direction
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    direction = direction + Vector3.new(0, 0.7, 0) -- Higher upward component for hats
    
    bodyVelocity.Velocity = direction * (power * 1.5) -- Increase power for hat flinging
    
    -- Also create a BodyPosition to maintain connection
    local bodyPosition = createSafeObject("BodyPosition", {
        MaxForce = Vector3.new(4000, 4000, 4000),
        Position = hat.Position
    }, hat, Config.FlingDuration * 0.3)
    
    return true, "Hat fling applied"
end

-- Body part flinging (Uses limbs)
function FlingImplementations.BodyPart(targetPlayer, power)
    debugPrint("Using BodyPart method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Get body parts
    local bodyParts = getBodyParts(targetCharacter)
    if #bodyParts == 0 then
        return false, "Target has no accessible body parts"
    end
    
    -- Apply velocity to multiple body parts for better effect
    local appliedCount = 0
    local maxParts = math.min(3, #bodyParts) -- Limit to prevent crashes
    
    for i = 1, maxParts do
        local part = bodyParts[i]
        if part and part.Parent then
            local bodyVelocity = createSafeObject("BodyVelocity", {
                MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            }, part, Config.FlingDuration)
            
            if bodyVelocity then
                -- Calculate direction from our position to the body part
                local direction = (part.Position - RootPart.Position).Unit
                direction = direction + Vector3.new(
                    math.random(-30, 30) / 100,
                    0.4,
                    math.random(-30, 30) / 100
                ) -- Add randomness and upward force
                
                bodyVelocity.Velocity = direction * (power * 0.8) -- Slightly less power per part
                appliedCount = appliedCount + 1
            end
        end
    end
    
    if appliedCount > 0 then
        return true, "BodyPart fling applied to " .. appliedCount .. " parts"
    else
        return false, "Failed to apply BodyPart fling"
    end
end

-- CFrame manipulation flinging (Enhanced with safety)
function FlingImplementations.CFrame(targetPlayer, power)
    debugPrint("Using CFrame method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Calculate fling position with safety checks
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    local flingPosition = targetRootPart.Position + (direction * math.min(power / 1000, 50)) -- Limit displacement
    flingPosition = flingPosition + Vector3.new(0, math.min(power / 2000, 25), 0) -- Limit height
    
    -- Apply CFrame manipulation safely
    pcall(function()
        targetRootPart.CFrame = CFrame.new(flingPosition, flingPosition + direction)
    end)
    
    -- Create velocity for momentum with safe object creation
    local bodyVelocity = createSafeObject("BodyVelocity", {
        MaxForce = Vector3.new(math.huge, math.huge, math.huge),
        Velocity = direction * (power / 2)
    }, targetRootPart, Config.FlingDuration)
    
    if not bodyVelocity then
        return false, "Failed to create BodyVelocity for CFrame method"
    end
    
    return true, "CFrame fling applied"
end

-- Network ownership exploitation (Enhanced with safety)
function FlingImplementations.Network(targetPlayer, power)
    debugPrint("Using Network method on " .. targetPlayer.Name)
    
    local targetCharacter = targetPlayer.Character
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not targetRootPart then
        return false, "Target has no HumanoidRootPart"
    end
    
    -- Try to gain network ownership safely
    pcall(function()
        targetRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        targetRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)
    
    safeWait(0.05) -- Reduced wait time to prevent hanging
    
    -- Apply network-based fling with limits
    local direction = (targetRootPart.Position - RootPart.Position).Unit
    direction = direction + Vector3.new(0, 0.3, 0)
    
    pcall(function()
        targetRootPart.AssemblyLinearVelocity = direction * math.min(power / 10, 500) -- Limit velocity
        targetRootPart.AssemblyAngularVelocity = Vector3.new(
            math.random(-30, 30), -- Reduced random range
            math.random(-30, 30),
            math.random(-30, 30)
        )
    end)
    
    return true, "Network fling applied"
end

-- Hybrid method combining multiple techniques (Enhanced)
function FlingImplementations.Hybrid(targetPlayer, power)
    debugPrint("Using Hybrid method on " .. targetPlayer.Name)
    
    local successCount = 0
    local methods = {}
    
    -- Try hat method first (often most effective)
    local success1, msg1 = FlingImplementations.Hat(targetPlayer, power * 0.6)
    if success1 then 
        successCount = successCount + 1
        table.insert(methods, "Hat")
    end
    safeWait(0.05)
    
    -- Then velocity method
    local success2, msg2 = FlingImplementations.Velocity(targetPlayer, power * 0.8)
    if success2 then 
        successCount = successCount + 1
        table.insert(methods, "Velocity")
    end
    safeWait(0.05)
    
    -- Body part method for extra effect
    local success3, msg3 = FlingImplementations.BodyPart(targetPlayer, power * 0.5)
    if success3 then 
        successCount = successCount + 1
        table.insert(methods, "BodyPart")
    end
    
    if successCount > 0 then
        return true, "Hybrid fling applied (" .. table.concat(methods, ", ") .. ")"
    else
        return false, "All hybrid methods failed"
    end
end

-- Main Fling Function (Enhanced with crash prevention)
local function flingPlayer(targetPlayer, method, power)
    method = method or CurrentMethod
    power = power or Config.FlingPower
    
    -- Clamp power to safe limits
    power = math.clamp(power, Config.MinFlingPower, Config.MaxFlingPower)
    
    -- Safety checks
    if Config.SafetyChecks and not isValidTarget(targetPlayer) then
        return false, "Invalid target or target too far away"
    end
    
    -- Check memory limits before flinging
    if #activeFlings >= Config.MaxConcurrentFlings then
        cleanupMemory()
        if #activeFlings >= Config.MaxConcurrentFlings then
            return false, "Too many active flings, try again in a moment"
        end
    end
    
    -- Get implementation
    local implementation = FlingImplementations[method]
    if not implementation then
        return false, "Invalid fling method: " .. tostring(method)
    end
    
    -- Execute fling with error handling
    local success, message = pcall(function()
        return implementation(targetPlayer, power)
    end)
    
    if not success then
        debugPrint("Error during fling execution: " .. tostring(message))
        return false, "Fling execution error"
    end
    
    local flingSuccess, flingMessage = message[1], message[2]
    
    if flingSuccess then
        debugPrint("Successfully flung " .. targetPlayer.Name .. " using " .. method .. " method")
    else
        debugPrint("Failed to fling " .. targetPlayer.Name .. ": " .. flingMessage)
    end
    
    return flingSuccess, flingMessage
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
        return "Current method: " .. CurrentMethod .. "\nAvailable: VELOCITY, CFRAME, NETWORK, HYBRID, HAT, BODYPART"
    end
    
    local newMethod = args[1]:upper()
    if FlingMethods[newMethod] then
        CurrentMethod = newMethod
        return "Method changed to: " .. newMethod
    else
        return "Invalid method. Available: VELOCITY, CFRAME, NETWORK, HYBRID, HAT, BODYPART"
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
- method [VELOCITY/CFRAME/NETWORK/HYBRID/HAT/BODYPART] - Change fling method
- power <number> - Set fling power (10000-100000)
- help - Show this help message

Methods:
- VELOCITY: Most reliable, uses BodyVelocity
- HAT: Uses player's hat/accessories (very effective)
- BODYPART: Targets multiple body parts
- CFRAME: Uses CFrame manipulation
- NETWORK: Exploits network ownership
- HYBRID: Combines HAT, VELOCITY, and BODYPART methods
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

-- Initialize with memory management
local function initialize()
    print("FE Fling Script Enhanced Edition loaded!")
    print("New methods: HAT, BODYPART")
    print("Type /help for commands")
    
    -- Setup protections
    setupAntiKick()
    setupAutoRespawn()
    
    -- Connect chat handler
    LocalPlayer.Chatted:Connect(handleCommand)
    
    -- Setup memory cleanup timer
    local cleanupConnection = RunService.Heartbeat:Connect(function()
        memoryCleanupTimer = memoryCleanupTimer + RunService.Heartbeat:Wait()
        if memoryCleanupTimer >= Config.MemoryCleanupInterval then
            cleanupMemory()
            memoryCleanupTimer = 0
        end
    end)
    
    table.insert(cleanupConnections, {
        connection = cleanupConnection,
        startTime = tick()
    })
    
    -- Update character references on respawn
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
        debugPrint("Character updated")
        
        -- Clear active flings on respawn
        activeFlings = {}
    end)
    
    debugPrint("Initialization complete with crash prevention")
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
