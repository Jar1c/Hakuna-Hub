-- -- -- ROBLOX UI SCRIPT - DARK NEON THEME (MOBILE-FRIENDLY)
-- -- -- Features: WalkSpeed, Unlimited Jump, Fly, NoClip, Waypoints, ClickTeleport, FPS, Keybind
-- -- -- Logic: Exact CFrame teleport + Manual key capture system

-- -- local Players = game:GetService("Players")
-- -- local RunService = game:GetService("RunService")
-- -- local UserInputService = game:GetService("UserInputService")
-- -- local LocalPlayer = Players.LocalPlayer
-- -- local Mouse = LocalPlayer:GetMouse()

-- -- local State = {
-- --     isUnlimitedJump = false,
-- --     isFlying = false,
-- --     isNoclip = false,
-- --     isClickTeleport = false,
-- --     isFPSVisible = false,
-- --     waypointCFrame = nil,
-- --     isWaitingForKey = false,
-- --     waypointKey = Enum.KeyCode.E,
-- --     flyBodyVelocity = nil,
-- --     flyBodyGyro = nil,
-- --     connections = {},
-- --     toggleKey = Enum.KeyCode.RightShift,
-- --     currentWalkSpeed = 16,
-- -- }

-- -- local Rayfield
-- -- local urls = {
-- --     "https://sirius.menu/rayfield",
-- --     "https://raw.githubusercontent.com/SiriusXT/Rayfield/main/source.lua",
-- -- }

-- -- for _, url in ipairs(urls) do
-- --     local success, lib = pcall(function()
-- --         return loadstring(game:HttpGet(url))()
-- --     end)
-- --     if success and type(lib) == "table" and lib.CreateWindow then
-- --         Rayfield = lib
-- --         break
-- --     end
-- -- end

-- -- if not Rayfield then
-- --     error("Failed to load Rayfield")
-- -- end

-- -- local Window = Rayfield:CreateWindow({
-- --     Name = "Hakuna Hub",
-- --     LoadingTitle = "Hakuna Hub",
-- --     LoadingSubtitle = "Dark Neon Theme | Mobile-Friendly",
-- --     Theme = "Default",
-- --     DisableRayfieldPrompts = false,
-- --     ConfigurationSaving = {
-- --         Enabled = true,
-- --         FolderName = "UniversalHub",
-- --         FileName = "Config",
-- --     },
-- -- })

-- -- local MainTab = Window:CreateTab("Main", 4483362458)
-- -- local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- -- local function Notify(title, content, duration)
-- --     pcall(function()
-- --         Rayfield:Notify({
-- --             Title = tostring(title),
-- --             Content = tostring(content),
-- --             Duration = duration or 3,
-- --             Image = 4483362458,
-- --         })
-- --     end)
-- -- end

-- -- local function Disconnect(key)
-- --     if State.connections[key] then
-- --         if State.connections[key].Connected then
-- --             State.connections[key]:Disconnect()
-- --         end
-- --         State.connections[key] = nil
-- --     end
-- -- end

-- -- -- WALKSPEED
-- -- MainTab:CreateSlider({
-- --     Name = "WalkSpeed",
-- --     Range = {16, 200},
-- --     Increment = 1,
-- --     Suffix = " Speed",
-- --     CurrentValue = 16,
-- --     Callback = function(v)
-- --         State.currentWalkSpeed = v
-- --         local char = LocalPlayer.Character
-- --         if char and char:FindFirstChildOfClass("Humanoid") then
-- --             char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
-- --         end
-- --     end,
-- -- })

-- -- LocalPlayer.CharacterAdded:Connect(function(char)
-- --     task.wait(0.5)
-- --     local hum = char:FindFirstChildOfClass("Humanoid")
-- --     if hum then
-- --         hum.WalkSpeed = State.currentWalkSpeed
-- --     end
-- -- end)

-- -- -- UNLIMITED JUMP
-- -- MainTab:CreateToggle({
-- --     Name = "Unlimited Jump",
-- --     CurrentValue = false,
-- --     Callback = function(v)
-- --         State.isUnlimitedJump = v
-- --         if v then
-- --             State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
-- --                 local char = LocalPlayer.Character
-- --                 if char and char:FindFirstChildOfClass("Humanoid") then
-- --                     char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
-- --                 end
-- --             end)
-- --         else
-- --             Disconnect("unlimitedJump")
-- --         end
-- --     end,
-- -- })

