-- ROBLOX UI SCRIPT - DARK NEON THEME (MOBILE-FRIENDLY)
-- Features: WalkSpeed, Unlimited Jump, Fly, NoClip, Waypoints, ClickTeleport, FPS, Keybind
-- Logic: Exact CFrame teleport + Manual key capture system

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local State = {
    isUnlimitedJump = false,
    isFlying = false,
    isNoclip = false,
    isClickTeleport = false,
    isFPSVisible = false,
    waypointCFrame = nil,
    isWaitingForKey = false,
    waypointKey = Enum.KeyCode.E,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,
    connections = {},
    toggleKey = Enum.KeyCode.RightShift,
    currentWalkSpeed = 16,
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
    LoadingSubtitle = "Dark Neon Theme | Mobile-Friendly",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "Config",
    },
})

local MainTab = Window:CreateTab("Main", 4483362458)
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

-- WALKSPEED
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
end)

-- UNLIMITED JUMP
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

-- FLY
MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        State.isFlying = v
        if v then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.P = 1e4
            bv.Parent = root
            State.flyBodyVelocity = bv
            
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1e4
            bg.CFrame = root.CFrame
            bg.Parent = root
            State.flyBodyGyro = bg
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Falling, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
            
            State.connections["flyLoop"] = RunService.Heartbeat:Connect(function()
                if not State.isFlying then return end
                local c2 = LocalPlayer.Character
                if not c2 then return end
                local r2 = c2:FindFirstChild("HumanoidRootPart")
                if not r2 then return end
                local cam = workspace.CurrentCamera
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                if move.Magnitude > 0 then move = move.Unit * 50 end
                if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
                    State.flyBodyVelocity.Velocity = move
                end
                if State.flyBodyGyro and State.flyBodyGyro.Parent then
                    State.flyBodyGyro.CFrame = CFrame.new(r2.Position, r2.Position + cam.CFrame.LookVector)
                end
            end)
        else
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
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                hum:SetStateEnabled(Enum.HumanoidStateType.Falling, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end,
})

-- NOCLIP
MainTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(v)
        State.isNoclip = v
        if v then
            State.connections["noclipLoop"] = RunService.Stepped:Connect(function()
                if not State.isNoclip then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            Disconnect("noclipLoop")
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

-- ==========================================
-- WAYPOINT SYSTEM (YOUR EXACT LOGIC)
-- ==========================================
MainTab:CreateSection("Waypoint")

-- Set Waypoint
MainTab:CreateButton({
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
        
        -- EXACT LOGIC: Save CFrame (position + rotation)
        State.waypointCFrame = root.CFrame
        Notify("Waypoint", "Waypoint Set", 2)
    end,
})

-- Teleport to Waypoint
MainTab:CreateButton({
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
        
        -- EXACT LOGIC: Direct CFrame assignment (no offset, no jump)
        root.CFrame = State.waypointCFrame
    end,
})

-- Keybind Display
local keybindLabel = MainTab:CreateLabel("Keybind: [E]")

-- Change Keybind Button
MainTab:CreateButton({
    Name = "Change Keybind",
    Callback = function()
        State.isWaitingForKey = true
        keybindLabel:Set("Press any key...")
        Notify("Keybind", "Press any key...", 2)
    end,
})

-- CLICK TELEPORT
MainTab:CreateToggle({
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

-- ==========================================
-- SETTINGS TAB
-- ==========================================
SettingsTab:CreateSection("Display")

-- FPS Counter
local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "FPSCounterGui"
FPSGui.ResetOnSpawn = false
FPSGui.DisplayOrder = 999

pcall(function() FPSGui.Parent = game:GetService("CoreGui") end)
if not FPSGui.Parent then
    FPSGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local FPSFrame = Instance.new("Frame")
FPSFrame.Size = UDim2.new(0, 100, 0, 30)
FPSFrame.Position = UDim2.new(1, -110, 0, 10)
FPSFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
FPSFrame.BackgroundTransparency = 0.3
FPSFrame.BorderSizePixel = 0
FPSFrame.Visible = false
FPSFrame.Parent = FPSGui

Instance.new("UICorner", FPSFrame).CornerRadius = UDim.new(0, 8)

local fpStroke = Instance.new("UIStroke", FPSFrame)
fpStroke.Color = Color3.fromRGB(0, 255, 255)
fpStroke.Thickness = 1.5

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1,0,1,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(0,255,255)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.GothamBold
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
        if fps >= 55 then
            FPSLabel.TextColor3 = Color3.fromRGB(0,255,150)
            fpStroke.Color = Color3.fromRGB(0,255,150)
        elseif fps >= 30 then
            FPSLabel.TextColor3 = Color3.fromRGB(255,200,0)
            fpStroke.Color = Color3.fromRGB(255,200,0)
        else
            FPSLabel.TextColor3 = Color3.fromRGB(255,50,50)
            fpStroke.Color = Color3.fromRGB(255,50,50)
        end
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

-- KEYBIND SETTINGS
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

-- ==========================================
-- GLOBAL INPUT HANDLER (YOUR EXACT LOGIC)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- KEYBIND SETTER (Press any key...)
    if State.isWaitingForKey then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            State.waypointKey = input.KeyCode
            keybindLabel:Set("Keybind: [" .. input.KeyCode.Name .. "]")
            State.isWaitingForKey = false
            Notify("Keybind", "Keybind set to: " .. input.KeyCode.Name, 2)
        end
        return
    end
    
    -- WAYPOINT TELEPORT (Exact logic from your script)
    if input.KeyCode == State.waypointKey and State.waypointCFrame then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- EXACT CFRAME TELEPORT (No offset, no jump)
        root.CFrame = State.waypointCFrame
    end
    
    -- TOGGLE UI
    if input.KeyCode == State.toggleKey then
        pcall(function() Rayfield:HideGui() end)
        pcall(function() Rayfield:ShowGui() end)
    end
end)

-- CHARACTER RESPAWN HANDLER
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    -- Reapply walkspeed
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.currentWalkSpeed
    end
    
    -- Reconnect unlimited jump
    if State.isUnlimitedJump then
        Disconnect("unlimitedJump")
        State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChildOfClass("Humanoid") then
                c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
    
    -- Reconnect noclip
    if State.isNoclip then
        Disconnect("noclipLoop")
        State.connections["noclipLoop"] = RunService.Stepped:Connect(function()
            if not State.isNoclip then return end
            local c = LocalPlayer.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end)

print("Hakuna Hub Loaded")
print("RightShift - Toggle UI")
print("E - Waypoint Teleport (Default)")
task.wait(2)
Notify("Loaded", "Press RightShift to toggle UI", 5)

--save

