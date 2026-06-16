--[[
    FLUENT PRO + HAKUNA HUB INTEGRATED
    - All Fluent Moded features preserved
    - Hakuna Hub features added as new tabs
    - Mobile-ready with floating buttons
]]

local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Mouse = LocalPlayer:GetMouse()

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
local Window = Fluent:CreateWindow({
        Title            = "Hakuna Hub V2",
        TabWidth         = 130,
        Size             = UDim2.fromOffset(580, 460),
        Acrylic          = true,
        Theme            = "Midnight",
        MinimizeKey      = Enum.KeyCode.LeftControl,
        Search           = true,
        TabLogo          = "rbxassetid://75683776827684",
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
local TabPlayers = Window:AddTab({ Title = "Players", Icon = "solar/user-bold" })
local TabTeleport = Window:AddTab({ Title = "Teleport", Icon = "solar/route-bold" })
local TabElements = Window:AddTab({ Title = "Elements", Icon = "solar/layers-bold" })
local TabComponents = Window:AddTab({ Title = "Components", Icon = "solar/widget-bold" })
local TabSettings = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })

-- =================== HELPER NOTIFY ===================
local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({
            Title    = tostring(title),
            Content  = tostring(content),
            Duration = duration or 3,
        })
    end)
end

-- =================== FORWARD DECLARATIONS ===================
local StartFly, StopFly

-- =================== MAIN TAB (HAKUNA FEATURES) ===================
local secMovement = TabMain:AddSection("Movement")

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
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.CanCollide = true
                    elseif p:IsA("Accessory") then
                        local handle = p:FindFirstChild("Handle")
                        if handle and handle:IsA("BasePart") then
                            handle.CanCollide = true
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

-- =================== ELEMENTS TAB (FROM MODED) ===================
local secToggles = TabElements:AddSection("Toggle")
secToggles:AddToggle("ShowcaseToggle1", {
        Title = "Speed Boost",
        Icon = "solar/running-bold",
        Default = false,
        Description = "Enables walk speed multiplier when ON.",
        Callback = function(v)
                local chr = LocalPlayer.Character
                if chr and chr:FindFirstChild("Humanoid") then chr.Humanoid.WalkSpeed = v and 60 or 16 end
                Fluent:Notify({ Title = "Speed Boost", Content = v and "Enabled" or "Disabled", Type = v and "Success" or "Info", Duration = 2 })
        end,
})
secToggles:AddToggle("ShowcaseToggle2", {
        Title = "High Jump",
        Icon = "solar/arrow-up-bold",
        Default = false,
        Description = "Increases jump power when ON.",
        Callback = function(v)
                local chr = LocalPlayer.Character
                if chr and chr:FindFirstChild("Humanoid") then chr.Humanoid.JumpPower = v and 120 or 50 end
                Fluent:Notify({ Title = "High Jump", Content = v and "Enabled" or "Disabled", Type = v and "Success" or "Info", Duration = 2 })
        end,
})
secToggles:AddDivider()

local secSliders = TabElements:AddSection("Slider")
secSliders:AddSlider("ShowcaseSlider1", {
        Title = "Walk Speed",
        Icon = "solar/running-bold",
        Min = 1,
        Max = 200,
        Default = 16,
        Rounding = 0,
        Description = "Sets humanoid WalkSpeed in real time.",
        Callback = function(v)
                local chr = LocalPlayer.Character
                if chr and chr:FindFirstChild("Humanoid") then chr.Humanoid.WalkSpeed = v end
        end,
})
secSliders:AddSlider("ShowcaseSlider2", {
        Title = "Volume",
        Icon = "solar/volume-loud-bold",
        Min = 0,
        Max = 10,
        Default = 5,
        Rounding = 1,
        Description = "Decimal slider — Rounding=1 gives one decimal place.",
        Callback = function(v)
                Fluent:Notify({ Title = "Volume", Content = tostring(v / 10), Duration = 1 })
        end,
})
secSliders:AddDivider()

local secButtons = TabElements:AddSection("Button")
secButtons:AddButton({
        Title = "Reset Character",
        Icon = "solar/restart-bold",
        Description = "Destroys HumanoidRootPart to respawn the character.",
        Callback = function()
                if LocalPlayer.Character then
                        local hr = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hr then hr:Destroy() end
                end
                Fluent:Notify({ Title = "Reset", Content = "Character reset.", Type = "Warning", Duration = 3 })
        end,
})
secButtons:AddButton({
        Title = "Fire Notify",
        Icon = "solar/bell-bold",
        Description = "Demonstrates a Success notification.",
        Callback = function()
                Fluent:Notify({ Title = "Hello!", Content = "Button was pressed.", Type = "Success", Duration = 3 })
        end,
})
secButtons:AddDivider()