-- -- -- FLY
-- -- MainTab:CreateToggle({
-- --     Name = "Fly",
-- --     CurrentValue = false,
-- --     Callback = function(v)
-- --         State.isFlying = v
-- --         if v then
-- --             local char = LocalPlayer.Character
-- --             if not char or not char:FindFirstChild("HumanoidRootPart") then return end
-- --             local root = char:FindFirstChild("HumanoidRootPart")
            
-- --             local bv = Instance.new("BodyVelocity")
-- --             bv.Velocity = Vector3.zero
-- --             bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
-- --             bv.P = 1e4
-- --             bv.Parent = root
-- --             State.flyBodyVelocity = bv
            
-- --             local bg = Instance.new("BodyGyro")
-- --             bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
-- --             bg.P = 1e4
-- --             bg.CFrame = root.CFrame
-- --             bg.Parent = root
-- --             State.flyBodyGyro = bg
            
-- --             local hum = char:FindFirstChildOfClass("Humanoid")
-- --             if hum then
-- --                 hum:SetStateEnabled(Enum.HumanoidStateType.Falling, false)
-- --                 hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
-- --                 hum:ChangeState(Enum.HumanoidStateType.Physics)
-- --             end
            
-- --             State.connections["flyLoop"] = RunService.Heartbeat:Connect(function()
-- --                 if not State.isFlying then return end
-- --                 local c2 = LocalPlayer.Character
-- --                 if not c2 then return end
-- --                 local r2 = c2:FindFirstChild("HumanoidRootPart")
-- --                 if not r2 then return end
-- --                 local cam = workspace.CurrentCamera
-- --                 local move = Vector3.zero
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
-- --                 if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
-- --                 if move.Magnitude > 0 then move = move.Unit * 50 end
-- --                 if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
-- --                     State.flyBodyVelocity.Velocity = move
-- --                 end
-- --                 if State.flyBodyGyro and State.flyBodyGyro.Parent then
-- --                     State.flyBodyGyro.CFrame = CFrame.new(r2.Position, r2.Position + cam.CFrame.LookVector)
-- --                 end
-- --             end)
-- --         else
-- --             Disconnect("flyLoop")
-- --             if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
-- --                 State.flyBodyVelocity:Destroy()
-- --                 State.flyBodyVelocity = nil
-- --             end
-- --             if State.flyBodyGyro and State.flyBodyGyro.Parent then
-- --                 State.flyBodyGyro:Destroy()
-- --                 State.flyBodyGyro = nil
-- --             end
-- --             local char = LocalPlayer.Character
-- --             if char and char:FindFirstChildOfClass("Humanoid") then
-- --                 local hum = char:FindFirstChildOfClass("Humanoid")
-- --                 hum:SetStateEnabled(Enum.HumanoidStateType.Falling, true)
-- --                 hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
-- --                 hum:ChangeState(Enum.HumanoidStateType.GettingUp)
-- --             end
-- --         end
-- --     end,
-- -- })

-- -- -- NOCLIP
-- -- MainTab:CreateToggle({
-- --     Name = "No Clip",
-- --     CurrentValue = false,
-- --     Callback = function(v)
-- --         State.isNoclip = v
-- --         if v then
-- --             State.connections["noclipLoop"] = RunService.Stepped:Connect(function()
-- --                 if not State.isNoclip then return end
-- --                 local char = LocalPlayer.Character
-- --                 if not char then return end
-- --                 for _, p in ipairs(char:GetDescendants()) do
-- --                     if p:IsA("BasePart") then p.CanCollide = false end
-- --                 end
-- --             end)
-- --         else
-- --             Disconnect("noclipLoop")
-- --             local char = LocalPlayer.Character
-- --             if char then
-- --                 for _, p in ipairs(char:GetDescendants()) do
-- --                     if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
-- --                         p.CanCollide = true
-- --                     end
-- --                 end
-- --             end
-- --         end
-- --     end,
-- -- })

-- -- -- ==========================================
-- -- -- WAYPOINT SYSTEM (YOUR EXACT LOGIC)
-- -- -- ==========================================
-- -- MainTab:CreateSection("Waypoint")

-- -- -- Set Waypoint
-- -- MainTab:CreateButton({
-- --     Name = "Set Waypoint",
-- --     Callback = function()
-- --         local char = LocalPlayer.Character
-- --         if not char then
-- --             Notify("Error", "Character not found", 2)
-- --             return
-- --         end
-- --         local root = char:FindFirstChild("HumanoidRootPart")
-- --         if not root then
-- --             Notify("Error", "HumanoidRootPart not found", 2)
-- --             return
-- --         end
        
-- --         -- EXACT LOGIC: Save CFrame (position + rotation)
-- --         State.waypointCFrame = root.CFrame
-- --         Notify("Waypoint", "Waypoint Set", 2)
-- --     end,
-- -- })

-- -- -- Teleport to Waypoint
-- -- MainTab:CreateButton({
-- --     Name = "Teleport to Waypoint",
-- --     Callback = function()
-- --         if not State.waypointCFrame then
-- --             Notify("Error", "No Waypoint Set", 2)
-- --             return
-- --         end
        
-- --         local char = LocalPlayer.Character
-- --         if not char then
-- --             Notify("Error", "Character not found", 2)
-- --             return
-- --         end
-- --         local root = char:FindFirstChild("HumanoidRootPart")
-- --         if not root then
-- --             Notify("Error", "HumanoidRootPart not found", 2)
-- --             return
-- --         end
        
-- --         -- EXACT LOGIC: Direct CFrame assignment (no offset, no jump)
-- --         root.CFrame = State.waypointCFrame
-- --     end,
-- -- })

-- -- -- Keybind Display
-- -- local keybindLabel = MainTab:CreateLabel("Keybind: [E]")

-- -- -- Change Keybind Button
-- -- MainTab:CreateButton({
-- --     Name = "Change Keybind",
-- --     Callback = function()
-- --         State.isWaitingForKey = true
-- --         keybindLabel:Set("Press any key...")
-- --         Notify("Keybind", "Press any key...", 2)
-- --     end,
-- -- })

-- -- -- CLICK TELEPORT
-- -- MainTab:CreateToggle({
-- --     Name = "Click-to-Teleport (Ctrl + Click)",
-- --     CurrentValue = false,
-- --     Callback = function(v)
-- --         State.isClickTeleport = v
-- --         if v then
-- --             State.connections["clickTeleport"] = Mouse.Button1Down:Connect(function()
-- --                 if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
-- --                     return
-- --                 end
-- --                 local char = LocalPlayer.Character
-- --                 if char and char:FindFirstChild("HumanoidRootPart") then
-- --                     char:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)))
-- --                 end
-- --             end)
-- --         else
-- --             Disconnect("clickTeleport")
-- --         end
-- --     end,
-- -- })

-- -- -- ==========================================
-- -- -- SETTINGS TAB
-- -- -- ==========================================
-- -- SettingsTab:CreateSection("Display")

-- -- -- FPS Counter
-- -- local FPSGui = Instance.new("ScreenGui")
-- -- FPSGui.Name = "FPSCounterGui"
-- -- FPSGui.ResetOnSpawn = false
-- -- FPSGui.DisplayOrder = 999

