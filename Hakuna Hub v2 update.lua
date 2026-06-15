--[[
    HAKUNA HUB - FLUENT UI EDITION
    - Clean, organized, and mobile‑ready
    - Toggle: Left Alt (keyboard) + persistent ☰ button (touch)
    - 4 Tabs: Main, Players, Teleport, Settings
    - Fixed: Fly/Waypoint keybind using Fluent Keybind + OnChanged
    - Fixed: Mobile toggle now always visible
    - Removed duplicate theme selector (Fluent InterfaceManager handles it)
]]

-- =================== SERVICES ===================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local VirtualUser        = game:GetService("VirtualUser")
local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()

-- =================== STATE ===================
local State = {
    isUnlimitedJump   = false,
    isFlying          = false,
    isSelfNoclip      = false,
    isGlobalNoclip    = false,
    isClickTeleport   = false,
    isFPSVisible      = false,
    isAntiAFK         = true,
    isAntiFling       = false,
    waypointCFrame    = nil,
    waypointKey       = Enum.KeyCode.E,
    flyBodyVelocity   = nil,
    flyBodyGyro       = nil,
    flyKey            = Enum.KeyCode.Q,
    flySpeed          = 50,
    connections       = {},
    toggleKey         = Enum.KeyCode.LeftAlt,
    currentWalkSpeed  = 16,
    flyToggleObj      = nil,
    globalNoclipPlayers = {},
    isAutoReturn      = false,
    autoReturnDistance = 100,
    autoReturnToggleObj = nil,
    antiFlingPlayers   = {},
}