local secInputs = TabElements:AddSection("Input")
secInputs:AddInput("ShowcaseInput1", {
        Title = "Display Name",
        Icon = "solar/user-bold",
        Placeholder = "Enter a name…",
        Default = "",
        Description = "Text is echoed back in a notify on submit.",
        Callback = function(v) Fluent:Notify({ Title = "Input", Content = "Value: " .. v, Duration = 2 }) end,
})
secInputs:AddDivider()

local secColor = TabElements:AddSection("Colorpicker")
secColor:AddColorpicker("ShowcaseColor1", {
        Title = "Accent Preview",
        Icon = "solar/palette-bold",
        Default = Color3.fromRGB(255, 80, 80),
        Transparency = 0,
        Description = "Pick any colour — value shown in notify.",
        Callback = function(c) Fluent:Notify({ Title = "Color", Content = tostring(c), Duration = 2 }) end,
})
secColor:AddDivider()

local secKeybinds = TabElements:AddSection("Keybind")
secKeybinds:AddKeybind("ShowcaseBind1", {
        Title = "Toggle UI",
        Icon = "solar/keyboard-bold",
        Default = "RightAlt",
        Mode = "Toggle",
        Description = "Toggle mode: fires true/false each press.",
        Callback = function(state)
                if state then Window:Show() else Window:Hide() end
                Fluent:Notify({ Title = "Keybind", Content = state and "UI Shown" or "UI Hidden", Type = "Info", Duration = 2 })
        end,
})
secKeybinds:AddKeybind("ShowcaseBind2", {
        Title = "Hold Action",
        Icon = "solar/hand-holding-bold",
        Default = "RightShift",
        Mode = "Hold",
        Description = "Hold mode: fires true while held, false on release.",
        Callback = function(held)
                Fluent:Notify({ Title = "Hold", Content = held and "Holding…" or "Released", Type = held and "Warning" or "Info", Duration = 1 })
        end,
})
secKeybinds:AddDivider()

local secDD = TabElements:AddSection("Dropdown")
secDD:AddDropdown("ShowcaseDD1", {
        Title = "Single Select",
        Icon = "solar/list-bold",
        Values = { "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape" },
        Default = "Apple",
        Description = "Standard single-select with search.",
        Callback = function(v) Fluent:Notify({ Title = "Dropdown", Content = tostring(v), Duration = 2 }) end,
})
secDD:AddDropdown("ShowcaseDD2", {
        Title = "Multi Select",
        Icon = "solar/layers-bold",
        Multi = true,
        Values = { "Fighter", "Mage", "Rogue", "Ranger", "Paladin", "Druid", "Bard" },
        Default = { "Fighter", "Mage" },
        Description = "Multi-select — holds a table of selected keys.",
        Callback = function(v)
                local parts = {}
                for k in next, v do table.insert(parts, k) end
                Fluent:Notify({ Title = "Multi DD", Content = table.concat(parts, ", "), Duration = 3 })
        end,
})
secDD:AddDropdown("ShowcaseDD3", {
        Title = "Outside Window",
        Icon = "solar/maximise-bold",
        Values = { "Option A", "Option B", "Option C", "Option D", "Option E" },
        Default = "Option A",
        OutsideWindow = true,
        Description = "Popup appears to the right of the window.",
        Callback = function(v) Fluent:Notify({ Title = "Outside Dropdown", Content = tostring(v), Duration = 2 }) end,
})
secDD:AddDivider()

local secCode = TabElements:AddSection("Code")
secCode:AddCode({
        Title = "Load FluentPro",
        Code = 'local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()',
        OnCopy = function() Fluent:Notify({ Title = "Code", Content = "Copied!", Duration = 2 }) end,
})
secCode:AddDivider()

local secMisc = TabElements:AddSection("Divider & Space")
secMisc:AddDivider()
secMisc:AddButton({ Title = "Button Above", Icon = "solar/star-bold", Callback = function() end })
secMisc:AddSpace({ Height = 20 })
secMisc:AddButton({ Title = "Button Below", Icon = "solar/star-bold", Callback = function() end })
secMisc:AddDivider()

