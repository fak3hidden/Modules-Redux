--[[
    Modules Redux [V6.3] - FULL VERSION
    Update: Red/Green Circular Toggles, Spaz Fling, Full ESP Suite
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Constants
local ConfigPath = [[C:\Users\morte\AppData\Local\Potassium\workspace\Configs]]
local TargetPlaceId = 17625359962
local IsRageAllowed = (game.PlaceId == TargetPlaceId)

pcall(function()
    if makefolder and not isfolder(ConfigPath) then makefolder(ConfigPath) end
end)

-- Global Configuration Table
local Config = {
    Advantage = { Aimbot = false, Smoothing = 0.2, Radius = 100, ShowFOV = true, TriggerBot = false, TriggerDelay = 50 },
    Visual = { Box = false, Tracer = false, Health = false, Name = false, Distance = false, MaxDistance = 1000 },
    Player = { WalkSpeed = 16, Fly = false, FlySpeed = 50, Noclip = false },
    Misc = { Ragebot = false }
}

local UIRegistry = {}
local SelectedPlayer = nil

-- Colors
local UI_Colors = {
    Accent = Color3.fromRGB(80, 150, 255),
    Enabled = Color3.fromRGB(46, 204, 113), -- Green
    Disabled = Color3.fromRGB(231, 76, 60), -- Red
    MainBG = Color3.fromRGB(15, 15, 15),
    TopBar = Color3.fromRGB(20, 20, 20)
}

-- Drawing Objects (FOV)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 100; FOVCircle.Radius = Config.Advantage.Radius
FOVCircle.Filled = false; FOVCircle.Visible = false; FOVCircle.Color = UI_Colors.Accent

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ModulesRedux_V6_3"
ScreenGui.ResetOnSpawn = false

-- 1. EXIT UI
local ExitFrame = Instance.new("Frame", ScreenGui)
ExitFrame.Size = UDim2.new(0, 320, 0, 140); ExitFrame.Position = UDim2.new(0.5, -160, 0.5, -70); ExitFrame.BackgroundColor3 = UI_Colors.MainBG; ExitFrame.Visible = false; ExitFrame.ZIndex = 100
Instance.new("UICorner", ExitFrame)
local YesBtn = Instance.new("TextButton", ExitFrame); YesBtn.Size = UDim2.new(0, 130, 0, 32); YesBtn.Position = UDim2.new(0, 20, 0, 80); YesBtn.BackgroundColor3 = UI_Colors.Enabled; YesBtn.Text = "YES"; YesBtn.TextColor3 = Color3.new(1,1,1); YesBtn.ZIndex = 101; Instance.new("UICorner", YesBtn)
local NoBtn = Instance.new("TextButton", ExitFrame); NoBtn.Size = UDim2.new(0, 130, 0, 32); NoBtn.Position = UDim2.new(1, -150, 0, 80); NoBtn.BackgroundColor3 = UI_Colors.Disabled; NoBtn.Text = "NO"; NoBtn.TextColor3 = Color3.new(1,1,1); NoBtn.ZIndex = 101; Instance.new("UICorner", NoBtn)

-- 2. TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 30); ToggleBtn.Position = UDim2.new(0, 20, 1, -50); ToggleBtn.BackgroundColor3 = UI_Colors.TopBar; ToggleBtn.Text = "TOGGLE UI"; ToggleBtn.TextColor3 = UI_Colors.Accent; ToggleBtn.Visible = false; Instance.new("UICorner", ToggleBtn)

-- 3. MAIN FRAME
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 400); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200); MainFrame.BackgroundColor3 = UI_Colors.MainBG; MainFrame.BorderSizePixel = 0

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30); TopBar.BackgroundColor3 = UI_Colors.TopBar

local Title = Instance.new("TextLabel", TopBar); Title.Text = "Modules Redux V6.3"; Title.Size = UDim2.new(1, -70, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.FontFace = Font.fromEnum(Enum.Font.Code)

local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -60, 0, 0); MinBtn.Text = "-"; MinBtn.BackgroundTransparency = 1; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.TextSize = 20
local CloseBtn = Instance.new("TextButton", TopBar); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.Text = "X"; CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.new(1,1,1)

local TabHolder = Instance.new("Frame", MainFrame); TabHolder.Size = UDim2.new(1, 0, 0, 25); TabHolder.Position = UDim2.new(0, 0, 0, 30); TabHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UIListLayout", TabHolder).FillDirection = Enum.FillDirection.Horizontal

local ContentArea = Instance.new("Frame", MainFrame); ContentArea.Size = UDim2.new(1, -20, 1, -65); ContentArea.Position = UDim2.new(0, 10, 0, 60); ContentArea.BackgroundTransparency = 1