-- -- pcall(function() FPSGui.Parent = game:GetService("CoreGui") end)
-- -- if not FPSGui.Parent then
-- --     FPSGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
-- -- end

-- -- local FPSFrame = Instance.new("Frame")
-- -- FPSFrame.Size = UDim2.new(0, 100, 0, 30)
-- -- FPSFrame.Position = UDim2.new(1, -110, 0, 10)
-- -- FPSFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
-- -- FPSFrame.BackgroundTransparency = 0.3
-- -- FPSFrame.BorderSizePixel = 0
-- -- FPSFrame.Visible = false
-- -- FPSFrame.Parent = FPSGui

-- -- Instance.new("UICorner", FPSFrame).CornerRadius = UDim.new(0, 8)

-- -- local fpStroke = Instance.new("UIStroke", FPSFrame)
-- -- fpStroke.Color = Color3.fromRGB(0, 255, 255)
-- -- fpStroke.Thickness = 1.5

-- -- local FPSLabel = Instance.new("TextLabel")
-- -- FPSLabel.Size = UDim2.new(1,0,1,0)
-- -- FPSLabel.BackgroundTransparency = 1
-- -- FPSLabel.Text = "FPS: --"
-- -- FPSLabel.TextColor3 = Color3.fromRGB(0,255,255)
-- -- FPSLabel.TextSize = 14
-- -- FPSLabel.Font = Enum.Font.GothamBold
-- -- FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
-- -- FPSLabel.Parent = FPSFrame

-- -- local lastFPSTime = tick()
-- -- local frameCount = 0

-- -- State.connections["fpsUpdate"] = RunService.RenderStepped:Connect(function()
-- --     if not State.isFPSVisible then return end
-- --     frameCount = frameCount + 1
-- --     local now = tick()
-- --     if now - lastFPSTime >= 0.5 then
-- --         local fps = math.floor(frameCount / (now - lastFPSTime))
-- --         frameCount = 0
-- --         lastFPSTime = now
-- --         FPSLabel.Text = "FPS: " .. fps
-- --         if fps >= 55 then
-- --             FPSLabel.TextColor3 = Color3.fromRGB(0,255,150)
-- --             fpStroke.Color = Color3.fromRGB(0,255,150)
-- --         elseif fps >= 30 then
-- --             FPSLabel.TextColor3 = Color3.fromRGB(255,200,0)
-- --             fpStroke.Color = Color3.fromRGB(255,200,0)
-- --         else
-- --             FPSLabel.TextColor3 = Color3.fromRGB(255,50,50)
-- --             fpStroke.Color = Color3.fromRGB(255,50,50)
-- --         end
-- --     end
-- -- end)

-- -- SettingsTab:CreateToggle({
-- --     Name = "Show FPS Counter",
-- --     CurrentValue = false,
-- --     Callback = function(v)
-- --         State.isFPSVisible = v
-- --         FPSFrame.Visible = v
-- --         lastFPSTime = tick()
-- --         frameCount = 0
-- --         FPSLabel.Text = "FPS: --"
-- --     end,
-- -- })

-- -- -- KEYBIND SETTINGS
-- -- SettingsTab:CreateSection("Keybinds")

-- -- SettingsTab:CreateKeybind({
-- --     Name = "Toggle UI Keybind",
-- --     CurrentKeybind = "RightShift",
-- --     HoldToInteract = false,
-- --     Callback = function(keybind)
-- --         local ok, key = pcall(function() return Enum.KeyCode[keybind] end)
-- --         if ok and key then
-- --             State.toggleKey = key
-- --             Notify("Keybind", "Toggle UI key set to: " .. keybind, 3)
-- --         end
-- --     end,
-- -- })

-- -- -- ==========================================
-- -- -- GLOBAL INPUT HANDLER (YOUR EXACT LOGIC)
-- -- -- ==========================================
-- -- UserInputService.InputBegan:Connect(function(input, gameProcessed)
-- --     if gameProcessed then return end
    
-- --     -- KEYBIND SETTER (Press any key...)
-- --     if State.isWaitingForKey then
-- --         if input.KeyCode ~= Enum.KeyCode.Unknown then
-- --             State.waypointKey = input.KeyCode
-- --             keybindLabel:Set("Keybind: [" .. input.KeyCode.Name .. "]")
-- --             State.isWaitingForKey = false
-- --             Notify("Keybind", "Keybind set to: " .. input.KeyCode.Name, 2)
-- --         end
-- --         return
-- --     end
    
-- --     -- WAYPOINT TELEPORT (Exact logic from your script)
-- --     if input.KeyCode == State.waypointKey and State.waypointCFrame then
-- --         local char = LocalPlayer.Character
-- --         if not char then return end
-- --         local root = char:FindFirstChild("HumanoidRootPart")
-- --         if not root then return end
        
-- --         -- EXACT CFRAME TELEPORT (No offset, no jump)
-- --         root.CFrame = State.waypointCFrame
-- --     end
    
-- --     -- TOGGLE UI
-- --     if input.KeyCode == State.toggleKey then
-- --         pcall(function() Rayfield:HideGui() end)
-- --         pcall(function() Rayfield:ShowGui() end)
-- --     end
-- -- end)

-- -- -- CHARACTER RESPAWN HANDLER
-- -- LocalPlayer.CharacterAdded:Connect(function(char)
-- --     task.wait(0.5)
    
-- --     -- Reapply walkspeed
-- --     local hum = char:FindFirstChildOfClass("Humanoid")
-- --     if hum then
-- --         hum.WalkSpeed = State.currentWalkSpeed
-- --     end
    
-- --     -- Reconnect unlimited jump
-- --     if State.isUnlimitedJump then
-- --         Disconnect("unlimitedJump")
-- --         State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
-- --             local c = LocalPlayer.Character
-- --             if c and c:FindFirstChildOfClass("Humanoid") then
-- --                 c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
-- --             end
-- --         end)
-- --     end
    