local secImg = TabElements:AddSection("Image")
secImg:AddImage({ Image = "rbxassetid://7733960981", AspectRatio = "16:9", Radius = 10 })
secImg:AddImage({ Image = "https://od.lk/d/NjNfOTg0NzkzMzdf/YotsubaRt.png", AspectRatio = "16:9", Radius = 10 })
secImg:AddImage({ Image = "https://od.lk/d/NjNfOTg0NjQyNTRf/ft.png", AspectRatio = "16:9", Radius = 10 })
secImg:AddDivider()

local secVid = TabElements:AddSection("Video")
secVid:AddVideo({ Video = "rbxassetid://5670802294", AspectRatio = "16:9", Radius = 8, AutoPlay = false, Looped = true, Volume = 0.5 })
secVid:AddDivider()

local secAudio = TabElements:AddSection("Audio")
secAudio:AddAudio({
        Audio = "rbxassetid://142376088",
        Volume = 0.5,
        Looped = true,
        AutoPlay = false,
        AudioTitle = "Roblox Classic BGM",
        AudioSubtitle = "By Roblox",
        PlayOutsideWindow = false,
})
secAudio:AddAudio({
        Audio = "https://od.lk/d/NjNfODkwMDU1MDJf/hkmori%20-%20anybody%20can%20find%20love%20%28except%20you.%29%20%281%29.mp3",
        Volume = 0.4,
        Looped = true,
        AutoPlay = false,
        AudioTitle = "Anybody Can Find Love (Except You)",
        AudioSubtitle = "By hkmori",
        PlayOutsideWindow = true,
})
secAudio:AddAudio({
        Audio = "https://od.lk/d/NjNfOTg1Mjc4ODdf/kyszenn_-_Good_for_me_%28SkySound.cc%29.mp3",
        AudioTitle = "good for you",
        AudioSubtitle = "By kyszenn",
        Volume = 0.5,
        Looped = true,
        AutoPlay = false,
        PlayOutsideWindow = true,
})
secAudio:AddAudio({
        Audio = "https://od.lk/d/NjNfOTg1Mjc4ODhf/TARISHKA_-_Transformation_breakcore_%28SkySound.cc%29.mp3",
        AudioTitle = "Transformation (Breakcore)",
        AudioSubtitle = "By TARISHKAu",
        Volume = 0.5,
        Looped = true,
        AutoPlay = false,
        PlayOutsideWindow = true,
})
secAudio:AddAudio({
        Audio = "https://od.lk/d/NjNfOTg1Mjc4Nzdf/Removeface_Kyszenn_-_ON_THE_FLOOR_%28SkySound.cc%29%20%281%29.mp3",
        AudioTitle = "ON THE FLOOR!",
        AudioSubtitle = "",
        Volume = 0.5,
        Looped = true,
        AutoPlay = false,
        PlayOutsideWindow = true,
})
secAudio:AddDivider()

local secVP = TabElements:AddSection("Viewport")
local demoModel = Instance.new("Part")
demoModel.Shape = Enum.PartType.Ball
demoModel.Size = Vector3.new(4, 4, 4)
demoModel.BrickColor = BrickColor.new("Bright blue")
demoModel.Material = Enum.Material.Neon
demoModel.CFrame = CFrame.new(0, 0, 0)
demoModel.Anchored = true

local vpCamera = Instance.new("Camera")
vpCamera.CFrame = CFrame.new(Vector3.new(0, 3, 10), Vector3.new(0, 0, 0))

local vp = secVP:AddViewport({ Height = 200, Object = demoModel, Camera = vpCamera, Focused = true, Interactive = true })
secVP:AddButton({
        Title = "Swap to Red Cylinder",
        Icon = "solar/refresh-bold",
        Callback = function()
                local np = Instance.new("Part")
                np.Shape = Enum.PartType.Cylinder
                np.Size = Vector3.new(6, 3, 3)
                np.BrickColor = BrickColor.new("Bright red")
                np.Material = Enum.Material.SmoothPlastic
                np.Anchored = true
                vp:SetObject(np, false)
                vp:Focus()
                Fluent:Notify({ Title = "Viewport", Content = "Object swapped!", Type = "Info", Duration = 2 })
        end,
})
secVP:AddDivider()

local secFloating = TabElements:AddSection("Floating Button")
secFloating:AddToggle("FloatingBtnToggle", {
        Title = "Enable Floating Button",
        Icon = "solar/widget-bold",
        Default = false,
        Description = "Shows a draggable floating button overlay. Hold to lock/unlock. Long-hold to toggle circle mode.",
        Callback = function(v)
                if v then
                        if floatingGui then
                                floatingGui.Enabled = true
                        else
                                local floatingFrame, floatingButton, floatingApplyShape = CreateButton("FloatingOverlay", "text btw", 0.16, 0.12, function()
                                        Fluent:Notify({ Title = "Floating Button", Content = "Pressed!", Type = "Info", Duration = 2 })
                                end, false)
                                floatingGui = floatingFrame.Parent
                                floatingBtn = floatingButton
                                FloatingButtonManager:AddButton("FloatingOverlay", floatingButton, false, false, floatingApplyShape, floatingFrame)
                        end
                else
                        if floatingGui then
                                floatingGui.Enabled = false
                        end
                end
        end,
})
secFloating:AddDivider()

