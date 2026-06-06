--[[
    ROBLOX UI SCRIPT - MINIMALIST (MOBILE-FRIENDLY)
    - Anti-AFK: Auto ON on load
    - GUI: Auto opens on load
    - Teleport tab with Auto Return (NEW)
    - Mobile: Circular waypoint button (draggable), no fly button
    - ESP: Toggle ON/OFF (NEW)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local State = {
    isUnlimitedJump = false,
    isFlying = false,
    isSelfNoclip = false,
    isGlobalNoclip = false,
    isClickTeleport = false,
    isFPSVisible = false,
    isAntiAFK = true,
    waypointCFrame = nil,
    isWaitingForKey = false,
    waypointKey = Enum.KeyCode.E,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,
    flyKey = Enum.KeyCode.Q,
    flySpeed = 50,
    connections = {},
    toggleKey = Enum.KeyCode.RightShift,
    currentWalkSpeed = 16,
    flyToggleObj = nil,
    globalNoclipPlayers = {},
    isAutoReturn = false,
    autoReturnDistance = 100,
    autoReturnToggleObj = nil,
}

local Rayfield
local urls = {
    "https://sirius.menu/rayfield",
    "https://raw.githubusercontent.com/SiriusXT/Rayfield/main/source.lua",
}

for _, url in ipairs(urls) do
    local success, lib = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and type(lib) == "table" and lib.CreateWindow then
        Rayfield = lib
        break
    end
end

if not Rayfield then
    error("Failed to load Rayfield")
end

local Window = Rayfield:CreateWindow({
    Name = "Hakuna Hub",
    LoadingTitle = "Hakuna Hub",
    LoadingSubtitle = "Minimalist | Mobile-Friendly",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "Config",
    },
})

-- TABS
local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local function Notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = tostring(title),
            Content = tostring(content),
            Duration = duration or 3,
            Image = 4483362458,
        })
    end)
end

local function Disconnect(key)
    if State.connections[key] then
        if State.connections[key].Connected then
            State.connections[key]:Disconnect()
        end
        State.connections[key] = nil
    end
end

-- =================== WALKSPEED ===================
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Callback = function(v)
        State.currentWalkSpeed = v
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.currentWalkSpeed
    end
    if State.isFlying then
        task.wait(0.3)
        StartFly()
    end
    if State.isAutoReturn and State.waypointCFrame then
        task.wait(0.3)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - State.waypointCFrame.Position).Magnitude
            if dist > State.autoReturnDistance then
                root.CFrame = State.waypointCFrame
            end
        end
    end
end)

-- =================== UNLIMITED JUMP ===================
MainTab:CreateToggle({
    Name = "Unlimited Jump",
    CurrentValue = false,
    Callback = function(v)
        State.isUnlimitedJump = v
        if v then
            State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            Disconnect("unlimitedJump")
        end
    end,
})

-- =================== FLY ===================
MainTab:CreateSection("Fly")

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = " Speed",
    CurrentValue = 50,
    Callback = function(v)
        State.flySpeed = v
    end,
})

local flyKeyLabel = MainTab:CreateLabel("Fly Key: [Q]")
MainTab:CreateButton({
    Name = "Change Fly Key",
    Callback = function()
        State.isWaitingForKey = "flyKey"
        flyKeyLabel:Set("Fly Key: [Press any key...]")
        Notify("Fly Key", "Press any key...", 2)
    end,
})

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.PlatformStand = true

    if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
        State.flyBodyVelocity:Destroy()
    end
    if State.flyBodyGyro and State.flyBodyGyro.Parent then
        State.flyBodyGyro:Destroy()
    end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 9e4
    bv.Parent = root
    State.flyBodyVelocity = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 9e4
    bg.D = 100
    bg.CFrame = root.CFrame
    bg.Parent = root
    State.flyBodyGyro = bg

    Disconnect("flyLoop")
    State.connections["flyLoop"] = RunService.RenderStepped:Connect(function()
        if not State.isFlying then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local cam = workspace.CurrentCamera

        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            move -= Vector3.new(0, 1, 0)
        end

        if move.Magnitude > 0 then
            move = move.Unit * State.flySpeed
        else
            move = Vector3.zero
        end

        if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
            State.flyBodyVelocity.Velocity = move
        end
        if State.flyBodyGyro and State.flyBodyGyro.Parent then
            State.flyBodyGyro.CFrame = cam.CFrame
        end
    end)

    Notify("Fly", "Fly Enabled", 2)
end