-- --     -- Reconnect noclip
-- --     if State.isNoclip then
-- --         Disconnect("noclipLoop")
-- --         State.connections["noclipLoop"] = RunService.Stepped:Connect(function()
-- --             if not State.isNoclip then return end
-- --             local c = LocalPlayer.Character
-- --             if not c then return end
-- --             for _, p in ipairs(c:GetDescendants()) do
-- --                 if p:IsA("BasePart") then p.CanCollide = false end
-- --             end
-- --         end)
-- --     end
-- -- end)

-- -- print("Hakuna Hub Loaded")
-- -- print("RightShift - Toggle UI")
-- -- print("E - Waypoint Teleport (Default)")
-- -- task.wait(2)
-- -- Notify("Loaded", "Press RightShift to toggle UI", 5)

-- -- --save



































-- -- ROBLOX UI SCRIPT - DARK NEON THEME (MOBILE-FRIENDLY)
-- -- Features: WalkSpeed, Unlimited Jump, Fly, NoClip (Self + Global), Waypoints, ClickTeleport, FPS, Anti-AFK, Mobile Buttons, Keybinds
-- -- Logic: Exact CFrame teleport + Manual key capture system

-- local Players = game:GetService("Players")
-- local RunService = game:GetService("RunService")
-- local UserInputService = game:GetService("UserInputService")
-- local TweenService = game:GetService("TweenService")
-- local VirtualUser = game:GetService("VirtualUser")
-- local LocalPlayer = Players.LocalPlayer
-- local Mouse = LocalPlayer:GetMouse()

-- local State = {
--     isUnlimitedJump = false,
--     isFlying = false,
--     isSelfNoclip = false,
--     isGlobalNoclip = false,
--     isClickTeleport = false,
--     isFPSVisible = false,
--     isAntiAFK = false,
--     waypointCFrame = nil,
--     isWaitingForKey = false,
--     waypointKey = Enum.KeyCode.E,
--     flyBodyVelocity = nil,
--     flyBodyGyro = nil,
--     flyKey = Enum.KeyCode.Q,
--     flySpeed = 50,
--     connections = {},
--     toggleKey = Enum.KeyCode.RightShift,
--     currentWalkSpeed = 16,
--     flyToggleObj = nil,
--     globalNoclipPlayers = {},
-- }

-- local Rayfield
-- local urls = {
--     "https://sirius.menu/rayfield",
--     "https://raw.githubusercontent.com/SiriusXT/Rayfield/main/source.lua",
-- }

-- for _, url in ipairs(urls) do
--     local success, lib = pcall(function()
--         return loadstring(game:HttpGet(url))()
--     end)
--     if success and type(lib) == "table" and lib.CreateWindow then
--         Rayfield = lib
--         break
--     end
-- end

-- if not Rayfield then
--     error("Failed to load Rayfield")
-- end

-- local Window = Rayfield:CreateWindow({
--     Name = "Hakuna Hub",
--     LoadingTitle = "Hakuna Hub",
--     LoadingSubtitle = "Dark Neon Theme | Mobile-Friendly",
--     Theme = "Default",
--     DisableRayfieldPrompts = false,
--     ConfigurationSaving = {
--         Enabled = true,
--         FolderName = "UniversalHub",
--         FileName = "Config",
--     },
-- })

-- local MainTab = Window:CreateTab("Main", 4483362458)
-- local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- local function Notify(title, content, duration)
--     pcall(function()
--         Rayfield:Notify({
--             Title = tostring(title),
--             Content = tostring(content),
--             Duration = duration or 3,
--             Image = 4483362458,
--         })
--     end)
-- end

-- local function Disconnect(key)
--     if State.connections[key] then
--         if State.connections[key].Connected then
--             State.connections[key]:Disconnect()
--         end
--         State.connections[key] = nil
--     end
-- end

-- -- =================== WALKSPEED ===================
-- MainTab:CreateSlider({
--     Name = "WalkSpeed",
--     Range = {16, 200},
--     Increment = 1,
--     Suffix = " Speed",
--     CurrentValue = 16,
--     Callback = function(v)
--         State.currentWalkSpeed = v
--         local char = LocalPlayer.Character
--         if char and char:FindFirstChildOfClass("Humanoid") then
--             char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
--         end
--     end,
-- })

-- LocalPlayer.CharacterAdded:Connect(function(char)
--     task.wait(0.5)
--     local hum = char:FindFirstChildOfClass("Humanoid")
--     if hum then
--         hum.WalkSpeed = State.currentWalkSpeed
--     end
--     if State.isFlying then
--         task.wait(0.3)
--         StartFly()
--     end
-- end)

-- -- =================== UNLIMITED JUMP ===================
-- MainTab:CreateToggle({
--     Name = "Unlimited Jump",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isUnlimitedJump = v
--         if v then
--             State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
--                 local char = LocalPlayer.Character
--                 if char and char:FindFirstChildOfClass("Humanoid") then
--                     char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
--                 end
--             end)
--         else
--             Disconnect("unlimitedJump")
--         end
--     end,
-- })

-- -- =================== FLY (IMPROVED LOGIC) ===================
-- MainTab:CreateSection("Fly")

-- MainTab:CreateSlider({
--     Name = "Fly Speed",
--     Range = {10, 300},
--     Increment = 5,
--     Suffix = " Speed",
--     CurrentValue = 50,
--     Callback = function(v)
--         State.flySpeed = v
--     end,
-- })

-- local flyKeyLabel = MainTab:CreateLabel("Fly Key: [Q]")
-- MainTab:CreateButton({
--     Name = "Change Fly Key",
--     Callback = function()
--         State.isWaitingForKey = "flyKey"
--         flyKeyLabel:Set("Fly Key: [Press any key...]")
--         Notify("Fly Key", "Press any key...", 2)
--     end,
-- })

