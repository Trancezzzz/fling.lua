# FE Fling Script for Roblox

A comprehensive Filtering Enabled (FE) script for flinging other players in Roblox games. This script includes multiple flinging methods, a modern GUI interface, and advanced safety features.

## Features

### Core Functionality
- **Multiple Fling Methods**: Velocity, CFrame, Network, and Hybrid approaches
- **Adjustable Power**: Configurable fling strength (10,000 - 100,000)
- **Target Selection**: Fling specific players or all players at once
- **Safety Checks**: Built-in protections and validation
- **Anti-Kick Protection**: Prevents automatic kicks from detection
- **Auto-Respawn**: Automatically respawns on death

### GUI Features
- **Modern Interface**: Clean, draggable GUI with animations
- **Player Search**: Real-time player search and selection
- **Visual Feedback**: Status updates and color-coded responses
- **Hotkey Support**: Quick actions with keyboard shortcuts
- **Minimize/Close**: Window management controls

## Installation

### Method 1: Direct Execution
```lua
loadstring(game:HttpGet("path/to/fe-fling-script.lua"))()
```

### Method 2: With GUI
```lua
-- Load main script first
loadstring(game:HttpGet("path/to/fe-fling-script.lua"))()
-- Then load GUI
loadstring(game:HttpGet("path/to/fe-fling-gui.lua"))()
```

### Method 3: Local Files
1. Copy the script content to your executor
2. Execute the main script first
3. Execute the GUI script second (optional)

## Usage

### Chat Commands
The script supports various chat commands (prefix with `/`):

#### Basic Commands
- `/fling <player>` - Fling a specific player
- `/fling <player> <method>` - Fling with specific method
- `/fling <player> <method> <power>` - Fling with custom power
- `/flingall` - Fling all players
- `/flingall <method>` - Fling all with specific method
- `/flingall <method> <power>` - Fling all with custom power

#### Configuration Commands
- `/method <VELOCITY|CFRAME|NETWORK|HYBRID>` - Change fling method
- `/power <number>` - Set fling power (10000-100000)
- `/help` - Show help message

#### Examples
```lua
/fling john VELOCITY 75000
/flingall HYBRID
/method NETWORK
/power 50000
```

### GUI Usage
1. **Player Selection**: Use the search box to find players, click to select
2. **Method Selection**: Click on method buttons (VELOCITY, CFRAME, NETWORK, HYBRID)
3. **Power Adjustment**: Drag the power slider to adjust fling strength
4. **Execute**: Click "FLING TARGET" or "FLING ALL"

### Hotkeys
- **F**: Quick fling selected player
- **G**: Toggle GUI visibility

## Fling Methods

### VELOCITY (Recommended)
- **Description**: Uses BodyVelocity objects for reliable flinging
- **Reliability**: High
- **Detection Risk**: Low
- **Best For**: General use, consistent results

### CFRAME
- **Description**: Manipulates player position and applies velocity
- **Reliability**: Medium
- **Detection Risk**: Medium
- **Best For**: Bypassing certain anti-cheat systems

### NETWORK
- **Description**: Exploits network ownership for flinging
- **Reliability**: Medium
- **Detection Risk**: High
- **Best For**: Advanced users, specific scenarios

### HYBRID
- **Description**: Combines multiple methods for maximum effectiveness
- **Reliability**: High
- **Detection Risk**: Medium
- **Best For**: Stubborn targets, maximum impact

## Configuration

### Power Settings
- **Minimum**: 10,000 (gentle push)
- **Default**: 50,000 (standard fling)
- **Maximum**: 100,000 (extreme fling)

### Safety Features
```lua
Config = {
    FlingPower = 50000,        -- Default power
    MaxFlingPower = 100000,    -- Maximum allowed power
    MinFlingPower = 10000,     -- Minimum allowed power
    FlingDuration = 0.5,       -- How long velocity is applied
    SafetyChecks = true,       -- Enable safety validations
    AntiKick = true,           -- Enable anti-kick protection
    AutoRespawn = true,        -- Auto-respawn on death
    DebugMode = false          -- Enable debug messages
}
```

## API Reference

### Global Functions
The script exposes `_G.FEFling` with the following functions:

#### flingPlayer(targetPlayer, method, power)
Flings a specific player.
- **targetPlayer**: Player object to fling
- **method**: Fling method (optional, defaults to current)
- **power**: Fling power (optional, defaults to config)
- **Returns**: success (boolean), message (string)

#### flingAll(method, power)
Flings all players except yourself.
- **method**: Fling method (optional)
- **power**: Fling power (optional)
- **Returns**: flinged (number), failed (number)

#### setMethod(method)
Changes the current fling method.
- **method**: New method to use

#### setPower(power)
Changes the default fling power.
- **power**: New power value

#### getConfig()
Returns the current configuration table.

#### getMethods()
Returns available fling methods.

### Example Usage
```lua
-- Fling a specific player
local success, msg = _G.FEFling.flingPlayer(game.Players.PlayerName, "VELOCITY", 75000)

-- Fling all players
local flinged, failed = _G.FEFling.flingAll("HYBRID", 60000)

-- Change settings
_G.FEFling.setMethod("NETWORK")
_G.FEFling.setPower(80000)
```

## Troubleshooting

### Common Issues

#### Script Not Working
1. Ensure you're in a game, not the lobby
2. Check if your executor supports the required functions
3. Verify the target player is in range (< 100 studs)
4. Try different fling methods

#### Players Not Getting Flung
1. Increase fling power
2. Try the HYBRID method
3. Ensure target has a HumanoidRootPart
4. Check if target is anchored or has anti-fling

#### GUI Not Appearing
1. Check if it's minimized (press G to toggle)
2. Ensure both scripts are loaded
3. Try reloading the GUI script
4. Check executor compatibility

#### Getting Kicked
1. Enable anti-kick protection in config
2. Lower the fling power
3. Use VELOCITY method (lowest detection risk)
4. Add delays between flings

### Error Messages

#### "Invalid target or target too far away"
- Move closer to the target player
- Ensure target has spawned properly

#### "Target has no HumanoidRootPart"
- Target player hasn't fully loaded
- Try again after a few seconds

#### "Invalid fling method"
- Check method spelling (must be uppercase)
- Use: VELOCITY, CFRAME, NETWORK, or HYBRID

## Safety and Ethics

### Important Notes
- This script is for educational purposes
- Use responsibly and respect other players
- Some games may have anti-cheat systems
- Excessive use may result in account penalties

### Best Practices
1. Don't spam fling commands
2. Respect server rules and other players
3. Use appropriate power levels
4. Be aware of detection risks
5. Have fun but don't ruin others' experience

## Advanced Features

### Custom Implementations
You can extend the script with custom fling methods:

```lua
-- Add custom method
FlingImplementations.CUSTOM = function(targetPlayer, power)
    -- Your custom implementation
    return true, "Custom fling applied"
end
```

### Event Handling
The script provides various events you can hook into:

```lua
-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Update references
    Character = character
    -- Custom logic here
end)
```

## Version History

### v2.0 (Current)
- Added modern GUI interface
- Multiple fling methods
- Hotkey support
- Enhanced safety features
- API improvements

### v1.0
- Basic fling functionality
- Chat commands
- Simple configuration

## Support

For issues, suggestions, or contributions:
1. Check the troubleshooting section
2. Verify your executor compatibility
3. Test with different methods and settings
4. Report persistent issues with details

## License

This script is provided as-is for educational purposes. Use at your own risk and responsibility.