-- Tab / UI Builders
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabHolder); TabBtn.Size = UDim2.new(0, 83, 1, 0); TabBtn.BackgroundTransparency = 1; TabBtn.Text = name:upper(); TabBtn.TextColor3 = Color3.new(0.5, 0.5, 0.5); TabBtn.FontFace = Font.fromEnum(Enum.Font.Code); TabBtn.TextSize = 10
    local TabPage = Instance.new("ScrollingFrame", ContentArea); TabPage.Size = UDim2.new(1, 0, 1, 0); TabPage.Visible = false; TabPage.BackgroundTransparency = 1; TabPage.ScrollBarThickness = 2; TabPage.BorderSizePixel = 0
    Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 5)
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(ContentArea:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _, v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.new(0.5, 0.5, 0.5) end end
        TabPage.Visible = true; TabBtn.TextColor3 = UI_Colors.Accent
    end)
    return TabPage
end

local function AddToggle(parent, text, idx, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 25); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Text = text; Label.Size = UDim2.new(1, -40, 1, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.new(0.8,0.8,0.8); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.FontFace = Font.fromEnum(Enum.Font.Code)
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(0, 15, 0, 15); Btn.Position = UDim2.new(1, -20, 0.5, -7); Btn.BackgroundColor3 = UI_Colors.Disabled; Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0) -- Round Circle
    
    local function Update(val)
        Btn.BackgroundColor3 = val and UI_Colors.Enabled or UI_Colors.Disabled
        callback(val)
    end
    Btn.MouseButton1Click:Connect(function() Update(Btn.BackgroundColor3 == UI_Colors.Disabled) end)
    UIRegistry[idx] = Update
    return Update
end

local function AddSlider(parent, text, min, max, default, idx, callback)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(1, 0, 0, 35); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Text = text .. " [" .. default .. "]"; Label.Size = UDim2.new(1, 0, 0, 15); Label.BackgroundTransparency = 1; Label.TextColor3 = Color3.new(0.8,0.8,0.8); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.FontFace = Font.fromEnum(Enum.Font.Code)
    local Bar = Instance.new("Frame", Frame); Bar.Size = UDim2.new(1, -10, 0, 4); Bar.Position = UDim2.new(0, 0, 0, 20); Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = UI_Colors.Accent
    local function Update(val)
        val = math.clamp(val, min, max)
        Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        Label.Text = text .. " [" .. val .. "]"
        callback(val)
    end
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local move = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Update(math.floor(min + (max - min) * pos))
                end
            end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
        end
    end)
    UIRegistry[idx] = Update
    return Update
end

-- TABS
local AdvantageTab = CreateTab("Advantage")
local VisualTab = CreateTab("Visual")
local PlayerTab = CreateTab("Player")
local PlayersTab = CreateTab("Players")
local MiscTab = IsRageAllowed and CreateTab("Misc") or nil
local SettingsTab = CreateTab("Settings")

-- POPULATE
AddToggle(AdvantageTab, "Aimbot", "aimbot_toggle", function(v) Config.Advantage.Aimbot = v end)
AddSlider(AdvantageTab, "Smoothing", 1, 100, 20, "aimbot_smoothing", function(v) Config.Advantage.Smoothing = v/100 end)
AddSlider(AdvantageTab, "FOV Radius", 30, 800, 100, "aimbot_radius", function(v) Config.Advantage.Radius = v end)
AddToggle(AdvantageTab, "Triggerbot", "triggerbot_enabled", function(v) Config.Advantage.TriggerBot = v end)

AddToggle(VisualTab, "Box ESP", "esp_box", function(v) Config.Visual.Box = v end)
AddToggle(VisualTab, "Name ESP", "esp_name", function(v) Config.Visual.Name = v end)
AddToggle(VisualTab, "Health ESP", "esp_healthbar", function(v) Config.Visual.Health = v end)
AddToggle(VisualTab, "Distance ESP", "esp_distance", function(v) Config.Visual.Distance = v end)
AddToggle(VisualTab, "Tracers", "esp_tracers", function(v) Config.Visual.Tracer = v end)

AddSlider(PlayerTab, "Walkspeed", 16, 250, 16, "movement_velocityvalue", function(v) Config.Player.WalkSpeed = v end)
AddToggle(PlayerTab, "Fly", "movement_fly", function(v) Config.Player.Fly = v end)
AddToggle(PlayerTab, "Noclip", "movement_noclip", function(v) Config.Player.Noclip = v end)

if MiscTab then AddToggle(MiscTab, "Ragebot", "ragebot_enabled", function(v) Config.Misc.Ragebot = v end) end

