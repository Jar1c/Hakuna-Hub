if _G.HakunaHubLoaded then
    return
end
_G.HakunaHubLoaded = true

--[[
    FLUENT PRO + HAKUNA HUB INTEGRATED
    - All Fluent Moded features preserved
    - Hakuna Hub features added as new tabs
    - Mobile-ready with floating buttons
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Mouse = LocalPlayer:GetMouse()

local isLoaded = false
local Fluent
local safeZoneCenter = nil
local safeZoneBoxSize = Vector3.new(20, 20, 20)

local function StartHub()
    task.wait()
    local originalNotify = Fluent.Notify
    function Fluent:Notify(data)
        if not isLoaded then return end
        originalNotify(self, data)
    end

-- =================== HAKUNA STATE ===================
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

local function Disconnect(key)
    if State.connections[key] then
        if State.connections[key].Connected then
            State.connections[key]:Disconnect()
        end
        State.connections[key] = nil
    end
end

-- =================== CREATE BUTTON FUNCTION (FROM MODED) ===================
local function CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = ButtonName
        screenGui.Parent = LocalPlayer.PlayerGui
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame")
        frame.Name = ButtonName
        frame.Size = UDim2.new(Size1, 0, Size2, 0)
        frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.Parent = screenGui

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 3
        stroke.Transparency = 0.8
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Parent = frame

        local innerFrame = Instance.new("Frame")
        innerFrame.Size = UDim2.new(1, 6, 1, 6)
        innerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        innerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        innerFrame.BackgroundTransparency = 1
        innerFrame.Parent = frame

        local innerFrameCorner = Instance.new("UICorner")
        innerFrameCorner.CornerRadius = UDim.new(0, 4)
        innerFrameCorner.Parent = innerFrame

        local innerStroke = Instance.new("UIStroke")
        innerStroke.Thickness = 2
        innerStroke.Transparency = 0.6
        innerStroke.Color = Color3.fromRGB(0, 0, 0)
        innerStroke.Parent = innerFrame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.8, 0)
        button.Position = UDim2.new(0.5, 0, 0.5, 0)
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.BackgroundTransparency = 1
        button.Text = Name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextTransparency = 0.7
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 28, 0, 28)
        toggle.Position = UDim2.new(1, 6, 0.5, -14)
        toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggle.Text = "○"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Visible = false
        toggle.Parent = frame
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

        local originalSize = UDim2.new(Size1, 0, Size2, 0)
        local holding, holdStart, hideAt = false, 0, 0

        frame:SetAttribute("IsCircle", false)
        local isCircle = CircleMode ~= nil and CircleMode or frame:GetAttribute("IsCircle")

        local function applyShape(circle)
                frame:SetAttribute("IsCircle", circle)
                if circle then
                        local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
                        frame.Size = UDim2.new(0, s, 0, s)
                        button.TextWrapped = true
                        button.TextScaled = true
                        button.TextSize = math.floor(s * 0.45)
                        frameCorner.CornerRadius = UDim.new(1, 0)
                        innerFrameCorner.CornerRadius = UDim.new(1, 0)
                        toggle.Text = "▢"
                else
                        frame.Size = originalSize
                        button.TextWrapped = false
                        button.TextScaled = true
                        button.TextSize = 14
                        frameCorner.CornerRadius = UDim.new(0, 4)
                        innerFrameCorner.CornerRadius = UDim.new(0, 4)
                        toggle.Text = "○"
                end
        end

        applyShape(isCircle)

        task.spawn(function()
                while task.wait(0.25) do
                        if not frame.Parent then break end
                        if toggle.Visible and tick() - hideAt >= 10 then toggle.Visible = false end
                end
        end)

        button.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        holding = true
                        holdStart = tick()
                end
        end)

        button.InputEnded:Connect(function(i)
                if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                        holding = false
                        if tick() - holdStart >= 0.6 then
                                toggle.Visible = true
                                hideAt = tick()
                        end
                end
        end)

        toggle.MouseButton1Click:Connect(function()
                hideAt = tick()
                applyShape(not frame:GetAttribute("IsCircle"))
        end)

        if ScriptLogic then
                button.Activated:Connect(function()
                        ScriptLogic(button)
                end)
        end

        local function MakeDraggable(topbar, obj)
                local dragging = false
                local dragInput = nil
                local dragStart = nil
                local startPos = nil
                local holdTime = 2
                local holdToken = 0
                local holding2 = false

                topbar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                dragging = true
                                dragStart = input.Position
                                startPos = obj.Position
                                holding2 = true
                                holdToken = holdToken + 1
                                local token = holdToken
                                task.delay(holdTime, function()
                                        if holding2 and token == holdToken then
                                                obj:SetAttribute("Locked", not obj:GetAttribute("Locked"))
                                                holding2 = false
                                        end
                                end)
                                input.Changed:Connect(function()
                                        if input.UserInputState == Enum.UserInputState.End then
                                                dragging = false
                                                holding2 = false
                                        end
                                end)
                        end
                end)

                topbar.InputChanged:Connect(function(input)
                        if not dragStart then return end
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                dragInput = input
                        end
                end)

                UserInputService.InputChanged:Connect(function(input)
                        if input == dragInput and dragging and not obj:GetAttribute("Locked") then
                                local delta = input.Position - dragStart
                                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                end)
        end

        MakeDraggable(button, frame)

        return frame, button, applyShape
end

local floatingGui = nil
local floatingBtn = nil