-- local function StartFly()
--     local char = LocalPlayer.Character
--     if not char then return end
--     local root = char:FindFirstChild("HumanoidRootPart")
--     if not root then return end
--     local hum = char:FindFirstChildOfClass("Humanoid")
--     if not hum then return end

--     hum.PlatformStand = true

--     if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
--         State.flyBodyVelocity:Destroy()
--     end
--     if State.flyBodyGyro and State.flyBodyGyro.Parent then
--         State.flyBodyGyro:Destroy()
--     end

--     local bv = Instance.new("BodyVelocity")
--     bv.Velocity = Vector3.zero
--     bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
--     bv.P = 9e4
--     bv.Parent = root
--     State.flyBodyVelocity = bv

--     local bg = Instance.new("BodyGyro")
--     bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
--     bg.P = 9e4
--     bg.D = 100
--     bg.CFrame = root.CFrame
--     bg.Parent = root
--     State.flyBodyGyro = bg

--     Disconnect("flyLoop")
--     State.connections["flyLoop"] = RunService.RenderStepped:Connect(function()
--         if not State.isFlying then return end
--         local char = LocalPlayer.Character
--         if not char then return end
--         local root = char:FindFirstChild("HumanoidRootPart")
--         if not root then return end
--         local cam = workspace.CurrentCamera

--         local move = Vector3.zero
--         if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
--         if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
--         if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
--         if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
--         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
--         if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
--             move -= Vector3.new(0, 1, 0)
--         end

--         if move.Magnitude > 0 then
--             move = move.Unit * State.flySpeed
--         else
--             move = Vector3.zero
--         end

--         if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
--             State.flyBodyVelocity.Velocity = move
--         end
--         if State.flyBodyGyro and State.flyBodyGyro.Parent then
--             State.flyBodyGyro.CFrame = cam.CFrame
--         end
--     end)

--     UpdateMobileFlyButton() -- Update mobile button appearance
--     Notify("Fly", "Fly Enabled", 2)
-- end

-- local function StopFly()
--     State.isFlying = false
--     Disconnect("flyLoop")

--     if State.flyBodyVelocity and State.flyBodyVelocity.Parent then
--         State.flyBodyVelocity:Destroy()
--         State.flyBodyVelocity = nil
--     end
--     if State.flyBodyGyro and State.flyBodyGyro.Parent then
--         State.flyBodyGyro:Destroy()
--         State.flyBodyGyro = nil
--     end

--     local char = LocalPlayer.Character
--     if char then
--         local hum = char:FindFirstChildOfClass("Humanoid")
--         if hum then
--             hum.PlatformStand = false
--             hum:ChangeState(Enum.HumanoidStateType.GettingUp)
--         end
--     end

--     UpdateMobileFlyButton()
--     Notify("Fly", "Fly Disabled", 2)
-- end

-- local flyUIToggle = MainTab:CreateToggle({
--     Name = "Enable Fly",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isFlying = v
--         if v then
--             StartFly()
--         else
--             StopFly()
--         end
--     end,
-- })
-- State.flyToggleObj = flyUIToggle

-- -- =================== NOCLIP (SELF) ===================
-- MainTab:CreateSection("NoClip")
-- MainTab:CreateToggle({
--     Name = "Self NoClip",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isSelfNoclip = v
--         if v then
--             State.connections["selfNoclipLoop"] = RunService.Stepped:Connect(function()
--                 if not State.isSelfNoclip then return end
--                 local char = LocalPlayer.Character
--                 if not char then return end
--                 for _, p in ipairs(char:GetDescendants()) do
--                     if p:IsA("BasePart") then p.CanCollide = false end
--                 end
--             end)
--         else
--             Disconnect("selfNoclipLoop")
--             local char = LocalPlayer.Character
--             if char then
--                 for _, p in ipairs(char:GetDescendants()) do
--                     if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
--                         p.CanCollide = true
--                     end
--                 end
--             end
--         end
--     end,
-- })

-- -- =================== NOCLIP (GLOBAL / OTHERS) ===================
-- local function disableCollision(part)
--     if part:IsA("BasePart") and part.CanCollide then
--         part.CanCollide = false
--     end
-- end

-- local function trackCharacter(char)
--     for _, part in ipairs(char:GetChildren()) do
--         disableCollision(part)
--     end
--     char.ChildAdded:Connect(function(child)
--         disableCollision(child)
--     end)
-- end

-- local function trackPlayer(player)
--     if player == LocalPlayer then return end
--     if player.Character then
--         trackCharacter(player.Character)
--     end
--     player.CharacterAdded:Connect(trackCharacter)
--     State.globalNoclipPlayers[player] = true
-- end

-- MainTab:CreateToggle({
--     Name = "Global NoCollide (Others)",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isGlobalNoclip = v
--         if v then
--             for _, player in ipairs(Players:GetPlayers()) do
--                 trackPlayer(player)
--             end
--             State.connections["globalNoclipPlayerAdded"] = Players.PlayerAdded:Connect(trackPlayer)
--             State.connections["globalNoclipLoop"] = RunService.RenderStepped:Connect(function()
--                 if not State.isGlobalNoclip then return end
--                 for player, _ in pairs(State.globalNoclipPlayers) do
--                     local char = player.Character
--                     if char then
--                         for _, part in ipairs(char:GetChildren()) do
--                             disableCollision(part)
--                         end
--                     end
--                 end
--             end)
--         else
--             Disconnect("globalNoclipPlayerAdded")
--             Disconnect("globalNoclipLoop")
--             State.globalNoclipPlayers = {}
--         end
--     end,
-- })

-- -- =================== WAYPOINT SYSTEM ===================
-- MainTab:CreateSection("Waypoint")