-- =================== COMPONENTS TAB (FROM MODED) ===================
local secUserInfo = TabComponents:AddSection("UserInfo")
secUserInfo:AddCode({
        Title = "UserInfo options in CreateWindow",
        Code = 'Fluent:CreateWindow({\n    UserInfoTop      = true,\n    UserInfoTitle    = "My Script",\n    UserInfoSubtitle = "v1.0.0",\n    UserInfoColor    = Color3.fromRGB(0, 180, 255),\n})',
        OnCopy = function() Fluent:Notify({ Title = "Code", Content = "Copied!", Duration = 2 }) end,
})
secUserInfo:AddDivider()

local secNotify = TabComponents:AddSection("Notifications")
secNotify:AddButton({ Title = "Info",    Icon = "solar/info-circle-bold",     Callback = function() Fluent:Notify({ Title = "Info",    Content = "Informational notification.",        Type = "Info",    Duration = 4 }) end })
secNotify:AddButton({ Title = "Success", Icon = "solar/check-circle-bold",    Callback = function() Fluent:Notify({ Title = "Success", Content = "Operation completed successfully!", Type = "Success", Duration = 4 }) end })
secNotify:AddButton({ Title = "Warning", Icon = "solar/danger-triangle-bold", Callback = function() Fluent:Notify({ Title = "Warning", Content = "Something might go wrong.",          Type = "Warning", Duration = 4 }) end })
secNotify:AddButton({ Title = "Error",   Icon = "solar/close-circle-bold",    Callback = function() Fluent:Notify({ Title = "Error",   Content = "An error occurred.",                Type = "Error",   Duration = 4 }) end })
secNotify:AddButton({
        Title = "With SubContent",
        Icon = "solar/document-bold",
        Callback = function() Fluent:Notify({ Title = "SubContent Demo", Content = "Main message line.", SubContent = "Secondary detail shown below.", Type = "Info", Duration = 5 }) end,
})
secNotify:AddDivider()

local secDialog = TabComponents:AddSection("Dialogs")
secDialog:AddButton({
        Title = "2-Button Confirm",
        Icon = "solar/chat-round-bold",
        Callback = function()
                Window:Dialog({
                        Title = "Confirm Action",
                        Content = "Are you sure you want to proceed?",
                        Buttons = {
                                { Title = "Yes", Callback = function() Fluent:Notify({ Title = "Dialog", Content = "Confirmed!", Type = "Success", Duration = 3 }) end },
                                { Title = "No",  Callback = function() Fluent:Notify({ Title = "Dialog", Content = "Cancelled.", Type = "Info",    Duration = 3 }) end },
                        },
                })
        end,
})
secDialog:AddButton({
        Title = "3-Button Save?",
        Icon = "solar/chat-round-dots-bold",
        Callback = function()
                Window:Dialog({
                        Title = "Save Changes?",
                        Content = "Do you want to save before closing?",
                        Buttons = {
                                { Title = "Save",    Callback = function() Fluent:Notify({ Title = "Dialog", Content = "Saved!",     Type = "Success", Duration = 3 }) end },
                                { Title = "Discard", Callback = function() Fluent:Notify({ Title = "Dialog", Content = "Discarded.", Type = "Warning", Duration = 3 }) end },
                                { Title = "Cancel" },
                        },
                })
        end,
})
secDialog:AddButton({
        Title = "Input Dialog",
        Icon = "solar/pen-bold",
        Callback = function()
                Window:Dialog({
                        Title = "Enter Value",
                        Content = "Type something in the field below:",
                        Input = { Placeholder = "Your input here…" },
                        Buttons = {
                                { Title = "Submit", Callback = function(v) Fluent:Notify({ Title = "Submitted", Content = tostring(v), Type = "Success", Duration = 4 }) end },
                                { Title = "Cancel" },
                        },
                })
        end,
})
secDialog:AddDivider()