local function StopFly()
    State.isFlying = false
    Disconnect("flyLoop")

    if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
        State.flyBodyVelocity:Destroy()
        State.flyBodyVelocity = nil
    end
    if State.flyBodyGyro and State.flyBodyGyro.Parent then
        State.flyBodyGyro:Destroy()
        State.flyBodyGyro = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    Notify("Fly", "Fly Disabled", 2)
end

local flyUIToggle = MainTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Callback = function(v)
        State.isFlying = v
        if v then
            StartFly()
        else
            StopFly()
        end
    end,
})
State.flyToggleObj = flyUIToggle

-- =================== NOCLIP (SELF) ===================
MainTab:CreateSection("NoClip")
MainTab:CreateToggle({
    Name = "Self NoClip",
    CurrentValue = false,
    Callback = function(v)
        State.isSelfNoclip = v
        if v then
            State.connections["selfNoclipLoop"] = RunService.Stepped:Connect(function()
                if not State.isSelfNoclip then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            Disconnect("selfNoclipLoop")
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.CanCollide = true
                    end
                end
            end
        end
    end,
})

-- =================== NOCLIP (GLOBAL / OTHERS) ===================
local function disableCollision(part)
    if part:IsA("BasePart") and part.CanCollide then
        part.CanCollide = false
    end
end

local function trackCharacter(char)
    for _, part in ipairs(char:GetChildren()) do
        disableCollision(part)
    end
    char.ChildAdded:Connect(function(child)
        disableCollision(child)
    end)
end

local function trackPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        trackCharacter(player.Character)
    end
    player.CharacterAdded:Connect(trackCharacter)
    State.globalNoclipPlayers[player] = true
end

MainTab:CreateToggle({
    Name = "Global NoCollide",
    CurrentValue = false,
    Callback = function(v)
        State.isGlobalNoclip = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                trackPlayer(player)
            end
            State.connections["globalNoclipPlayerAdded"] = Players.PlayerAdded:Connect(trackPlayer)
            State.connections["globalNoclipLoop"] = RunService.RenderStepped:Connect(function()
                if not State.isGlobalNoclip then return end
                for player, _ in pairs(State.globalNoclipPlayers) do
                    local char = player.Character
                    if char then
                        for _, part in ipairs(char:GetChildren()) do
                            disableCollision(part)
                        end
                    end
                end
            end)
        else
            Disconnect("globalNoclipPlayerAdded")
            Disconnect("globalNoclipLoop")
            State.globalNoclipPlayers = {}
        end
    end,
})

-- =================== ESP ===================
MainTab:CreateSection("ESP")

local espEnabled = false
local espConnections = {}
local espLoopRunning = false

local function ESPCleanup()
    espLoopRunning = false

    for _, conn in pairs(espConnections) do
        if conn then
            if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                conn:Disconnect()
            elseif type(conn) == "table" and type(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end
    end
    espConnections = {}

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local hl = v.Character:FindFirstChild("GetReal")
            if hl then hl:Destroy() end
        end
    end

    _G.Reantheajfdfjdgs = nil
end

local function ESPStart()
    _G.FriendColor = Color3.fromRGB(0, 0, 255)
    _G.EnemyColor = Color3.fromRGB(255, 0, 0)
    _G.UseTeamColor = true
    _G.Reantheajfdfjdgs = ":suifayhgvsdghfsfkajewfrhk321rk213kjrgkhj432rj34f67df"

    local plr = LocalPlayer

    local function espHighlight(target, color)
        if target.Character then
            if not target.Character:FindFirstChild("GetReal") then
                local highlight = Instance.new("Highlight")
                highlight.RobloxLocked = true
                highlight.Name = "GetReal"
                highlight.Adornee = target.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = color
                highlight.Parent = target.Character
            else
                target.Character.GetReal.FillColor = color
            end
        end
    end

    -- Update highlights for current players
    local function updateAll()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= plr then
                local color = _G.UseTeamColor
                    and v.TeamColor.Color
                    or ((plr.TeamColor == v.TeamColor) and _G.FriendColor or _G.EnemyColor)
                espHighlight(v, color)
            end
        end
    end

    updateAll()

    -- Loop to continuously refresh highlights
    espLoopRunning = true
    task.spawn(function()
        while espLoopRunning and espEnabled do
            task.wait()
            if not espEnabled then break end
            updateAll()
        end
    end)

    -- When a new player joins
    local c1 = Players.PlayerAdded:Connect(function(v)
        task.wait(0.5)
        updateAll()
    end)
    table.insert(espConnections, c1)

    -- When a player leaves, highlight auto‑removes with the character
end

MainTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        if v then
            ESPStart()
            Notify("ESP", "ESP Enabled (No NameTags)", 2)
        else
            ESPCleanup()
            Notify("ESP", "ESP Disabled", 2)
        end
    end,
})