-- MainTab:CreateButton({
--     Name = "Set Waypoint",
--     Callback = function()
--         local char = LocalPlayer.Character
--         if not char then
--             Notify("Error", "Character not found", 2)
--             return
--         end
--         local root = char:FindFirstChild("HumanoidRootPart")
--         if not root then
--             Notify("Error", "HumanoidRootPart not found", 2)
--             return
--         end
--         State.waypointCFrame = root.CFrame
--         Notify("Waypoint", "Waypoint Set", 2)
--     end,
-- })

-- MainTab:CreateButton({
--     Name = "Teleport to Waypoint",
--     Callback = function()
--         if not State.waypointCFrame then
--             Notify("Error", "No Waypoint Set", 2)
--             return
--         end
--         local char = LocalPlayer.Character
--         if not char then
--             Notify("Error", "Character not found", 2)
--             return
--         end
--         local root = char:FindFirstChild("HumanoidRootPart")
--         if not root then
--             Notify("Error", "HumanoidRootPart not found", 2)
--             return
--         end
--         root.CFrame = State.waypointCFrame
--     end,
-- })

-- local keybindLabel = MainTab:CreateLabel("Keybind: [E]")
-- MainTab:CreateButton({
--     Name = "Change Keybind",
--     Callback = function()
--         State.isWaitingForKey = "waypointKey"
--         keybindLabel:Set("Press any key...")
--         Notify("Keybind", "Press any key...", 2)
--     end,
-- })

-- -- =================== CLICK TELEPORT ===================
-- MainTab:CreateToggle({
--     Name = "Click-to-Teleport (Ctrl + Click)",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isClickTeleport = v
--         if v then
--             State.connections["clickTeleport"] = Mouse.Button1Down:Connect(function()
--                 if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
--                     return
--                 end
--                 local char = LocalPlayer.Character
--                 if char and char:FindFirstChild("HumanoidRootPart") then
--                     char:PivotTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)))
--                 end
--             end)
--         else
--             Disconnect("clickTeleport")
--         end
--     end,
-- })

-- -- =================== ANTI-AFK ===================
-- MainTab:CreateSection("Anti-AFK")
-- MainTab:CreateToggle({
--     Name = "Anti-AFK",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isAntiAFK = v
--         if v then
--             -- Fire a subtle idle reset when AFK true
--             State.connections["antiAFK"] = LocalPlayer.Idled:Connect(function()
--                 VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
--                 task.wait(1)
--                 VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
--             end)

--             -- Show notification like the original script
--             local gui = Instance.new("ScreenGui")
--             gui.Name = "AFK_Notice"
--             gui.ResetOnSpawn = false
--             gui.IgnoreGuiInset = true
--             gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--             local frame = Instance.new("Frame")
--             frame.Size = UDim2.new(0, 560, 0, 60)
--             frame.Position = UDim2.new(0.5, 0, 0, -150)
--             frame.AnchorPoint = Vector2.new(0.5, 0)
--             frame.BackgroundColor3 = Color3.fromRGB(70, 90, 70)
--             frame.BackgroundTransparency = 0
--             frame.BorderSizePixel = 0
--             frame.ZIndex = 10
--             frame.Parent = gui

--             local corner = Instance.new("UICorner")
--             corner.CornerRadius = UDim.new(0, 12)
--             corner.Parent = frame

--             local stroke = Instance.new("UIStroke")
--             stroke.Color = Color3.fromRGB(180, 255, 180)
--             stroke.Thickness = 2
--             stroke.Transparency = 0.05
--             stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
--             stroke.Parent = frame

--             local label = Instance.new("TextLabel")
--             label.Size = UDim2.new(1, -20, 1, -10)
--             label.Position = UDim2.new(0, 10, 0, 5)
--             label.BackgroundTransparency = 1
--             label.Text = "✅ Anti-AFK Enabled - You won't be kicked while AFK."
--             label.Font = Enum.Font.GothamSemibold
--             label.TextSize = 18
--             label.TextColor3 = Color3.fromRGB(240, 255, 240)
--             label.TextWrapped = true
--             label.TextXAlignment = Enum.TextXAlignment.Left
--             label.TextYAlignment = Enum.TextYAlignment.Center
--             label.Parent = frame

--             TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
--                 Position = UDim2.new(0.5, 0, 0, -50)
--             }):Play()

--             task.delay(10, function()
--                 local out = TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
--                     Position = UDim2.new(0.5, 0, 0, -120)
--                 })
--                 out:Play()
--                 out.Completed:Wait()
--                 gui:Destroy()
--             end)

--             Notify("Anti-AFK", "Anti-AFK Enabled", 3)
--         else
--             Disconnect("antiAFK")
--             Notify("Anti-AFK", "Anti-AFK Disabled", 2)
--         end
--     end,
-- })

-- -- =================== SETTINGS TAB ===================
-- SettingsTab:CreateSection("Display")

-- -- FPS Counter
-- local FPSGui = Instance.new("ScreenGui")
-- FPSGui.Name = "FPSCounterGui"
-- FPSGui.ResetOnSpawn = false
-- FPSGui.DisplayOrder = 999

-- pcall(function() FPSGui.Parent = game:GetService("CoreGui") end)
-- if not FPSGui.Parent then
--     FPSGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
-- end

-- local FPSFrame = Instance.new("Frame")
-- FPSFrame.Size = UDim2.new(0, 100, 0, 30)
-- FPSFrame.Position = UDim2.new(1, -110, 0, 10)
-- FPSFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
-- FPSFrame.BackgroundTransparency = 0.3
-- FPSFrame.BorderSizePixel = 0
-- FPSFrame.Visible = false
-- FPSFrame.Parent = FPSGui

-- Instance.new("UICorner", FPSFrame).CornerRadius = UDim.new(0, 8)

-- local fpStroke = Instance.new("UIStroke", FPSFrame)
-- fpStroke.Color = Color3.fromRGB(0, 255, 255)
-- fpStroke.Thickness = 1.5