-- =================== CUSTOM THEMES (FROM MODED) ===================
Fluent:RegisterCustomTheme("NeonBlue", {
        Accent = Color3.fromRGB(0, 180, 255),
        AcrylicMain = Color3.fromRGB(10, 14, 28),
        AcrylicBorder = Color3.fromRGB(0, 100, 180),
        AcrylicGradient = ColorSequence.new(Color3.fromRGB(10, 14, 28), Color3.fromRGB(5, 8, 20)),
        AcrylicNoise = 0.75,
        TitleBarLine = Color3.fromRGB(0, 100, 180),
        Tab = Color3.fromRGB(15, 22, 48),
        Element = Color3.fromRGB(12, 18, 40),
        ElementBorder = Color3.fromRGB(0, 80, 160),
        InElementBorder = Color3.fromRGB(0, 120, 220),
        ElementTransparency = 0.82,
        ToggleSlider = Color3.fromRGB(20, 30, 70),
        ToggleToggled = Color3.fromRGB(0, 180, 255),
        SliderRail = Color3.fromRGB(20, 30, 70),
        DropdownFrame = Color3.fromRGB(10, 16, 36),
        DropdownHolder = Color3.fromRGB(6, 10, 24),
        DropdownBorder = Color3.fromRGB(0, 80, 160),
        DropdownOption = Color3.fromRGB(14, 22, 50),
        Keybind = Color3.fromRGB(14, 22, 50),
        Input = Color3.fromRGB(8, 14, 32),
        InputFocused = Color3.fromRGB(4, 8, 20),
        InputIndicator = Color3.fromRGB(0, 120, 220),
        Dialog = Color3.fromRGB(6, 10, 24),
        DialogHolder = Color3.fromRGB(4, 8, 20),
        DialogHolderLine = Color3.fromRGB(0, 70, 140),
        DialogButton = Color3.fromRGB(10, 16, 38),
        DialogButtonBorder = Color3.fromRGB(0, 80, 160),
        DialogBorder = Color3.fromRGB(0, 80, 160),
        DialogInput = Color3.fromRGB(8, 14, 32),
        DialogInputLine = Color3.fromRGB(0, 120, 220),
        Text = Color3.fromRGB(230, 245, 255),
        SubText = Color3.fromRGB(120, 170, 220),
        Hover = Color3.fromRGB(20, 36, 80),
        HoverChange = 0.05,
        ShineEnabled = true,
        StrokeShine = true,
        StrokeDark = Color3.fromRGB(0, 60, 130),
        Shine = {
                Speed = 0.5,
                RotationSpeed = 18,
                ColorSequence = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 160)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 160)),
                }),
        },
        ButtonGradient = {
                Background = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 30, 80)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 10, 40)),
                }),
                Stroke = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 220)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 220)),
                }),
        },
})

Fluent:RegisterCustomTheme("EmeraldDark", {
        Accent = Color3.fromRGB(0, 220, 120),
        AcrylicMain = Color3.fromRGB(8, 20, 14),
        AcrylicBorder = Color3.fromRGB(0, 140, 70),
        AcrylicGradient = ColorSequence.new(Color3.fromRGB(8, 20, 14), Color3.fromRGB(4, 12, 8)),
        AcrylicNoise = 0.7,
        TitleBarLine = Color3.fromRGB(0, 140, 70),
        Tab = Color3.fromRGB(10, 28, 18),
        Element = Color3.fromRGB(8, 22, 14),
        ElementBorder = Color3.fromRGB(0, 110, 55),
        InElementBorder = Color3.fromRGB(0, 180, 90),
        ElementTransparency = 0.84,
        ToggleSlider = Color3.fromRGB(14, 40, 24),
        ToggleToggled = Color3.fromRGB(0, 220, 120),
        SliderRail = Color3.fromRGB(14, 40, 24),
        DropdownFrame = Color3.fromRGB(6, 18, 12),
        DropdownHolder = Color3.fromRGB(4, 12, 8),
        DropdownBorder = Color3.fromRGB(0, 110, 55),
        DropdownOption = Color3.fromRGB(10, 28, 18),
        Keybind = Color3.fromRGB(10, 28, 18),
        Input = Color3.fromRGB(6, 18, 12),
        InputFocused = Color3.fromRGB(3, 10, 7),
        InputIndicator = Color3.fromRGB(0, 170, 85),
        Dialog = Color3.fromRGB(4, 14, 9),
        DialogHolder = Color3.fromRGB(3, 10, 6),
        DialogHolderLine = Color3.fromRGB(0, 90, 45),
        DialogButton = Color3.fromRGB(8, 20, 13),
        DialogButtonBorder = Color3.fromRGB(0, 110, 55),
        DialogBorder = Color3.fromRGB(0, 110, 55),
        DialogInput = Color3.fromRGB(6, 18, 12),
        DialogInputLine = Color3.fromRGB(0, 170, 85),
        Text = Color3.fromRGB(220, 255, 235),
        SubText = Color3.fromRGB(120, 200, 155),
        Hover = Color3.fromRGB(14, 42, 26),
        HoverChange = 0.05,
        ShineEnabled = true,
        StrokeShine = false,
        StrokeDark = Color3.fromRGB(0, 80, 40),
        ButtonGradient = {
                Background = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 25)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 10)),
                }),
                Stroke = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 75)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 220, 120)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 75)),
                }),
        },
})

-- =================== WINDOW ===================
local isMobile = UserInputService.TouchEnabled
local Window = Fluent:CreateWindow({
        Title            = "Hakuna Hub V2",
        TabWidth         = isMobile and 110 or 130,
        Size             = isMobile and UDim2.fromOffset(480, 360) or UDim2.fromOffset(580, 460),
        Acrylic          = true,
        Theme            = "Midnight",
        MinimizeKey      = Enum.KeyCode.LeftControl,
        Search           = false,
        UserInfoTop      = true,
        UserInfoTitle    = "Hakuna Hub",
        UserInfoSubtitle = LocalPlayer.Name,
        UserInfoColor    = Color3.fromRGB(0, 180, 255),
})
Window:Hide() -- Hide immediately; will show after saved theme is loaded

Fluent:SetErrorHandler(function(msg, fullErr)
        pcall(function() Fluent:Notify({ Title = "Error", Content = tostring(msg), Type = "Error", Duration = 5 }) end)
end)

-- =================== TABS ===================
local TabMain = Window:AddTab({ Title = "Main", Icon = "solar/home-bold" })
task.wait()
local TabPlayers = Window:AddTab({ Title = "Players", Icon = "solar/user-bold" })
task.wait()
local TabTeleport = Window:AddTab({ Title = "Teleport", Icon = "solar/route-bold" })
task.wait()
local TabSettings = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })
task.wait()