local secGrp = TabComponents:AddSection("Group")
local grp2 = secGrp:AddGroup({ Columns = 2, Gap = 6 })
local col2A = grp2:AddElement()
local col2B = grp2:AddElement()
col2A:AddButton({ Title = "Left",  Icon = "solar/arrow-left-bold",  Callback = function() Fluent:Notify({ Title = "Group", Content = "Left",  Type = "Info",    Duration = 2 }) end })
col2B:AddButton({ Title = "Right", Icon = "solar/arrow-right-bold", Callback = function() Fluent:Notify({ Title = "Group", Content = "Right", Type = "Success", Duration = 2 }) end })
col2A:AddToggle("GrpTglA", { Title = "Toggle A", Default = false, Callback = function(v) Fluent:Notify({ Title = "A", Content = tostring(v), Duration = 2 }) end })
col2B:AddToggle("GrpTglB", { Title = "Toggle B", Default = false, Callback = function(v) Fluent:Notify({ Title = "B", Content = tostring(v), Duration = 2 }) end })
secGrp:AddDivider()

local secTheme = TabComponents:AddSection("Built-in Themes")
for _, name in ipairs({
        "AMOLED", "Ash Gray", "Blood Red", "Cyanic", "Amber Glow", "Deep Violet",
        "Neon Cyber", "Neon Purple", "Royal Blue", "Deep Ocean", "RGB", "Orange",
        "Charcoal", "Pearl White", "Midnight", "Galaxy Purple", "Cosmic Violet",
        "Cotton Candy", "Arctic Frost",
}) do
        local n = name
        secTheme:AddButton({
                Title = n,
                Icon = "solar/palette-bold",
                Callback = function()
                        Fluent:SetTheme(n)
                        Fluent:Notify({ Title = "Theme", Content = n .. " applied!", Type = "Info", Duration = 2 })
                end,
        })
end

local secCustomTheme = TabComponents:AddSection("Custom Themes")
secCustomTheme:AddButton({
        Title = "Apply NeonBlue",
        Icon = "solar/star-bold",
        Callback = function()
                Fluent:SetTheme("NeonBlue")
                Fluent:Notify({ Title = "Theme", Content = "NeonBlue applied!", Type = "Success", Duration = 2 })
        end,
})
secCustomTheme:AddButton({
        Title = "Apply EmeraldDark",
        Icon = "solar/leaf-bold",
        Callback = function()
                Fluent:SetTheme("EmeraldDark")
                Fluent:Notify({ Title = "Theme", Content = "EmeraldDark applied!", Type = "Success", Duration = 2 })
        end,
})
secCustomTheme:AddDivider()


-- =================== SETTINGS TAB ===================
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

local secAntiAFK = TabSettings:AddSection("Anti-AFK")

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

local sizeBackMulti = 0.3
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "RotatingBackground"
backgroundImage.Parent = mainBtn
backgroundImage.Size = UDim2.new(1.5 + sizeBackMulti, 0, 1.5 + sizeBackMulti, 0)
backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = "rbxassetid://92062295706713"
backgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
backgroundImage.ZIndex = 0

local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainBtn
frontImage.Size = UDim2.fromOffset(55, 55)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = "rbxassetid://126113649238951"
frontImage.ZIndex = 1
Instance.new("UICorner", frontImage).CornerRadius = UDim.new(0.2, 0)

local rotation = 0
local rotSpeed = 90
local lastTime = tick()
task.spawn(function()
        while true do
                local now = tick()
                local delta = now - lastTime
                lastTime = now
                rotation = (rotation + rotSpeed * delta) % 360
                backgroundImage.Rotation = rotation
                task.wait()
        end
end)

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
local function playSound(soundId)
        local sound = Instance.new("Sound")
        pcall(function() sound.SoundId = "rbxassetid://" .. soundId end)
        sound.Parent = game:GetService("SoundService")
        pcall(function() sound:Play() end)
        sound.Ended:Connect(function() sound:Destroy() end)
end

mainBtn.MouseButton1Click:Connect(function()
        local sounds = { "7127123605", "438666542" }
        playSound(sounds[math.random(#sounds)])
        uiOpen = not uiOpen
        if uiOpen then Window:Show() else Window:Hide() end
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
end)

FloatingButtonManager:AddButton("OpenUiBtn", mainBtn, false, false, nil, mainBtn)
FloatingButtonManager:BuildConfigSection(TabSettings)
FloatingButtonManager:LoadAutoloadConfig()

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

-- =================== FINALIZE ===================
Fluent:Notify({ Title = "Hakuna Hub + FluentPro", Content = "Fully loaded! Enjoy the best of both worlds.", Type = "Success", Duration = 4 })
task.delay(0.5, function()
        Window:SelectTab(1)
end)