-- local FPSLabel = Instance.new("TextLabel")
-- FPSLabel.Size = UDim2.new(1,0,1,0)
-- FPSLabel.BackgroundTransparency = 1
-- FPSLabel.Text = "FPS: --"
-- FPSLabel.TextColor3 = Color3.fromRGB(0,255,255)
-- FPSLabel.TextSize = 14
-- FPSLabel.Font = Enum.Font.GothamBold
-- FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
-- FPSLabel.Parent = FPSFrame

-- local lastFPSTime = tick()
-- local frameCount = 0

-- State.connections["fpsUpdate"] = RunService.RenderStepped:Connect(function()
--     if not State.isFPSVisible then return end
--     frameCount = frameCount + 1
--     local now = tick()
--     if now - lastFPSTime >= 0.5 then
--         local fps = math.floor(frameCount / (now - lastFPSTime))
--         frameCount = 0
--         lastFPSTime = now
--         FPSLabel.Text = "FPS: " .. fps
--         if fps >= 55 then
--             FPSLabel.TextColor3 = Color3.fromRGB(0,255,150)
--             fpStroke.Color = Color3.fromRGB(0,255,150)
--         elseif fps >= 30 then
--             FPSLabel.TextColor3 = Color3.fromRGB(255,200,0)
--             fpStroke.Color = Color3.fromRGB(255,200,0)
--         else
--             FPSLabel.TextColor3 = Color3.fromRGB(255,50,50)
--             fpStroke.Color = Color3.fromRGB(255,50,50)
--         end
--     end
-- end)

-- SettingsTab:CreateToggle({
--     Name = "Show FPS Counter",
--     CurrentValue = false,
--     Callback = function(v)
--         State.isFPSVisible = v
--         FPSFrame.Visible = v
--         lastFPSTime = tick()
--         frameCount = 0
--         FPSLabel.Text = "FPS: --"
--     end,
-- })

-- SettingsTab:CreateSection("Keybinds")
-- SettingsTab:CreateKeybind({
--     Name = "Toggle UI Keybind",
--     CurrentKeybind = "RightShift",
--     HoldToInteract = false,
--     Callback = function(keybind)
--         local ok, key = pcall(function() return Enum.KeyCode[keybind] end)
--         if ok and key then
--             State.toggleKey = key
--             Notify("Keybind", "Toggle UI key set to: " .. keybind, 3)
--         end
--     end,
-- })

-- -- =================== GLOBAL INPUT HANDLER ===================
-- UserInputService.InputBegan:Connect(function(input, gameProcessed)
--     if gameProcessed then return end

--     if State.isWaitingForKey then
--         if input.KeyCode ~= Enum.KeyCode.Unknown then
--             if State.isWaitingForKey == "waypointKey" then
--                 State.waypointKey = input.KeyCode
--                 keybindLabel:Set("Keybind: [" .. input.KeyCode.Name .. "]")
--                 Notify("Keybind", "Waypoint key set to: " .. input.KeyCode.Name, 2)
--             elseif State.isWaitingForKey == "flyKey" then
--                 State.flyKey = input.KeyCode
--                 flyKeyLabel:Set("Fly Key: [" .. input.KeyCode.Name .. "]")
--                 Notify("Fly Key", "Fly key set to: " .. input.KeyCode.Name, 2)
--             end
--             State.isWaitingForKey = false
--         end
--         return
--     end

--     if input.KeyCode == State.flyKey then
--         State.isFlying = not State.isFlying
--         if State.isFlying then
--             StartFly()
--         else
--             StopFly()
--         end
--         if State.flyToggleObj then
--             pcall(function() State.flyToggleObj:Set(State.isFlying) end)
--         end
--         return
--     end

--     if input.KeyCode == State.waypointKey and State.waypointCFrame then
--         local char = LocalPlayer.Character
--         if char then
--             local root = char:FindFirstChild("HumanoidRootPart")
--             if root then
--                 root.CFrame = State.waypointCFrame
--             end
--         end
--     end

--     if input.KeyCode == State.toggleKey then
--         pcall(function() Rayfield:HideGui() end)
--         pcall(function() Rayfield:ShowGui() end)
--     end
-- end)

-- -- =================== RESPAWN HANDLING ===================
-- LocalPlayer.CharacterAdded:Connect(function(char)
--     task.wait(0.5)

--     local hum = char:FindFirstChildOfClass("Humanoid")
--     if hum then
--         hum.WalkSpeed = State.currentWalkSpeed
--     end

--     if State.isUnlimitedJump then
--         Disconnect("unlimitedJump")
--         State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
--             local c = LocalPlayer.Character
--             if c and c:FindFirstChildOfClass("Humanoid") then
--                 c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
--             end
--         end)
--     end

--     if State.isSelfNoclip then
--         Disconnect("selfNoclipLoop")
--         State.connections["selfNoclipLoop"] = RunService.Stepped:Connect(function()
--             if not State.isSelfNoclip then return end
--             local c = LocalPlayer.Character
--             if not c then return end
--             for _, p in ipairs(c:GetDescendants()) do
--                 if p:IsA("BasePart") then p.CanCollide = false end
--             end
--         end)
--     end

--     if State.isFlying then
--         StartFly()
--     end
-- end)

-- -- =================== MOBILE TOUCH BUTTONS (ONLY FOR MOBILE PLAYERS) ===================
-- local function UpdateMobileFlyButton()
--     if not mobileButtonsGui or not mobileButtonsGui.FlyButton then return end
--     local btn = mobileButtonsGui.FlyButton
--     if State.isFlying then
--         btn.Text = "FLY: ON"
--         btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
--     else
--         btn.Text = "FLY: OFF"
--         btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
--     end
-- end

-- local function CreateMobileButtons()
--     -- Only for touch-enabled devices (assume mobile)
--     if not UserInputService.TouchEnabled then return end