-- PLAYER LIST
local PlayerScroll = Instance.new("ScrollingFrame", PlayersTab); PlayerScroll.Size = UDim2.new(1, 0, 0, 180); PlayerScroll.BackgroundTransparency = 1; PlayerScroll.CanvasSize = UDim2.new(0,0,5,0)
Instance.new("UIListLayout", PlayerScroll)
local TargetLabel = Instance.new("TextLabel", PlayersTab); TargetLabel.Size = UDim2.new(1, 0, 0, 25); TargetLabel.Text = "Selected: None"; TargetLabel.TextColor3 = UI_Colors.Accent; TargetLabel.BackgroundTransparency = 1
local TpBtn = Instance.new("TextButton", PlayersTab); TpBtn.Size = UDim2.new(1, 0, 0, 30); TpBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); TpBtn.Text = "TELEPORT TO PLAYER"; TpBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TpBtn)
local FlingBtn = Instance.new("TextButton", PlayersTab); FlingBtn.Size = UDim2.new(1, 0, 0, 30); FlingBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); FlingBtn.Text = "FLING PLAYER (SPAZ)"; FlingBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FlingBtn)
local RefreshPBtn = Instance.new("TextButton", PlayersTab); RefreshPBtn.Size = UDim2.new(1, 0, 0, 25); RefreshPBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); RefreshPBtn.Text = "REFRESH LIST"; RefreshPBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RefreshPBtn)

local function UpdatePlayerList()
    for _, v in pairs(PlayerScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerScroll)
            pBtn.Size = UDim2.new(1, 0, 0, 25); pBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); pBtn.Text = p.Name; pBtn.TextColor3 = Color3.new(0.8,0.8,0.8); pBtn.BorderSizePixel = 0
            pBtn.MouseButton1Click:Connect(function()
                SelectedPlayer = p; TargetLabel.Text = "Selected: " .. p.Name
                for _, b in pairs(PlayerScroll:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.new(0.8,0.8,0.8) end end
                pBtn.TextColor3 = UI_Colors.Accent
            end)
        end
    end
end
RefreshPBtn.MouseButton1Click:Connect(UpdatePlayerList); UpdatePlayerList()

TpBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

FlingBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local targetHRP = SelectedPlayer.Character.HumanoidRootPart
        local oldCF = hrp.CFrame
        task.spawn(function()
            local t = tick()
            while tick() - t < 2 do
                -- SPAZ FLING LOGIC
                hrp.CFrame = targetHRP.CFrame * CFrame.new(math.random(-2,2), 0, math.random(-2,2)) * CFrame.Angles(math.random(-360,360), math.random(-360,360), math.random(-360,360))
                hrp.Velocity = Vector3.new(800000, 800000, 800000)
                RunService.Heartbeat:Wait()
            end
            hrp.CFrame = oldCF; hrp.Velocity = Vector3.zero
        end)
    end
end)

-- CONFIG MANAGER
AddSlider(SettingsTab, "Trigger Delay (ms)", 0, 500, 50, "triggerbot_delay", function(v) Config.Advantage.TriggerDelay = v end)
AddSlider(SettingsTab, "ESP Max Dist", 100, 5000, 1000, "esp_max_dist", function(v) Config.Visual.MaxDistance = v end)
AddSlider(SettingsTab, "Fly Speed", 10, 500, 50, "fly_speed", function(v) Config.Player.FlySpeed = v end)
local RefreshBtn = Instance.new("TextButton", SettingsTab); RefreshBtn.Size = UDim2.new(1, -10, 0, 25); RefreshBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); RefreshBtn.Text = "REFRESH CONFIG LIST"; RefreshBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RefreshBtn)
local ConfigScroll = Instance.new("ScrollingFrame", SettingsTab); ConfigScroll.Size = UDim2.new(1, 0, 0, 100); ConfigScroll.BackgroundTransparency = 1; ConfigScroll.CanvasSize = UDim2.new(0,0,2,0)
Instance.new("UIListLayout", ConfigScroll).Padding = UDim.new(0, 2)

local function LoadConfig(name)
    local path = ConfigPath .. "\\" .. name
    local success, content = pcall(function() return readfile(path) end)
    if success then
        local data = HttpService:JSONDecode(content)
        if data.objects then
            for _, o in pairs(data.objects) do
                if UIRegistry[o.idx] then UIRegistry[o.idx](o.value) end
            end
        end
    end
end

RefreshBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local files = listfiles(ConfigPath)
    for _, f in pairs(files) do
        local name = f:match("([^" .. "\\" .. "]+)$")
        if name:sub(-5) == ".json" then
            local b = Instance.new("TextButton", ConfigScroll); b.Size = UDim2.new(1,-10,0,20); b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.Text = name; b.TextColor3 = Color3.new(0.8,0.8,0.8)
            b.MouseButton1Click:Connect(function() LoadConfig(name) end)
        end
    end
end)