-- =================== ANTI-AFK (AUTO ON) ===================
MainTab:CreateSection("Anti-AFK")

local function enableAntiAFK()
    State.connections["antiAFK"] = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AFK_Notice"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 36)
    frame.Position = UDim2.new(0.5, 0, 0, 60)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Anti-AFK Enabled"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 80)
    }):Play()

    task.delay(10, function()
        local out = TweenService:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -40)
        })
        out:Play()
        out.Completed:Wait()
        gui:Destroy()
    end)
end

task.spawn(enableAntiAFK)

MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Callback = function(v)
        State.isAntiAFK = v
        if v then
            enableAntiAFK()
            Notify("Anti-AFK", "Anti-AFK Enabled", 3)
        else
            Disconnect("antiAFK")
            Notify("Anti-AFK", "Anti-AFK Disabled", 2)
        end
    end,
})

-- =================== TELEPORT TAB ===================
TeleportTab:CreateSection("Waypoint")

TeleportTab:CreateButton({
    Name = "Set Waypoint",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then
            Notify("Error", "Character not found", 2)
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            Notify("Error", "HumanoidRootPart not found", 2)
            return
        end
        State.waypointCFrame = root.CFrame
        Notify("Waypoint", "Waypoint Set", 2)
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Waypoint",
    Callback = function()
        if not State.waypointCFrame then
            Notify("Error", "No Waypoint Set", 2)
            return
        end
        local char = LocalPlayer.Character
        if not char then
            Notify("Error", "Character not found", 2)
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            Notify("Error", "HumanoidRootPart not found", 2)
            return
        end
        root.CFrame = State.waypointCFrame
    end,
})

local keybindLabel = TeleportTab:CreateLabel("Keybind: [E]")
TeleportTab:CreateButton({
    Name = "Change Keybind",
    Callback = function()
        State.isWaitingForKey = "waypointKey"
        keybindLabel:Set("Press any key...")
        Notify("Keybind", "Press any key...", 2)
    end,
})

TeleportTab:CreateSection("Click Teleport")
TeleportTab:CreateToggle({
    Name = "Click-to-Teleport (Ctrl + Click)",
    CurrentValue = false,
    Callback = function(v)
        State.isClickTeleport = v
        if v then
            State.connections["clickTeleport"] = Mouse.Button1Down:Connect(function()
                if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
                    return
                end
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)))
                end
            end)
        else
            Disconnect("clickTeleport")
        end
    end,
})

-- =================== AUTO RETURN TO WAYPOINT ===================
TeleportTab:CreateSection("Auto Return")

TeleportTab:CreateSlider({
    Name = "Return Distance (Studs)",
    Range = {1, 500},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 100,
    Callback = function(v)
        State.autoReturnDistance = v
    end,
})

local function StartAutoReturn()
    if not State.waypointCFrame then
        Notify("Auto Return", "Set a waypoint first!", 2)
        State.isAutoReturn = false
        if State.autoReturnToggleObj then
            State.autoReturnToggleObj:Set(false)
        end
        return
    end

    Disconnect("autoReturnLoop")

    State.connections["autoReturnLoop"] = RunService.Heartbeat:Connect(function()
        if not State.isAutoReturn or not State.waypointCFrame then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local dist = (root.Position - State.waypointCFrame.Position).Magnitude
        if dist > State.autoReturnDistance then
            root.CFrame = State.waypointCFrame
        end
    end)

    Notify("Auto Return", "Enabled | Distance: " .. State.autoReturnDistance .. " studs", 2)
end

local function StopAutoReturn()
    Disconnect("autoReturnLoop")
    Notify("Auto Return", "Disabled", 2)
end

local autoReturnToggle = TeleportTab:CreateToggle({
    Name = "Auto Return to Waypoint",
    CurrentValue = false,
    Callback = function(v)
        State.isAutoReturn = v
        if v then
            StartAutoReturn()
        else
            StopAutoReturn()
        end
    end,
})
State.autoReturnToggleObj = autoReturnToggle

-- =================== SETTINGS TAB ===================
SettingsTab:CreateSection("Display")

local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "FPSCounterGui"
FPSGui.ResetOnSpawn = false
FPSGui.DisplayOrder = 999