--     local gui = Instance.new("ScreenGui")
--     gui.Name = "MobileButtons"
--     gui.ResetOnSpawn = false
--     gui.DisplayOrder = 998
--     gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
--     mobileButtonsGui = gui -- so we can update fly button text

--     -- Fly Button
--     local flyBtn = Instance.new("TextButton")
--     flyBtn.Name = "FlyButton"
--     flyBtn.Size = UDim2.new(0, 90, 0, 50)
--     flyBtn.Position = UDim2.new(1, -100, 1, -200)
--     flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
--     flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
--     flyBtn.Text = "FLY: OFF"
--     flyBtn.Font = Enum.Font.GothamBold
--     flyBtn.TextSize = 16
--     flyBtn.AutoButtonColor = true
--     flyBtn.Parent = gui
--     Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 10)
--     local flyStroke = Instance.new("UIStroke", flyBtn)
--     flyStroke.Color = Color3.fromRGB(0, 255, 255)
--     flyStroke.Thickness = 1.5

--     flyBtn.Activated:Connect(function()
--         State.isFlying = not State.isFlying
--         if State.isFlying then
--             StartFly()
--         else
--             StopFly()
--         end
--         if State.flyToggleObj then
--             pcall(function() State.flyToggleObj:Set(State.isFlying) end)
--         end
--     end)

--     -- Waypoint Teleport Button
--     local wpBtn = Instance.new("TextButton")
--     wpBtn.Name = "WaypointButton"
--     wpBtn.Size = UDim2.new(0, 90, 0, 50)
--     wpBtn.Position = UDim2.new(1, -100, 1, -140)
--     wpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
--     wpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
--     wpBtn.Text = "WAYPOINT"
--     wpBtn.Font = Enum.Font.GothamBold
--     wpBtn.TextSize = 14
--     wpBtn.AutoButtonColor = true
--     wpBtn.Parent = gui
--     Instance.new("UICorner", wpBtn).CornerRadius = UDim.new(0, 10)
--     local wpStroke = Instance.new("UIStroke", wpBtn)
--     wpStroke.Color = Color3.fromRGB(255, 200, 0)
--     wpStroke.Thickness = 1.5

--     wpBtn.Activated:Connect(function()
--         if State.waypointCFrame then
--             local char = LocalPlayer.Character
--             if char then
--                 local root = char:FindFirstChild("HumanoidRootPart")
--                 if root then
--                     root.CFrame = State.waypointCFrame
--                     Notify("Waypoint", "Teleported!", 1)
--                 end
--             end
--         else
--             Notify("Waypoint", "No waypoint set! Use UI to set first.", 2)
--         end
--     end)
-- end

-- -- Wait for PlayerGui to be ready
-- task.wait(0.5)
-- CreateMobileButtons()

-- print("Hakuna Hub Loaded")
-- print("RightShift - Toggle UI")
-- print("Q - Toggle Fly (Default)")
-- print("E - Waypoint Teleport (Default)")
-- print("Mobile Buttons: only visible on touch devices")
-- task.wait(2)
-- Notify("Loaded", "Press RightShift to toggle UI | Q to toggle Fly | Mobile ready", 5)






























--[[
    ROBLOX UI SCRIPT - MINIMALIST (MOBILE-FRIENDLY)
    - Anti-AFK: Auto ON on load
    - GUI: Auto opens on load
    - New Teleport tab
    - Mobile: Circular waypoint button (draggable), no fly button
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
    isAntiAFK = true,      -- DEFAULT ON
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
    Name = "Global NoCollide (Others)",
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

-- Auto-enable on script load
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

-- =================== SETTINGS TAB ===================
SettingsTab:CreateSection("Display")

-- FPS Counter (white text, minimalist)
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
FPSLabel.TextColor3 = Color3.new(1, 1, 1)  -- WHITE TEXT
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

-- =================== RESPAWN HANDLING ===================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.currentWalkSpeed
    end

    if State.isUnlimitedJump then
        Disconnect("unlimitedJump")
        State.connections["unlimitedJump"] = UserInputService.JumpRequest:Connect(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChildOfClass("Humanoid") then
                c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    if State.isSelfNoclip then
        Disconnect("selfNoclipLoop")
        State.connections["selfNoclipLoop"] = RunService.Stepped:Connect(function()
            if not State.isSelfNoclip then return end
            local c = LocalPlayer.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end

    if State.isFlying then
        StartFly()
    end
end)

-- =================== MOBILE UI (CIRCULAR WAYPOINT BUTTON - DRAGGABLE) ===================
local function CreateMobileButtons()
    if not UserInputService.TouchEnabled then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileButtons"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 998
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Circular Waypoint Button (bilog, minimalist)
    local wpBtn = Instance.new("TextButton")
    wpBtn.Name = "WaypointButton"
    wpBtn.Size = UDim2.new(0, 55, 0, 55)  -- Square size for circle
    wpBtn.Position = UDim2.new(1, -70, 0.5, -27)
    wpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpBtn.Text = "W"
    wpBtn.Font = Enum.Font.GothamBold
    wpBtn.TextSize = 18
    wpBtn.AutoButtonColor = false
    wpBtn.Active = true
    wpBtn.Draggable = true  -- DRAGGABLE!
    wpBtn.Parent = gui

    -- Make it circular
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)  -- Full circle
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

-- Wait for PlayerGui to be ready
task.wait(0.5)
CreateMobileButtons()

print("Hakuna Hub Loaded")
print("Anti-AFK: Auto ON")
print("RightShift - Toggle UI")
print("Q - Toggle Fly (Default)")
print("E - Waypoint Teleport (Default)")
print("Mobile: Circular waypoint button (draggable)")

task.wait(1)

-- Auto-open GUI on load
pcall(function() Rayfield:ShowGui() end)

task.wait(2)
Notify("Loaded", "Anti-AFK: ON | RightShift = UI | Mobile Ready", 5) 




-- new