-- =================== HELPER NOTIFY ===================
local _notifyCooldowns = {}
local NOTIFY_COOLDOWN   = 2 -- seconds; prevents same-title spam
local function Notify(title, content, duration)
    local now = tick()
    local key = tostring(title)
    if _notifyCooldowns[key] and (now - _notifyCooldowns[key]) < NOTIFY_COOLDOWN then
        return -- drop duplicate within cooldown window
    end
    _notifyCooldowns[key] = now
    pcall(function()
        Fluent:Notify({
            Title    = key,
            Content  = tostring(content),
            Duration = duration or 3,
        })
    end)
end

-- =================== FORWARD DECLARATIONS ===================
local StartFly, StopFly
-- =================== MAIN TAB (HAKUNA FEATURES) ===================
local secMovement = TabMain:AddSection("Movement")
task.wait()

secMovement:AddSlider("WalkSpeedSlider", {
    Title    = "WalkSpeed",
    Icon     = "solar/running-bold",
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
    if safeZoneCenter then
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local floorY = safeZoneCenter.Y - safeZoneBoxSize.Y/2 + 4
                hrp.CFrame = CFrame.new(Vector3.new(safeZoneCenter.X, floorY, safeZoneCenter.Z))
            end
        end)
    end
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

secMovement:AddToggle("UnlimitedJump", {
    Title    = "Unlimited Jump",
    Icon     = "solar/arrow-up-bold",
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
secMovement:AddDivider()

task.wait()
-- ---- FLY ----
local secFly = TabMain:AddSection("Fly")

secFly:AddSlider("FlySpeedSlider", {
    Title    = "Fly Speed",
    Icon     = "solar/rocket-bold",
    Min      = 10,
    Max      = 300,
    Default  = 50,
    Rounding = 0,
    Callback = function(v) State.flySpeed = v end,
})

local flyKeybind = secFly:AddKeybind("FlyKeybind", {
    Title   = "Fly Key",
    Icon    = "solar/keyboard-bold",
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

-- Highly optimized camera-relative physics-based fly logic
local flyBusy = false -- re-entrancy guard
local lastFlyToggle = 0 -- time-based toggle debounce

function StartFly()
    if flyBusy then return end
    flyBusy = true

    local char = LocalPlayer.Character
    if not char then flyBusy = false return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then flyBusy = false return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then flyBusy = false return end

    -- Clean up any previous fly
    Disconnect("flyLoop")
    if State.flyBodyVelocity and State.flyBodyVelocity.Parent then State.flyBodyVelocity:Destroy() end
    if State.flyBodyGyro and State.flyBodyGyro.Parent then State.flyBodyGyro:Destroy() end
    State.flyBodyVelocity = nil
    State.flyBodyGyro = nil

    -- Disable Animate script and freeze animations safely using Animator
    pcall(function()
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = true end
        local animator = hum:FindFirstChildOfClass("Animator")
        local tracks = animator and animator:GetPlayingAnimationTracks() or hum:GetPlayingAnimationTracks()
        for _, track in ipairs(tracks) do
            track:AdjustSpeed(0)
        end
    end)

    -- Enable platform standing so character is physics-driven and won't walk/trip
    hum.PlatformStand = true

    -- Create body movers on HumanoidRootPart for stability
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bg.Parent = root
    State.flyBodyGyro = bg

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = root
    State.flyBodyVelocity = bv

    -- Direct camera-relative fly loop
    State.connections["flyLoop"] = RunService.RenderStepped:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r or not bv.Parent or not bg.Parent then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local camCF = cam.CFrame
        local look = camCF.LookVector
        local right = camCF.RightVector

        -- Direct key polling
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - look end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        local targetVelocity = Vector3.zero
        if moveDir.Magnitude > 0 then
            targetVelocity = moveDir.Unit * State.flySpeed
        end

        -- Smooth velocity interpolation
        bv.Velocity = bv.Velocity:Lerp(targetVelocity, 0.2)

        -- Keep character upright and facing where camera points (yaw only)
        local yawLook = Vector3.new(look.X, 0, look.Z)
        if yawLook.Magnitude > 0 then
            bg.CFrame = CFrame.new(r.Position, r.Position + yawLook)
        end
    end)

    flyBusy = false
end

function StopFly()
    if flyBusy then return end
    flyBusy = true

    State.isFlying = false
    Disconnect("flyLoop")

    if State.flyBodyVelocity and State.flyBodyVelocity.Parent then State.flyBodyVelocity:Destroy() end
    State.flyBodyVelocity = nil
    if State.flyBodyGyro and State.flyBodyGyro.Parent then State.flyBodyGyro:Destroy() end
    State.flyBodyGyro = nil

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        pcall(function()
            local animate = char:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end)
    end

    flyBusy = false
end

local flyUIToggle = secFly:AddToggle("FlyToggle", {
    Title    = "Enable Fly",
    Icon     = "solar/wing-bold",
    Default  = false,
    Callback = function(v)
        if tick() - lastFlyToggle < 0.2 then
            -- Revert UI state to State.isFlying to prevent UI desync
            if State.flyToggleObj then
                task.spawn(function()
                    State.flyToggleObj:SetValue(State.isFlying)
                end)
            end
            return
        end
        lastFlyToggle = tick()

        State.isFlying = v
        if v then
            StartFly()
        else
            StopFly()
        end
    end,
})
State.flyToggleObj = flyUIToggle
secFly:AddDivider()

task.wait()
-- ---- NOCLIP ----
local secNoclip = TabMain:AddSection("NoClip")

secNoclip:AddToggle("SelfNoclip", {
    Title    = "Self NoClip",
    Icon     = "solar/ghost-bold",
    Default  = false,
    Callback = function(v)
        State.isSelfNoclip = v
        if v then
            State.connections["selfNoclipLoop"] = RunService.Stepped:Connect(function()
                if not State.isSelfNoclip then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    elseif p:IsA("Accessory") then
                        local handle = p:FindFirstChild("Handle")
                        if handle and handle:IsA("BasePart") then
                            handle.CanCollide = false
                        end
                    end
                end
            end)
        else
            Disconnect("selfNoclipLoop")
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetChildren()) do
                    if p:IsA("BasePart") then
                        if p.Name == "Head" or p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "LowerTorso" then
                            p.CanCollide = true
                        else
                            p.CanCollide = false
                        end
                    elseif p:IsA("Accessory") then
                        local handle = p:FindFirstChild("Handle")
                        if handle and handle:IsA("BasePart") then
                            handle.CanCollide = false
                        end
                    end
                end
            end
        end
    end,
})

local function disableCollision(part)
    if part:IsA("BasePart") and part.CanCollide then
        part.CanCollide = false
    end
end

local function trackCharacter(char)
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        elseif p:IsA("Accessory") then
            local handle = p:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.CanCollide = false
            end
        end
    end
    char.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            child.CanCollide = false
        elseif child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.CanCollide = false
            end
        end
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

secNoclip:AddToggle("GlobalNoclip", {
    Title    = "Global NoCollide",
    Icon     = "solar/users-group-rounded-bold",
    Default  = false,
    Callback = function(v)
        State.isGlobalNoclip = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                trackPlayer(player)
            end
            State.connections["globalNoclipPlayerAdded"] = Players.PlayerAdded:Connect(trackPlayer)
            State.connections["globalNoclipLoop"] = RunService.Stepped:Connect(function()
                if not State.isGlobalNoclip then return end
                for player, _ in pairs(State.globalNoclipPlayers) do
                    local char = player.Character
                    if char then
                        for _, p in ipairs(char:GetChildren()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            elseif p:IsA("Accessory") then
                                local handle = p:FindFirstChild("Handle")
                                if handle and handle:IsA("BasePart") then
                                    handle.CanCollide = false
                                end
                            end
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
secNoclip:AddDivider()

task.wait()
-- ---- ANTI-FLING ----
local secAntiFling = TabMain:AddSection("Anti-Fling")

local function antiFlingTrackCharacter(character)
    for _, p in ipairs(character:GetChildren()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        elseif p:IsA("Accessory") then
            local handle = p:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.CanCollide = false
            end
        end
    end
    character.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            child.CanCollide = false
        elseif child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.CanCollide = false
            end
        end
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

secAntiFling:AddToggle("AntiFlingToggle", {
    Title    = "Anti-Fling (NoCollide Others)",
    Icon     = "solar/shield-check-bold",
    Default  = false,
    Callback = function(v)
        State.isAntiFling = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                antiFlingTrackPlayer(player)
            end
            State.connections["antiFlingPlayerAdded"] = Players.PlayerAdded:Connect(antiFlingTrackPlayer)
            State.connections["antiFlingLoop"] = RunService.Stepped:Connect(function()
                if not State.isAntiFling then return end
                for player, _ in pairs(State.antiFlingPlayers) do
                    local character = player.Character
                    if character then
                        for _, p in ipairs(character:GetChildren()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            elseif p:IsA("Accessory") then
                                local handle = p:FindFirstChild("Handle")
                                if handle and handle:IsA("BasePart") then
                                    handle.CanCollide = false
                                end
                            end
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
secAntiFling:AddDivider()

task.wait()
-- ---- ESP ----
local secESP = TabMain:AddSection("ESP")

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

secESP:AddToggle("ESPToggle", {
    Title    = "ESP",
    Icon     = "solar/eye-bold",
    Default  = false,
    Callback = function(v)
        espEnabled = v
        if v then
            ESPStart()
            Notify("ESP", "ESP Enabled", 2)
        else
            ESPCleanup()
            Notify("ESP", "ESP Disabled", 2)
        end
    end,
})
secESP:AddDivider()

-- =================== PLAYERS TAB ===================
local CurrentSpectateTarget = nil

local function ReturnCameraToSelf()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            Notify("Camera", "Returned to self", 2)
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
            Notify("Spectate", "Viewing: " .. targetPlayer.Name, 2)
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

task.wait()
TabPlayers:AddSection("Players List")

local PlayerSearchInput = TabPlayers:AddInput("PlayerSearch", {
    Title       = "Search Players",
    Icon        = "solar/search-bold",
    Description = "Filter by name",
    Default     = "",
    Placeholder = "Type name...",
    Callback    = function(value)
        _G.__HakunaPlayerSearch = (value or ""):lower()
        if _G.__HakunaRefreshPlayers then
            _G.__HakunaRefreshPlayers()
        end
    end,
})

local PlayerCountParagraph = TabPlayers:AddParagraph({
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
    local container = getTabContainer(TabPlayers)
    if container then
        PlayerListFrame.Parent = container
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
task.wait()
local secWaypoint = TabTeleport:AddSection("Waypoint")

secWaypoint:AddButton({
    Title    = "Set Waypoint",
    Icon     = "solar/map-pin-bold",
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

secWaypoint:AddButton({
    Title    = "Teleport to Waypoint",
    Icon     = "solar/target-bold",
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

local waypointKeybind = secWaypoint:AddKeybind("WaypointKeybind", {
    Title   = "Waypoint Key",
    Icon    = "solar/keyboard-bold",
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
secWaypoint:AddDivider()

task.wait()
local secClickTP = TabTeleport:AddSection("Click Teleport")
secClickTP:AddToggle("ClickTeleport", {
    Title    = "Click-to-Teleport (Ctrl + Click)",
    Icon     = "solar/cursor-bold",
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
secClickTP:AddDivider()

task.wait()
local secAutoReturn = TabTeleport:AddSection("Auto Return")

secAutoReturn:AddSlider("AutoReturnDist", {
    Title    = "Return Distance (Studs)",
    Icon     = "solar/route-bold",
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

local autoReturnToggle = secAutoReturn:AddToggle("AutoReturnToggle", {
    Title    = "Auto Return to Waypoint",
    Icon     = "solar/refresh-bold",
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
secAutoReturn:AddDivider()

-- =================== SAFE ZONE BUNKER LOGIC ===================
local safeZoneHeightOffset = 7
local safeZoneParts = {}
local safeZoneKeepInsideConn = nil

local function destroySafeZone()
    for _, part in ipairs(safeZoneParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    table.clear(safeZoneParts)
    safeZoneCenter = nil
end

local function createSafeZoneBox(center)
    destroySafeZone()
    
    local char = LocalPlayer.Character
    local charSize = char and char:GetExtentsSize() or Vector3.new(4, 6, 2)
    safeZoneBoxSize = charSize + Vector3.new(15, 10, 15)
    
    safeZoneCenter = center
    local half = safeZoneBoxSize / 2

    local model = Instance.new("Model")
    model.Name = "HakunaSafeZone"
    model.Parent = workspace
    table.insert(safeZoneParts, model)

    -- Floor
    local floor = Instance.new("Part")
    floor.Name = "SafeZoneFloor"
    floor.Anchored = true
    floor.CanCollide = true
    floor.Material = Enum.Material.ForceField
    floor.Color = Color3.fromRGB(0, 255, 200)
    floor.Shape = Enum.PartType.Block
    floor.Size = Vector3.new(safeZoneBoxSize.X, 1, safeZoneBoxSize.Z)
    floor.Position = Vector3.new(center.X, center.Y - half.Y, center.Z)
    floor.Transparency = 0.7
    floor.Parent = model
    table.insert(safeZoneParts, floor)

    -- Ceiling
    local ceiling = Instance.new("Part")
    ceiling.Name = "SafeZoneCeiling"
    ceiling.Anchored = true
    ceiling.CanCollide = true
    ceiling.Material = Enum.Material.ForceField
    ceiling.Color = Color3.fromRGB(0, 255, 200)
    ceiling.Shape = Enum.PartType.Block
    ceiling.Size = Vector3.new(safeZoneBoxSize.X, 1, safeZoneBoxSize.Z)
    ceiling.Position = Vector3.new(center.X, center.Y + half.Y, center.Z)
    ceiling.Transparency = 0.85
    ceiling.Parent = model
    table.insert(safeZoneParts, ceiling)

    -- Walls
    local wallThickness = 1
    local walls = {
        { offset = Vector3.new(0, 0, -half.Z), size = Vector3.new(safeZoneBoxSize.X, safeZoneBoxSize.Y, wallThickness) },
        { offset = Vector3.new(0, 0,  half.Z), size = Vector3.new(safeZoneBoxSize.X, safeZoneBoxSize.Y, wallThickness) },
        { offset = Vector3.new(-half.X, 0, 0), size = Vector3.new(wallThickness, safeZoneBoxSize.Y, safeZoneBoxSize.Z) },
        { offset = Vector3.new( half.X, 0, 0), size = Vector3.new(wallThickness, safeZoneBoxSize.Y, safeZoneBoxSize.Z) },
    }
    for _, wallData in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "SafeZoneWall"
        wall.Anchored = true
        wall.CanCollide = true
        wall.Material = Enum.Material.ForceField
        wall.Color = Color3.fromRGB(0, 255, 200)
        wall.Shape = Enum.PartType.Block
        wall.Size = wallData.size
        wall.Position = center + wallData.offset
        wall.Transparency = 0.85
        wall.Parent = model
        table.insert(safeZoneParts, wall)
    end

    -- Highlight the entire model
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 200)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = model
    table.insert(safeZoneParts, highlight)
end

local function isPlayerInsideSafeZone()
    if not safeZoneCenter then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local pos = hrp.Position
    local min = safeZoneCenter - safeZoneBoxSize/2
    local max = safeZoneCenter + safeZoneBoxSize/2

    return (pos.X >= min.X - 1 and pos.X <= max.X + 1)
       and (pos.Y >= min.Y - 1 and pos.Y <= max.Y + 1)
       and (pos.Z >= min.Z - 1 and pos.Z <= max.Z + 1)
end

local function startSafeZoneKeepInside()
    if safeZoneKeepInsideConn then return end
    safeZoneKeepInsideConn = RunService.Heartbeat:Connect(function()
        if not safeZoneCenter then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not isPlayerInsideSafeZone() then
            local floorY = safeZoneCenter.Y - safeZoneBoxSize.Y/2 + 4
            hrp.CFrame = CFrame.new(Vector3.new(safeZoneCenter.X, floorY, safeZoneCenter.Z))
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end)
end

local function stopSafeZoneKeepInside()
    if safeZoneKeepInsideConn then
        safeZoneKeepInsideConn:Disconnect()
        safeZoneKeepInsideConn = nil
    end
end

-- =================== MOBILE SAFE ZONE BUNKER LOGIC ===================
local mobileSafeZoneHeightOffset = 7
local mobileSafeZoneBoxSize = Vector3.new(20, 20, 20)
local mobileSafeZoneParts = {}
local mobileSafeZoneCenter = nil
local mobileSafeZoneConn = nil

local function destroyMobileSafeZone()
    for _, part in ipairs(mobileSafeZoneParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    table.clear(mobileSafeZoneParts)
    mobileSafeZoneCenter = nil
end

local function createMobileSafeZoneBox(center)
    destroyMobileSafeZone()
    
    local char = LocalPlayer.Character
    local charSize = char and char:GetExtentsSize() or Vector3.new(4, 6, 2)
    mobileSafeZoneBoxSize = charSize + Vector3.new(15, 10, 15)
    mobileSafeZoneCenter = center
    local half = mobileSafeZoneBoxSize / 2

    local model = Instance.new("Model")
    model.Name = "MobileSafeZone"
    model.Parent = workspace
    table.insert(mobileSafeZoneParts, model)

    -- Floor
    local floor = Instance.new("Part")
    floor.Name = "SafeZoneFloor"
    floor.Anchored = true
    floor.CanCollide = false
    floor.Material = Enum.Material.ForceField
    floor.Color = Color3.fromRGB(255, 255, 0)
    floor.Shape = Enum.PartType.Block
    floor.Size = Vector3.new(mobileSafeZoneBoxSize.X, 1, mobileSafeZoneBoxSize.Z)
    floor.Position = Vector3.new(0, -half.Y, 0)
    floor.Transparency = 0.7
    floor.Parent = model
    table.insert(mobileSafeZoneParts, floor)

    -- Ceiling
    local ceiling = Instance.new("Part")
    ceiling.Name = "SafeZoneCeiling"
    ceiling.Anchored = true
    ceiling.CanCollide = false
    ceiling.Material = Enum.Material.ForceField
    ceiling.Color = Color3.fromRGB(255, 255, 0)
    ceiling.Shape = Enum.PartType.Block
    ceiling.Size = Vector3.new(mobileSafeZoneBoxSize.X, 1, mobileSafeZoneBoxSize.Z)
    ceiling.Position = Vector3.new(0, half.Y, 0)
    ceiling.Transparency = 0.85
    ceiling.Parent = model
    table.insert(mobileSafeZoneParts, ceiling)

    -- Walls
    local wallThickness = 1
    local walls = {
        { offset = Vector3.new(0, 0, -half.Z), size = Vector3.new(mobileSafeZoneBoxSize.X, mobileSafeZoneBoxSize.Y, wallThickness) },
        { offset = Vector3.new(0, 0,  half.Z), size = Vector3.new(mobileSafeZoneBoxSize.X, mobileSafeZoneBoxSize.Y, wallThickness) },
        { offset = Vector3.new(-half.X, 0, 0), size = Vector3.new(wallThickness, mobileSafeZoneBoxSize.Y, mobileSafeZoneBoxSize.Z) },
        { offset = Vector3.new( half.X, 0, 0), size = Vector3.new(wallThickness, mobileSafeZoneBoxSize.Y, mobileSafeZoneBoxSize.Z) },
    }
    for _, wallData in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "SafeZoneWall"
        wall.Anchored = true
        wall.CanCollide = false
        wall.Material = Enum.Material.ForceField
        wall.Color = Color3.fromRGB(255, 255, 0)
        wall.Shape = Enum.PartType.Block
        wall.Size = wallData.size
        wall.Position = wallData.offset
        wall.Transparency = 0.85
        wall.Parent = model
        table.insert(mobileSafeZoneParts, wall)
    end

    -- Highlight the entire model
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.Parent = model
    table.insert(mobileSafeZoneParts, highlight)

    model:PivotTo(CFrame.new(center))
end

local function startMobileSafeZoneFollow()
    if mobileSafeZoneConn then return end
    mobileSafeZoneConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        table.insert(ignoreList, char)
        raycastParams.FilterDescendantsInstances = ignoreList
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        -- Find the floor part to toggle collision dynamically
        local floorPart
        for _, part in ipairs(mobileSafeZoneParts) do
            if part and part.Name == "SafeZoneFloor" then
                floorPart = part
                break
            end
        end

        local targetY
        if raycastResult then
            -- On the ground, lock Y position to the ground to completely block floating feedback loop
            targetY = raycastResult.Position.Y + half.Y
            if floorPart then
                floorPart.CanCollide = true
            end
        else
            -- Flying or in the air, center on player and make the floor non-collidable to prevent floating loops
            targetY = currentPos.Y
            if floorPart then
                floorPart.CanCollide = false
            end
        end

        local newCenter = Vector3.new(currentPos.X, targetY, currentPos.Z)
        mobileSafeZoneCenter = newCenter

        local model
        for _, part in ipairs(mobileSafeZoneParts) do
            if part and part:IsA("Model") then
                model = part
                break
            end
        end
        if model and model.Parent then
            model:PivotTo(CFrame.new(newCenter))
        end
    end)
end

local function stopMobileSafeZoneFollow()
    if mobileSafeZoneConn then
        mobileSafeZoneConn:Disconnect()
        mobileSafeZoneConn = nil
    end
end

task.wait()
local secSafeZone = TabTeleport:AddSection("Safe Zone")
secSafeZone:AddToggle("SafeZoneToggle", {
    Title    = "Safe Zone Bunker",
    Icon     = "solar/shield-check-bold",
    Default  = false,
    Callback = function(v)
        if v then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                Notify("Safe Zone", "Character not found!", 2)
                local opt = Window.Options and Window.Options.SafeZoneToggle
                if opt then task.spawn(function() opt:SetValue(false) end) end
                return
            end

            local hrp = char.HumanoidRootPart
            local currentPos = hrp.Position
            
            -- Calculate dynamic safeZoneBoxSize based on character size
            local charSize = char:GetExtentsSize()
            local dynamicBoxSize = charSize + Vector3.new(15, 10, 15)
            
            -- Place the center of the box so that the floor sits exactly at the player's feet
            local newCenter = Vector3.new(currentPos.X, currentPos.Y - (charSize.Y / 2) + (dynamicBoxSize.Y / 2), currentPos.Z)

            createSafeZoneBox(newCenter)

            local floorY = newCenter.Y - dynamicBoxSize.Y/2 + 2
            local teleportCFrame = CFrame.new(Vector3.new(newCenter.X, floorY, newCenter.Z))
            char:PivotTo(teleportCFrame)

            startSafeZoneKeepInside()
            Notify("Safe Zone", "Created and locked inside!", 2)
        else
            stopSafeZoneKeepInside()
            destroySafeZone()
            Notify("Safe Zone", "Deactivated", 2)
        end
    end,
})

secSafeZone:AddToggle("MobileSafeZoneToggle", {
    Title    = "Mobile Safe Zone (Follows You)",
    Icon     = "solar/shield-up-bold",
    Default  = false,
    Callback = function(v)
        if v then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                Notify("Mobile Safe Zone", "Character not found!", 2)
                local opt = Window.Options and Window.Options.MobileSafeZoneToggle
                if opt then task.spawn(function() opt:SetValue(false) end) end
                return
            end

            local hrp = char.HumanoidRootPart
            local currentPos = hrp.Position

            createMobileSafeZoneBox(currentPos)
            startMobileSafeZoneFollow()
            Notify("Mobile Safe Zone", "Created and following you!", 2)
        else
            stopMobileSafeZoneFollow()
            destroyMobileSafeZone()
            Notify("Mobile Safe Zone", "Deactivated", 2)
        end
    end,
})

secSafeZone:AddDivider()


-- =================== SETTINGS TAB ===================
task.wait()
local secDisplay = TabSettings:AddSection("Display")

local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "FPSCounterGui"
FPSGui.ResetOnSpawn = false
FPSGui.DisplayOrder = 999
pcall(function() FPSGui.Parent = game:GetService("CoreGui") end)
if not FPSGui.Parent then
    FPSGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local FPSFrame = Instance.new("Frame")
FPSFrame.Size = UDim2.new(0, 80, 0, 20)
FPSFrame.Position = UDim2.new(1, -90, 0, 2)
FPSFrame.BackgroundTransparency = 1
FPSFrame.BorderSizePixel = 0
FPSFrame.Visible = false
FPSFrame.Parent = FPSGui

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FPSLabel.TextSize = 13
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Parent = FPSFrame

local lastFPSTime = tick()
local frameCount  = 0

local function startFPSUpdate()
    Disconnect("fpsUpdate")
    lastFPSTime = tick()
    frameCount = 0
    State.connections["fpsUpdate"] = RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastFPSTime >= 0.5 then
            local fps = math.floor(frameCount / (now - lastFPSTime))
            frameCount = 0
            lastFPSTime = now
            FPSLabel.Text = "FPS: " .. fps
        end
    end)
end

local function stopFPSUpdate()
    Disconnect("fpsUpdate")
end

secDisplay:AddToggle("FPSCounterToggle", {
    Title    = "Show FPS Counter",
    Icon     = "solar/chart-bold",
    Default  = false,
    Callback = function(v)
        State.isFPSVisible = v
        FPSFrame.Visible = v
        if v then
            startFPSUpdate()
        else
            stopFPSUpdate()
        end
    end,
})
secDisplay:AddDivider()

task.wait()
local secButtons = TabSettings:AddSection("Buttons")
task.wait()

secButtons:AddToggle("HideUiBtn", {
    Title    = "Show UI Button",
    Icon     = "solar/menu-bold",
    Default  = true,
    Callback = function(v)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("OpenUi")
        if gui then
            local btn = gui:FindFirstChild("OpenButton")
            if btn then btn.Visible = v end
        end
    end,
})
secButtons:AddToggle("HideWpBtn", {
    Title    = "Show Teleport Button",
    Icon     = "solar/route-bold",
    Default  = true,
    Callback = function(v)
        local gui = LocalPlayer.PlayerGui:FindFirstChild("WaypointTeleportBtn")
        if gui then
            local btn = gui:FindFirstChild("WaypointBtn")
            if btn then btn.Visible = v end
        end
    end,
})
secButtons:AddDivider()

local secAntiAFK = TabSettings:AddSection("Anti-AFK")

local function enableAntiAFK()
    State.connections["antiAFK"] = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

task.spawn(enableAntiAFK)

secAntiAFK:AddToggle("AntiAFKToggle", {
    Title    = "Anti-AFK",
    Icon     = "solar/cup-bold",
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
secAntiAFK:AddDivider()

task.wait()
local secKeybinds2 = TabSettings:AddSection("Keybinds")

secKeybinds2:AddKeybind("ToggleUIKeybind", {
    Title   = "Toggle UI Keybind",
    Icon    = "solar/keyboard-bold",
    Mode    = "Toggle",
    Default = "LeftControl",
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

MediaManager:SetFolder("FluentShowcase/MediaCache")

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentShowcase")
InterfaceManager:BuildInterfaceSection(TabSettings)
InterfaceManager:LoadSettings() -- applies saved theme before window is shown
Window:Show()                   -- show NOW, theme already applied = no flash

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("FluentShowcase/Config")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(TabSettings)
SaveManager:LoadAutoloadConfig()

FloatingButtonManager:SetLibrary(Fluent)
FloatingButtonManager:SetFolder("FluentShowcase/Floating")

-- =================== OPEN UI BUTTON (MODED STYLE) ===================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "OpenUi"
toggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.ResetOnSpawn = false

local mainBtn = Instance.new("TextButton")
mainBtn.Name = "OpenButton"
mainBtn.Parent = toggleGui
mainBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainBtn.BackgroundTransparency = 1
mainBtn.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
mainBtn.Size = UDim2.new(0, 64, 0, 42)
mainBtn.Text = ""
mainBtn.Visible = true
Instance.new("UICorner", mainBtn)

-- local sizeBackMulti = 0.3
-- local backgroundImage = Instance.new("ImageLabel")
-- backgroundImage.Name = "RotatingBackground"
-- backgroundImage.Parent = mainBtn
-- backgroundImage.Size = UDim2.new(1.5 + sizeBackMulti, 0, 1.5 + sizeBackMulti, 0)
-- backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
-- backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
-- backgroundImage.BackgroundTransparency = 1
-- backgroundImage.Image = "rbxassetid://92062295706713"
-- backgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
-- backgroundImage.ZIndex = 0

local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainBtn
frontImage.Size = UDim2.fromOffset(55, 55)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = "rbxassetid://131680574108351"
frontImage.ZIndex = 1 
Instance.new("UICorner", frontImage).CornerRadius = UDim.new(0.2, 0)

--[[ -- rotation loop (disabled for performance)
local rotation = 0
local rotSpeed = 90
local lastTime = tick()
local backgroundImage = nil
task.spawn(function()
        while true do
                local now = tick()
                local delta = now - lastTime
                lastTime = now
                rotation = (rotation + rotSpeed * delta) % 360
                if backgroundImage and backgroundImage.Parent then
                        backgroundImage.Rotation = rotation
                end
                task.wait()
        end
end)
--]]

local function MakeDraggableOpenUi(topbar, obj)
        local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        local holdingDrag, holdToken = false, 0
        obj:SetAttribute("Locked", false)
        local function Update(input)
                if obj:GetAttribute("Locked") then return end
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        local function ToggleLock()
                local newState = not obj:GetAttribute("Locked")
                obj:SetAttribute("Locked", newState)
                Fluent:Notify({ Title = newState and "Locked" or "Unlocked", Content = newState and "Locked in place." or "Can be moved.", Duration = 2 })
        end
        topbar.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
                dragging = not obj:GetAttribute("Locked")
                holdingDrag = true
                dragStart = input.Position
                startPos = obj.Position
                holdToken += 1
                local token = holdToken
                task.delay(1.0, function() if holdingDrag and token == holdToken then ToggleLock() end end)
                input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false holdingDrag = false end
                end)
        end)
        topbar.InputChanged:Connect(function(input)
                if not dragStart then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if (input.Position - dragStart).Magnitude > 6 then holdingDrag = false end
                        dragInput = input
                end
        end)
        UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then Update(input) end
        end)
end
MakeDraggableOpenUi(mainBtn, mainBtn)

local uiOpen = true
local soundBusy = false
local function playSound(soundId)
        if soundBusy then return end
        soundBusy = true
        pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. soundId
                sound.Volume = 0.75
                sound.Parent = workspace
                sound:Play()
                task.delay(1.5, function()
                        pcall(function() sound:Stop() end)
                        soundBusy = false
                        pcall(function() sound:Destroy() end)
                end)
                local c
                c = sound.Ended:Connect(function()
                        c:Disconnect()
                        soundBusy = false
                        pcall(function() sound:Destroy() end)
                end)
        end)
end

mainBtn.MouseButton1Click:Connect(function()
playSound("96100657989254")
uiOpen = not uiOpen
        if uiOpen then Window:Show() else Window:Hide() end
        --[[ -- rotation animation (disabled)
        local function smoothSpeed(target, dur)
                local start = rotSpeed
                local steps = 30
                for i = 1, steps do
                        rotSpeed = start + (target - start) * (i / steps)
                        task.wait(dur / steps)
                end
                rotSpeed = target
        end
        task.spawn(function()
                smoothSpeed(360, 0.4)
                task.wait(0.5)
                smoothSpeed(180, 0.4)
                task.wait(0.3)
                smoothSpeed(90, 0.4)
        end)
        --]]
end)

FloatingButtonManager:AddButton("OpenUiBtn", mainBtn, false, false, nil, mainBtn)
FloatingButtonManager:BuildConfigSection(TabSettings)
FloatingButtonManager:LoadAutoloadConfig()

-- =================== WAYPOINT TELEPORT FLOATING BUTTON (MOBILE SHORTCUT) ===================
local wpGui = Instance.new("ScreenGui")
wpGui.Name = "WaypointTeleportBtn"
wpGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
wpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
wpGui.ResetOnSpawn = false

local wpBtn = Instance.new("ImageButton")
wpBtn.Name = "WaypointBtn"
wpBtn.Parent = wpGui
wpBtn.BackgroundTransparency = 1
wpBtn.Position = UDim2.new(0.85, 0, 0.75, 0)
wpBtn.Size = UDim2.new(0, 55, 0, 55)
wpBtn.Image = "rbxassetid://87807738555121"
wpBtn.Visible = true

Instance.new("UICorner", wpBtn).CornerRadius = UDim.new(1, 0)

do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local holdingDrag, holdToken = false, 0
    wpBtn:SetAttribute("Locked", false)
    local function Update(input)
        if wpBtn:GetAttribute("Locked") then return end
        local delta = input.Position - dragStart
        wpBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    local function ToggleLock()
        local newState = not wpBtn:GetAttribute("Locked")
        wpBtn:SetAttribute("Locked", newState)
        Fluent:Notify({ Title = newState and "Waypoint Locked" or "Waypoint Unlocked", Content = newState and "Button locked in place." or "Button can be moved.", Duration = 2 })
    end
    wpBtn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = not wpBtn:GetAttribute("Locked")
        holdingDrag = true
        dragStart = input.Position
        startPos = wpBtn.Position
        holdToken += 1
        local token = holdToken
        task.delay(1.0, function() if holdingDrag and token == holdToken then ToggleLock() end end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false holdingDrag = false end
        end)
    end)
    wpBtn.InputChanged:Connect(function(input)
        if not dragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - dragStart).Magnitude > 6 then holdingDrag = false end
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then Update(input) end
    end)
end

wpBtn.MouseButton1Click:Connect(function()
    playSound("76752236711704")
    if not State.waypointCFrame then
        Notify("Waypoint", "No Waypoint Set", 2)
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
end)

-- =================== GLOBAL INPUT HANDLER ===================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == State.flyKey then
        -- Only update the toggle; the toggle callback handles StartFly/StopFly
        if State.flyToggleObj then
            pcall(function() State.flyToggleObj:SetValue(not State.isFlying) end)
        end
        return
    end

    if input.KeyCode == State.toggleKey then
        playSound("96100657989254")
    end

    if (input.KeyCode == State.waypointKey or input.KeyCode == Enum.KeyCode.ButtonL2) and State.waypointCFrame then
        playSound("76752236711704")
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = State.waypointCFrame
            end
        end
    end
end)

-- =================== FINALIZE ===================
isLoaded = true
task.delay(0.5, function()
        Window:SelectTab(1)
end)
end

-- Asynchronous loading sequence (non-blocking)
task.spawn(function()
    task.wait(0.3)
    local success, err = pcall(function()
        return loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()
    end)
    
    if success and err then
        Fluent = err
        task.wait()
        local ok, runErr = pcall(StartHub)
        if not ok then
            error("Hakuna Hub init failed: " .. tostring(runErr))
        end
    else
        error("Hakuna Hub load failed: " .. tostring(err))
    end
end)