-- =================== SAFE LOAD FLUENT ===================
local Fluent, SaveManager, InterfaceManager
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    if not ok or not lib then
        error("Failed to load Fluent UI: " .. tostring(lib))
    end
    Fluent = lib

    pcall(function()
        SaveManager     = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    end)
    pcall(function()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

-- =================== WINDOW ===================
local Window = Fluent:CreateWindow({
    Title         = "Hakuna Hub V2.",
    TabWidth      = 160,
    Size          = UDim2.fromOffset(580, 460),
    Acrylic       = true,
    Theme         = "Dark",
    MinimizeKey   = State.toggleKey,
    -- Mobile = true   -- we'll use our own persistent toggle
})

-- =================== SMOOTH MINIMIZE/MAXIMIZE PATCH ===================
task.spawn(function()
    task.wait(0.2)
    local windowFrame = nil
    local function findWindowFrame()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, child in ipairs(gui:GetChildren()) do
                    if child:IsA("Frame") and (child.Name == "Main" or child.Name == "Window") then
                        windowFrame = child
                        return
                    end
                end
            end
        end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, child in ipairs(gui:GetChildren()) do
                        if child:IsA("Frame") then
                            windowFrame = child
                            return
                        end
                    end
                end
            end
        end
    end
    findWindowFrame()
    if not windowFrame then return end
    local fullSize = windowFrame.Size
    local tweenIn  = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenOut = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local lastSize = windowFrame.Size
    windowFrame:GetPropertyChangedSignal("Size"):Connect(function()
        local newSize = windowFrame.Size
        local shrinking = newSize.Y.Offset < lastSize.Y.Offset - 20
        local growing   = newSize.Y.Offset > lastSize.Y.Offset + 20
        if shrinking then
            local target = newSize
            windowFrame.Size = lastSize
            TweenService:Create(windowFrame, tweenOut, { Size = target }):Play()
        elseif growing then
            local target = newSize
            windowFrame.Size = lastSize
            TweenService:Create(windowFrame, tweenIn, { Size = target }):Play()
        end
        lastSize = windowFrame.Size
    end)
end)

-- =================== TABS ===================
local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Players  = Window:AddTab({ Title = "Players",  Icon = "users" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

-- =================== NOTIFY ===================
local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({
            Title    = tostring(title),
            Content  = tostring(content),
            Duration = duration or 3,
        })
    end)
end

-- =================== HELPER: DISCONNECT ===================
local function Disconnect(key)
    if State.connections[key] then
        if State.connections[key].Connected then
            State.connections[key]:Disconnect()
        end
        State.connections[key] = nil
    end
end

-- =================== FORWARD DECLARATIONS ===================
local StartFly, StopFly

-- =================== MAIN TAB ===================
Tabs.Main:AddSection("Movement")

Tabs.Main:AddSlider("WalkSpeedSlider", {
    Title    = "WalkSpeed",
    Min      = 16,
    Max      = 200,
    Default  = 16,
    Rounding = 0,
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
    if hum then hum.WalkSpeed = State.currentWalkSpeed end
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

Tabs.Main:AddToggle("UnlimitedJump", {
    Title    = "Unlimited Jump",
    Default  = false,
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

-- ---- FLY ----
Tabs.Main:AddSection("Fly")

Tabs.Main:AddSlider("FlySpeedSlider", {
    Title    = "Fly Speed",
    Min      = 10,
    Max      = 300,
    Default  = 50,
    Rounding = 0,
    Callback = function(v) State.flySpeed = v end,
})

local flyKeybind = Tabs.Main:AddKeybind("FlyKeybind", {
    Title   = "Fly Key",
    Mode    = "Toggle",
    Default = "Q",
    Callback = function() end
})
flyKeybind:OnChanged(function()
    local val = flyKeybind.Value
    local ok, key = pcall(function() return Enum.KeyCode[val] end)
    if ok and key then
        State.flyKey = key
    end
end)

function StartFly()
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
    bv.Velocity  = Vector3.zero
    bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv.P         = 1e4
    bv.Parent    = root
    State.flyBodyVelocity = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P         = 1e4
    bg.D         = 50
    bg.CFrame    = root.CFrame
    bg.Parent    = root
    State.flyBodyGyro = bg

    Disconnect("flyLoop")
    State.connections["flyLoop"] = RunService.Heartbeat:Connect(function(dt)
        if not State.isFlying then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
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

        local targetVelocity = move.Magnitude > 0 and move.Unit * State.flySpeed or Vector3.zero
        local lerpFactor = math.clamp(12 * dt, 0, 1)

        if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
            State.flyBodyVelocity.Velocity = State.flyBodyVelocity.Velocity:Lerp(targetVelocity, lerpFactor)
        end
        if State.flyBodyGyro and State.flyBodyGyro.Parent then
            State.flyBodyGyro.CFrame = State.flyBodyGyro.CFrame:Lerp(cam.CFrame, lerpFactor)
        end
    end)

    Notify("Fly", "Fly Enabled", 2)
end

function StopFly()
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

local flyUIToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title    = "Enable Fly",
    Default  = false,
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

-- ---- NOCLIP (SELF) ----
Tabs.Main:AddSection("NoClip")

Tabs.Main:AddToggle("SelfNoclip", {
    Title    = "Self NoClip",
    Default  = false,
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

-- ---- NOCLIP (GLOBAL / OTHERS) ----
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

Tabs.Main:AddToggle("GlobalNoclip", {
    Title    = "Global NoCollide",
    Default  = false,
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

-- =================== ANTI‑FLING ===================
Tabs.Main:AddSection("Anti‑Fling")

local function antiFlingDisableCollide(part)
    if part:IsA("BasePart") and part.CanCollide then
        part.CanCollide = false
    end
end

local function antiFlingTrackCharacter(character)
    for _, part in ipairs(character:GetChildren()) do
        antiFlingDisableCollide(part)
    end
    character.ChildAdded:Connect(function(child)
        antiFlingDisableCollide(child)
    end)
end

local function antiFlingTrackPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        antiFlingTrackCharacter(player.Character)
    end
    player.CharacterAdded:Connect(antiFlingTrackCharacter)
    State.antiFlingPlayers[player] = true
end

Tabs.Main:AddToggle("AntiFlingToggle", {
    Title    = "Anti‑Fling (NoCollide Others)",
    Default  = false,
    Callback = function(v)
        State.isAntiFling = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                antiFlingTrackPlayer(player)
            end
            State.connections["antiFlingPlayerAdded"] = Players.PlayerAdded:Connect(antiFlingTrackPlayer)
            State.connections["antiFlingLoop"] = RunService.RenderStepped:Connect(function()
                if not State.isAntiFling then return end
                for player, _ in pairs(State.antiFlingPlayers) do
                    local character = player.Character
                    if character then
                        for _, part in ipairs(character:GetChildren()) do
                            antiFlingDisableCollide(part)
                        end
                    end
                end
            end)
        else
            Disconnect("antiFlingPlayerAdded")
            Disconnect("antiFlingLoop")
            State.antiFlingPlayers = {}
        end
    end,
})

-- ---- ESP ----
Tabs.Main:AddSection("ESP")

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
    _G.EnemyColor  = Color3.fromRGB(255, 0, 0)
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
    espLoopRunning = true
    task.spawn(function()
        while espLoopRunning and espEnabled do
            task.wait()
            if not espEnabled then break end
            updateAll()
        end
    end)

    local c1 = Players.PlayerAdded:Connect(function(v)
        task.wait(0.5)
        updateAll()
    end)
    table.insert(espConnections, c1)
end

Tabs.Main:AddToggle("ESPToggle", {
    Title    = "ESP",
    Default  = false,
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

-- =================== PLAYERS TAB ===================
local CurrentSpectateTarget = nil

local function ReturnCameraToSelf()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            Notify("Camera", "Camera returned to self", 2)
        end
    end
    CurrentSpectateTarget = nil
    if _G.__HakunaRefreshPlayerHighlights then
        _G.__HakunaRefreshPlayerHighlights()
    end
end

local function ToggleSpectate(targetPlayer)
    if CurrentSpectateTarget == targetPlayer then
        ReturnCameraToSelf()
        return
    end
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            CurrentSpectateTarget = targetPlayer
            Notify("Spectate", "Viewing: " .. targetPlayer.Name .. " (click eye again to return)", 2)
            if _G.__HakunaRefreshPlayerHighlights then
                _G.__HakunaRefreshPlayerHighlights()
            end
        end
    end
end

local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Notify("Teleport", "Target has no character", 2)
        return
    end
    local myChar = LocalPlayer.Character
    if not myChar then
        Notify("Teleport", "Your character not found", 2)
        return
    end
    local myRoot     = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        Notify("Teleport", "Teleported to " .. targetPlayer.Name, 2)
    end
end

Tabs.Players:AddSection("Players List")

local PlayerSearchInput = Tabs.Players:AddInput("PlayerSearch", {
    Title       = "Search",
    Description = "Filter players by name",
    Default     = "",
    Placeholder = "Type a name...",
    Numeric     = false,
    Finished    = false,
    Callback    = function(value)
        _G.__HakunaPlayerSearch = (value or ""):lower()
        if _G.__HakunaRefreshPlayers then
            _G.__HakunaRefreshPlayers()
        end
    end,
})

local PlayerCountParagraph = Tabs.Players:AddParagraph({
    Title   = "Players Online",
    Content = "0",
})

local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Name = "HakunaPlayerListFrame"
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Size = UDim2.new(1, 0, 0, 0)
PlayerListFrame.AutomaticSize = Enum.AutomaticSize.Y
PlayerListFrame.LayoutOrder = 999

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 5)
PlayerListLayout.Parent = PlayerListFrame

local function getTabContainer(tab)
    local candidate = rawget(tab, "Container") or (tab.Container)
    if typeof(candidate) == "Instance" then
        return candidate
    end
    return nil
end

task.spawn(function()
    task.wait(0.1)
    local container = getTabContainer(Tabs.Players)
    if container then
        PlayerListFrame.Parent = container
    else
        warn("[Hakuna] Could not locate Players tab container; list may not display.")
    end
end)

local SMOOTH_HOVER  = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SMOOTH_PRESS  = TweenInfo.new(0.08, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SMOOTH_LEAVE  = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function MakeFluentMiniButton(parent, opts)
    local btn = Instance.new("TextButton")
    btn.Size = opts.Size or UDim2.new(0, 32, 0, 24)
    btn.Position = opts.Position
    btn.AnchorPoint = opts.AnchorPoint or Vector2.new(0, 0)
    btn.BackgroundColor3 = opts.Color
    btn.BackgroundTransparency = 0
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = opts.Text or ""
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = opts.TextSize or 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    local baseColor  = opts.Color
    local hoverColor = Color3.new(
        math.clamp(baseColor.R + 0.10, 0, 1),
        math.clamp(baseColor.G + 0.10, 0, 1),
        math.clamp(baseColor.B + 0.10, 0, 1)
    )
    local pressColor = Color3.new(
        math.clamp(baseColor.R - 0.12, 0, 1),
        math.clamp(baseColor.G - 0.12, 0, 1),
        math.clamp(baseColor.B - 0.12, 0, 1)
    )

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, SMOOTH_HOVER, { BackgroundColor3 = hoverColor }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, SMOOTH_LEAVE, { BackgroundColor3 = baseColor }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, SMOOTH_PRESS, { BackgroundColor3 = pressColor }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, SMOOTH_HOVER, { BackgroundColor3 = hoverColor }):Play()
    end)

    return btn, stroke
end

local PlayerRowRefs = {}

local function RefreshPlayerHighlights()
    for plr, refs in pairs(PlayerRowRefs) do
        if refs.spectateBtn and refs.spectateBtn.Parent then
            if plr == CurrentSpectateTarget then
                TweenService:Create(refs.spectateBtn, SMOOTH_HOVER,
                    { BackgroundColor3 = Color3.fromRGB(45, 175, 95) }):Play()
            else
                TweenService:Create(refs.spectateBtn, SMOOTH_LEAVE,
                    { BackgroundColor3 = refs.baseColor }):Play()
            end
        end
    end
end
_G.__HakunaRefreshPlayerHighlights = RefreshPlayerHighlights

local function CreatePlayerRow(player, order)
    local row = Instance.new("Frame")
    row.Name = "Row_" .. player.Name
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = PlayerListFrame

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 4)
    rc.Parent = row

    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(60, 60, 60)
    rs.Thickness = 1
    rs.Transparency = 1
    rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rs.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = row

    row.MouseEnter:Connect(function()
        TweenService:Create(row, SMOOTH_HOVER, { BackgroundColor3 = Color3.fromRGB(40, 40, 40) }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, SMOOTH_LEAVE, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
    end)

    task.delay(order * 0.03, function()
        if not row.Parent then return end
        TweenService:Create(row, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0 }):Play()
        TweenService:Create(rs, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Transparency = 0 }):Play()
    end)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size = UDim2.new(1, -90, 1, 0)
    nameLbl.Position = UDim2.new(0, 0, 0, 0)
    nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextSize = 13
    nameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Text = player.DisplayName ~= player.Name
        and (player.DisplayName .. "  (@" .. player.Name .. ")")
        or player.Name
    nameLbl.Parent = row

    local spectateBaseColor = Color3.fromRGB(45, 120, 220)
    local spectateBtn = MakeFluentMiniButton(row, {
        Size        = UDim2.new(0, 32, 0, 24),
        Position    = UDim2.new(1, -72, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Color       = spectateBaseColor,
        Text        = "👁",
        TextSize    = 14,
    })
    spectateBtn.MouseButton1Click:Connect(function() ToggleSpectate(player) end)

    local tpBaseColor = Color3.fromRGB(230, 130, 35)
    local tpBtn = MakeFluentMiniButton(row, {
        Size        = UDim2.new(0, 32, 0, 24),
        Position    = UDim2.new(1, -36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Color       = tpBaseColor,
        Text        = "🚀",
        TextSize    = 14,
    })
    tpBtn.MouseButton1Click:Connect(function() TeleportToPlayer(player) end)

    PlayerRowRefs[player] = {
        spectateBtn = spectateBtn,
        baseColor   = spectateBaseColor,
    }
end

local function RefreshPlayerList()
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:sub(1, 4) == "Row_" then
            child:Destroy()
        end
    end
    PlayerRowRefs = {}

    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p)
        end
    end
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)

    local search = _G.__HakunaPlayerSearch or ""
    local visibleCount = 0
    for i, p in ipairs(list) do
        local nameLower    = p.Name:lower()
        local displayLower = (p.DisplayName or ""):lower()
        if search == "" or nameLower:find(search, 1, true) or displayLower:find(search, 1, true) then
            visibleCount += 1
            CreatePlayerRow(p, visibleCount)
        end
    end

    pcall(function()
        PlayerCountParagraph:SetDesc(tostring(#list) ..
            (search ~= "" and (" (showing " .. visibleCount .. ")") or ""))
    end)

    RefreshPlayerHighlights()
end
_G.__HakunaRefreshPlayers = RefreshPlayerList

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    RefreshPlayerList()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    RefreshPlayerList()
end)

task.spawn(function()
    task.wait(0.3)
    RefreshPlayerList()
end)

-- =================== TELEPORT TAB ===================
Tabs.Teleport:AddSection("Waypoint")

Tabs.Teleport:AddButton({
    Title    = "Set Waypoint",
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

Tabs.Teleport:AddButton({
    Title    = "Teleport to Waypoint",
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

local waypointKeybind = Tabs.Teleport:AddKeybind("WaypointKeybind", {
    Title   = "Waypoint Key",
    Mode    = "Toggle",
    Default = "E",
    Callback = function() end
})
waypointKeybind:OnChanged(function()
    local val = waypointKeybind.Value
    local ok, key = pcall(function() return Enum.KeyCode[val] end)
    if ok and key then
        State.waypointKey = key
    end
end)

Tabs.Teleport:AddSection("Click Teleport")
Tabs.Teleport:AddToggle("ClickTeleport", {
    Title    = "Click-to-Teleport (Ctrl + Click)",
    Default  = false,
    Callback = function(v)
        State.isClickTeleport = v
        if v then
            State.connections["clickTeleport"] = Mouse.Button1Down:Connect(function()
                if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
                        UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
                    return
                end
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)))
                end
            end)
        else
            Disconnect("clickTeleport")
        end
    end,
})

-- ---- AUTO RETURN ----
Tabs.Teleport:AddSection("Auto Return")

Tabs.Teleport:AddSlider("AutoReturnDist", {
    Title    = "Return Distance (Studs)",
    Min      = 1,
    Max      = 500,
    Default  = 100,
    Rounding = 0,
    Callback = function(v) State.autoReturnDistance = v end,
})

local function StartAutoReturn()
    if not State.waypointCFrame then
        Notify("Auto Return", "Set a waypoint first!", 2)
        State.isAutoReturn = false
        if State.autoReturnToggleObj then
            pcall(function() State.autoReturnToggleObj:SetValue(false) end)
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

local autoReturnToggle = Tabs.Teleport:AddToggle("AutoReturnToggle", {
    Title    = "Auto Return to Waypoint",
    Default  = false,
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
Tabs.Settings:AddSection("Display")

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
local frameCount  = 0

State.connections["fpsUpdate"] = RunService.RenderStepped:Connect(function()
    if not State.isFPSVisible then return end
    frameCount += 1
    local now = tick()
    if now - lastFPSTime >= 0.5 then
        local fps = math.floor(frameCount / (now - lastFPSTime))
        frameCount = 0
        lastFPSTime = now
        FPSLabel.Text = "FPS: " .. fps
    end
end)

Tabs.Settings:AddToggle("FPSCounterToggle", {
    Title    = "Show FPS Counter",
    Default  = false,
    Callback = function(v)
        State.isFPSVisible = v
        FPSFrame.Visible = v
        lastFPSTime = tick()
        frameCount = 0
        FPSLabel.Text = "FPS: --"
    end,
})

-- =================== ANTI‑AFK ===================
Tabs.Settings:AddSection("Anti-AFK")

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

Tabs.Settings:AddToggle("AntiAFKToggle", {
    Title    = "Anti-AFK",
    Default  = true,
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

Tabs.Settings:AddSection("Keybinds")

Tabs.Settings:AddKeybind("ToggleUIKeybind", {
    Title   = "Toggle UI Keybind",
    Mode    = "Toggle",
    Default = "LeftAlt",
    Callback = function() end,
})

do
    local kb = Window.Options and Window.Options.ToggleUIKeybind or nil
    if kb and kb.OnChanged then
        kb:OnChanged(function()
            local val = kb.Value
            local ok, key = pcall(function() return Enum.KeyCode[val] end)
            if ok and key then
                State.toggleKey = key
                pcall(function() Window:SetMinimizeKey(key) end)
                Notify("Keybind", "Toggle UI key set to: " .. tostring(val), 3)
            end
        end)
    end
end

-- Theme is handled by InterfaceManager; we'll call BuildInterfaceSection
if InterfaceManager then
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("HakunaHub")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
end

-- =================== GLOBAL INPUT HANDLER ===================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == State.flyKey then
        State.isFlying = not State.isFlying
        if State.isFlying then
            StartFly()
        else
            StopFly()
        end
        if State.flyToggleObj then
            pcall(function() State.flyToggleObj:SetValue(State.isFlying) end)
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
end)

-- =================== MOBILE OVERLAY (ALWAYS VISIBLE) ===================
-- Creates two draggable buttons: toggle UI and waypoint teleport
-- These remain on screen even when the Fluent UI is hidden.

local function FindFluentGui()
    -- Look for the ScreenGui that contains the Fluent window (Frame named "Main" or "Window")
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "MobileOverlay" and gui.Name ~= "FPSCounterGui" then
            for _, child in ipairs(gui:GetChildren()) do
                if child:IsA("Frame") and (child.Name == "Main" or child.Name == "Window") then
                    return gui
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    task.wait(0.5) -- wait for Fluent to load

    local fluentGui = FindFluentGui()
    if not fluentGui then return end

    local overlay = Instance.new("ScreenGui")
    overlay.Name = "MobileOverlay"
    overlay.ResetOnSpawn = false
    overlay.DisplayOrder = 1000
    overlay.IgnoreGuiInset = true
    overlay.Parent = game:GetService("CoreGui")

    ---- Toggle UI button ----
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0, 30)   -- top-left, just below top
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "☰"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.Draggable = true
    toggleBtn.Parent = overlay

    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0.5, 0)
    corner1.Parent = toggleBtn

    toggleBtn.Activated:Connect(function()
        if fluentGui then
            fluentGui.Enabled = not fluentGui.Enabled
        end
    end)

    ---- Waypoint teleport button ----
    local wpBtn = Instance.new("TextButton")
    wpBtn.Size = UDim2.new(0, 55, 0, 55)
    wpBtn.Position = UDim2.new(1, -70, 0.5, -27)   -- center-right
    wpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpBtn.Text = "W"
    wpBtn.Font = Enum.Font.GothamBold
    wpBtn.TextSize = 20
    wpBtn.AutoButtonColor = false
    wpBtn.Active = true
    wpBtn.Draggable = true
    wpBtn.Parent = overlay

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0.5, 0)
    corner2.Parent = wpBtn

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
end)

-- =================== FINALIZE ===================
Window:SelectTab(1)

pcall(function() Fluent:Notify({
    Title    = "Hakuna Hub Loaded",
    Content  = "Mobile toggle: ☰ always visible | Anti-AFK ON",
    Duration = 5,
}) end)

print("Hakuna Hub (Fluent) Loaded – Polished & mobile‑friendly")