pcall(function() FPSGui.Parent = game:GetService("CoreGui") end)
if not FPSGui.Parent then
    FPSGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local FPSFrame = Instance.new("Frame")
FPSFrame.Size = UDim2.new(0, 80, 0, 26)
FPSFrame.Position = UDim2.new(1, -90, 0, 10)
FPSFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FPSFrame.BackgroundTransparency = 0.2
FPSFrame.BorderSizePixel = 0
FPSFrame.Visible = false
FPSFrame.Parent = FPSGui

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.TextSize = 13
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Parent = FPSFrame

local lastFPSTime = tick()
local frameCount = 0

State.connections["fpsUpdate"] = RunService.RenderStepped:Connect(function()
    if not State.isFPSVisible then return end
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFPSTime >= 0.5 then
        local fps = math.floor(frameCount / (now - lastFPSTime))
        frameCount = 0
        lastFPSTime = now
        FPSLabel.Text = "FPS: " .. fps
    end
end)

SettingsTab:CreateToggle({
    Name = "Show FPS Counter",
    CurrentValue = false,
    Callback = function(v)
        State.isFPSVisible = v
        FPSFrame.Visible = v
        lastFPSTime = tick()
        frameCount = 0
        FPSLabel.Text = "FPS: --"
    end,
})

SettingsTab:CreateSection("Keybinds")
SettingsTab:CreateKeybind({
    Name = "Toggle UI Keybind",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Callback = function(keybind)
        local ok, key = pcall(function() return Enum.KeyCode[keybind] end)
        if ok and key then
            State.toggleKey = key
            Notify("Keybind", "Toggle UI key set to: " .. keybind, 3)
        end
    end,
})

-- =================== GLOBAL INPUT HANDLER ===================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if State.isWaitingForKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            if State.isWaitingForKey == "waypointKey" then
                State.waypointKey = input.KeyCode
                keybindLabel:Set("Keybind: [" .. input.KeyCode.Name .. "]")
                Notify("Keybind", "Waypoint key set to: " .. input.KeyCode.Name, 2)
            elseif State.isWaitingForKey == "flyKey" then
                State.flyKey = input.KeyCode
                flyKeyLabel:Set("Fly Key: [" .. input.KeyCode.Name .. "]")
                Notify("Fly Key", "Fly key set to: " .. input.KeyCode.Name, 2)
            end
            State.isWaitingForKey = false
        end
        return
    end

    if input.KeyCode == State.flyKey then
        State.isFlying = not State.isFlying
        if State.isFlying then
            StartFly()
        else
            StopFly()
        end
        if State.flyToggleObj then
            pcall(function() State.flyToggleObj:Set(State.isFlying) end)
        end
        return
    end

    if input.KeyCode == State.waypointKey and State.waypointCFrame then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = State.waypointCFrame
            end
        end
    end

    if input.KeyCode == State.toggleKey then
        pcall(function() Rayfield:HideGui() end)
        pcall(function() Rayfield:ShowGui() end)
    end
end)

-- =================== MOBILE UI ===================
local function CreateMobileButtons()
    if not UserInputService.TouchEnabled then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileButtons"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 998
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local wpBtn = Instance.new("TextButton")
    wpBtn.Name = "WaypointButton"
    wpBtn.Size = UDim2.new(0, 55, 0, 55)
    wpBtn.Position = UDim2.new(1, -70, 0.5, -27)
    wpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpBtn.Text = "W"
    wpBtn.Font = Enum.Font.GothamBold
    wpBtn.TextSize = 18
    wpBtn.AutoButtonColor = false
    wpBtn.Active = true
    wpBtn.Draggable = true
    wpBtn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = wpBtn

    wpBtn.Activated:Connect(function()
        if State.waypointCFrame then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = State.waypointCFrame
                    Notify("Waypoint", "Teleported!", 1)
                end
            end
        else
            Notify("Waypoint", "No waypoint set! Use UI to set first.", 2)
        end
    end)
end

task.wait(0.5)
CreateMobileButtons()

print("Hakuna Hub Loaded")
print("Anti-AFK: Auto ON")
print("RightShift - Toggle UI")
print("Q - Toggle Fly (Default)")
print("E - Waypoint Teleport (Default)")
print("Mobile: Circular waypoint button (draggable)")

task.wait(1)
pcall(function() Rayfield:ShowGui() end)

task.wait(2)
Notify("Loaded", "Anti-AFK: ON | RightShift = UI | Mobile Ready", 5)