-- ESP ENGINE
local DrawObjects = {}
local function CreateESP(p)
    local o = { Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), Health = Drawing.new("Line"), Name = Drawing.new("Text"), Dist = Drawing.new("Text") }
    o.Box.Thickness = 1; o.Box.Color = Color3.new(1,1,1)
    o.Tracer.Color = UI_Colors.Accent; o.Health.Thickness = 2; o.Health.Color = UI_Colors.Enabled
    o.Name.Size = 14; o.Name.Center = true; o.Name.Outline = true; o.Name.Color = Color3.new(1,1,1)
    o.Dist.Size = 12; o.Dist.Center = true; o.Dist.Outline = true; o.Dist.Color = Color3.new(0.8,0.8,0.8)
    DrawObjects[p] = o
end
local function RemoveESP(p) if DrawObjects[p] then for _, v in pairs(DrawObjects[p]) do v.Visible = false; v:Remove() end DrawObjects[p] = nil end end
Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- MAIN LOOP
local BodyVel, BodyGyro, lastShot = nil, nil, 0
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.WalkSpeed = Config.Player.WalkSpeed
    if Config.Player.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end

    if Config.Player.Fly then
        if not BodyVel then BodyVel = Instance.new("BodyVelocity", hrp); BodyVel.MaxForce = Vector3.new(9e9,9e9,9e9); BodyGyro = Instance.new("BodyGyro", hrp); BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9) end
        local dir = Vector3.new(0,0,0); local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        BodyVel.Velocity = dir * Config.Player.FlySpeed; BodyGyro.CFrame = cf
    elseif BodyVel then BodyVel:Destroy(); BodyVel = nil; BodyGyro:Destroy(); BodyGyro = nil end

    FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Config.Advantage.Radius; FOVCircle.Visible = Config.Advantage.Aimbot and Config.Advantage.ShowFOV

    local target = nil; local minDist = (Config.Misc.Ragebot and 10000) or Config.Advantage.Radius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local head = p.Character.Head
            if Config.Misc.Ragebot then local d = (head.Position - hrp.Position).Magnitude; if d < minDist then minDist = d; target = head end
            elseif Config.Advantage.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local pos, onS = Camera:WorldToViewportPoint(head.Position)
                if onS then local mD = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude; if mD < minDist then minDist = mD; target = head end end
            end
        end
    end

    if Config.Misc.Ragebot and target then
        hrp.CFrame = CFrame.new(target.Position + Vector3.new(math.cos(tick()*25)*7, 5, math.sin(tick()*25)*7), target.Position)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position); if mouse1click then mouse1click() end
    elseif target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.Advantage.Smoothing)
    end

    if Config.Advantage.TriggerBot and not Config.Misc.Ragebot then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if hit and hit.Instance and Players:GetPlayerFromCharacter(hit.Instance:FindFirstAncestorOfClass("Model")) and tick()*1000 - lastShot > Config.Advantage.TriggerDelay then
            if mouse1click then mouse1click() end; lastShot = tick()*1000
        end
    end

    for p, o in pairs(DrawObjects) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tHRP = p.Character.HumanoidRootPart; local pos, onS = Camera:WorldToViewportPoint(tHRP.Position); local d = (tHRP.Position - hrp.Position).Magnitude
            if onS and d <= Config.Visual.MaxDistance then
                local size = (Camera:WorldToViewportPoint(tHRP.Position - Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(tHRP.Position + Vector3.new(0,2.6,0)).Y)
                o.Box.Size = Vector2.new(size*0.7, size); o.Box.Position = Vector2.new(pos.X - o.Box.Size.X/2, pos.Y - o.Box.Size.Y/2); o.Box.Visible = Config.Visual.Box
                o.Health.From = Vector2.new(pos.X - size*0.35 - 5, pos.Y + size/2); o.Health.To = Vector2.new(pos.X - size*0.35 - 5, pos.Y + size/2 - (size * (p.Character.Humanoid.Health/p.Character.Humanoid.MaxHealth))); o.Health.Visible = Config.Visual.Health
                o.Name.Text = p.Name; o.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15); o.Name.Visible = Config.Visual.Name
                o.Dist.Text = math.floor(d) .. "m"; o.Dist.Position = Vector2.new(pos.X, pos.Y + size/2 + 5); o.Dist.Visible = Config.Visual.Distance
                o.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); o.Tracer.To = Vector2.new(pos.X, pos.Y); o.Tracer.Visible = Config.Visual.Tracer
            else for _, v in pairs(o) do v.Visible = false end end
        else for _, v in pairs(o) do v.Visible = false end end
    end
end)

-- UI Interactions
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleBtn.Visible = true end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; ToggleBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ExitFrame.Visible = true end)
NoBtn.MouseButton1Click:Connect(function() ExitFrame.Visible = false; MainFrame.Visible = true end)
YesBtn.MouseButton1Click:Connect(function() FOVCircle:Remove(); for p, _ in pairs(DrawObjects) do RemoveESP(p) end; ScreenGui:Destroy() end)

AdvantageTab.Visible = true