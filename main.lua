

local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn(Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info})
                    end
                end
                return true
            end)

            table.insert(Hooked, Detected)
        end
        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then
                    warn(Adonis AntiCheat tried to kill (fallback): {Info})
                end
            end)
            table.insert(Hooked, Kill)
        end
    end
end
local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...
    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn(Adonis AntiCheat sanity check detected and broken)
        end
        return coroutine.yield(coroutine.running())
    end
    return Old(...)
end))
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/kav"))()
local Window = Library.CreateLib("Toprakware", "DarkTheme")
local Tab = Window:NewTab("Ana Menu")
local Section = Tab:NewSection("Main")
Section:NewButton("Camlock", "Default key is C.", function()
    -- Configuration
getgenv().OldAimPart = "HumanoidRootPart"
getgenv().AimPart = "UpperTorso" -- For R15 Games: {UpperTorso, LowerTorso, HumanoidRootPart, Head} | For R6 Games: {Head, Torso, HumanoidRootPart}
getgenv().AimlockKey = "c" -- change to whatever you want, make sure it's lowercase
getgenv().AimRadius = 50 -- How far away from someone's character you want to lock on
getgenv().ThirdPerson = true
getgenv().FirstPerson = true
getgenv().TeamCheck = false -- Check if the target is on your team
getgenv().PredictMovement = true -- Predicts if the target is moving
getgenv().PredictionVelocity = 14.657388 -- Velocity for prediction
getgenv().CheckIfJumped = true
getgenv().Smoothness = false
getgenv().SmoothnessAmount = 0.11345

-- Services
local Players, UserInputService, RunService, StarterGui = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("StarterGui")
local Client, Mouse, Camera = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera

-- Functions
getgenv().WorldToViewportPoint = Camera.WorldToViewportPoint
getgenv().WorldToScreenPoint = Camera.WorldToScreenPoint

local function GetNearestTarget()
    local players = {}
    local playerHold = {}
    local distances = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Client then
            table.insert(players, player)
        end
    end

    for _, player in pairs(players) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local aim = player.Character.Head

            if (getgenv().TeamCheck and player.Team ~= Client.Team) or (not getgenv().TeamCheck and player.Team == Client.Team) then
                local distance = (aim.Position - Camera.CFrame.p).magnitude
                local ray = Ray.new(Camera.CFrame.p, (Mouse.Hit.p - Camera.CFrame.p).unit * distance)
                local hit, pos = workspace:FindPartOnRay(ray, workspace)
                local diff = math.floor((pos - aim.Position).magnitude)

                playerHold[player.Name] = {
                    dist = distance,
                    plr = player,
                    diff = diff
                }
                table.insert(distances, diff)
            end
        end
    end

    if #distances == 0 then
        return nil
    end

    local lDistance = math.floor(math.min(unpack(distances)))
    if lDistance > getgenv().AimRadius then
        return nil
    end

    for _, v in pairs(playerHold) do
        if v.diff == lDistance then
            return v.plr
        end
    end
    return nil
end

-- Event Connections
Mouse.KeyDown:Connect(function(key)
    if not UserInputService:GetFocusedTextBox() then
        if key == getgenv().AimlockKey then
            if not AimlockTarget then
                local target = GetNearestTarget()
                if target then
                    AimlockTarget = target
                end
            else
                AimlockTarget = nil
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local canNotify = false

    if getgenv().ThirdPerson and getgenv().FirstPerson then
        canNotify = (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1
    elseif getgenv().ThirdPerson then
        canNotify = (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1
    elseif getgenv().FirstPerson then
        canNotify = (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1
    end

    if Aimlock and MousePressed then
        if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then
            local aimPart = AimlockTarget.Character[getgenv().AimPart]
            local targetPos = aimPart.Position + (getgenv().PredictMovement and aimPart.Velocity / getgenv().PredictionVelocity or Vector3.new(0, 0, 0))

            if canNotify then
                local main = CFrame.new(Camera.CFrame.p, targetPos)
                Camera.CFrame = getgenv().Smoothness and main:Lerp(Camera.CFrame, getgenv().SmoothnessAmount) or main
            end
        end
    end

    if getgenv().CheckIfJumped and AimlockTarget and AimlockTarget.Character then
        if AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then
            getgenv().AimPart = "UpperTorso"
        else
            getgenv().AimPart = getgenv().OldAimPart
        end
    end
end)

end)
Delay.Position:Destroy()
Delay.Position = 0
Section:NewButton("No-Delay", "Even if youre on 100 ping, u will have ZERO delay.", function()
    local ReplicatedStorage = game.ReplicatedStorage
local Network = game.Network
local Delay = ReplicatedStorage.BulletHole.Delay
Delay.Position:Destroy()
Delay.Position = 0
end)

Section:NewButton("No-Recoil", "Have fun of this with no delay, sticky aim should be good!", function()
    local ReplicatedStorage = game.ReplicatedStorage
local Network = game.Network
local Delay = ReplicatedStorage.BulletHole.Delay
Delay.Position:Destroy()
Delay.Position = 0
end)

Section:NewButton("Unlock skins", "All credits go to: Invooker1", function()
    hookfunction(game.Players.LocalPlayer.IsInGroup, function() return true end)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Invooker1/Hub/main/DH-Skin-Changer.lua", true))()
end)

local Tab = Window:NewTab("Antilocks")
local Section1 = Tab:NewSection("Antilock(s) and resolver(s).")
Section1:NewButton("X-Anti", "Harder than resolving sky and underground antis available.", function()
getgenv().XAnti = true 
getgenv().AntiStrength = 1000 --(800-1500 is best)
game:GetService("RunService").heartbeat:Connect(function()
    if getgenv().XAnti ~= false then 
    local vel = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity
    game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(getgenv().AntiStrength,0,0) 
    game:GetService("RunService").RenderStepped:Wait()
    game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = vel
    end 
end)
end)

Section1:NewButton("Paid underground (leaked)", "Have fun destroying illegits key: x", function()
    local Toggled = false
    local KeyCode = 'x'
    
    
    function AA()
        local oldVelocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(oldVelocity.X, -70, oldVelocity.Z)
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(oldVelocity.X, oldVelocity.Y, oldVelocity.Z)
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(oldVelocity.X, -70, oldVelocity.Z)
        game.Players.LocalPlayer.Character.Humanoid.HipHeight = 4.14
    end
    
    game:GetService('UserInputService').InputBegan:Connect(function(Key)
        if Key.KeyCode == Enum.KeyCode[KeyCode:upper()] and not game:GetService('UserInputService'):GetFocusedTextBox() then
            if Toggled then
                Toggled = false
                game.Players.LocalPlayer.Character.Humanoid.HipHeight = 1.85
    
            elseif not Toggled then
                Toggled = true
    
                while Toggled do
                    AA()
                    task.wait()
                end
            end
        end
    end)
end)

Section1:NewButton("Anti viewer", "YOU HAVE TO USE AT TRYOUTS OR AS PEOPLE USE ANTIAIM", function()
    hookfunction(game.Players.LocalPlayer.IsInGroup, function() return true end)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Invooker1/Hub/main/DH-Skin-Changer.lua", true))()
end)


Section1:NewButton("Anti viewer", "YOU HAVE TO USE AT TRYOUTS OR AS PEOPLE USE ANTIAIM", function()
    hookfunction(game.Players.LocalPlayer.IsInGroup, function() return true end)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Invooker1/Hub/main/DH-Skin-Changer.lua", true))()
end)

Section1:NewButton("Prime Resolver", "Doesnt work on fatality and other paids, no trouble because they are detected. (untested)", function()
    local RunService = game:GetService("RunService")

    local function zeroOutYVelocity(hrp)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
    end
    
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            local hrp = character:WaitForChild("HumanoidRootPart")
            zeroOutYVelocity(hrp)
        end)
    end
    
    local function onPlayerRemoving(player)
        player.CharacterAdded:Disconnect()
    end
    
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    game.Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    RunService.Heartbeat:Connect(function()
        pcall(function()
            for i, player in pairs(game.Players:GetChildren()) do
                if player.Name ~= game.Players.LocalPlayer.Name then
                    local hrp = player.Character.HumanoidRootPart
                    zeroOutYVelocity(hrp)
                end
            end
        end)
    end)
end)


Section1:NewButton("My Resolver", "ngl mid", function()
    local RunService = game:GetService("RunService")
    RunService.Heartbeat:Connect(function()
        pcall(function()
            for i,v in pairs(game.Players:GetChildren()) do
                if v.Name ~= game.Players.LocalPlayer.Name then
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)    
                    hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)   
                end
            end
        end)
    end)
end)
local Tab = Window:NewTab("Misc")
local Section2 = Tab:NewSection("Misc")
Section1:NewButton("Legit fake macro: Q", "another streamable", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/nEQZRJJP", true))()
end)
Section1:NewButton("Smooth fps macro: X", "streamable", function()

local Player = game:GetService("Players").LocalPlayer
            local Mouse = Player:GetMouse()
            local SpeedGlitch = false
            Mouse.KeyDown:Connect(function(Key)
                if Key == "x" then
                    SpeedGlitch = not SpeedGlitch
                    if SpeedGlitch == true then
                        repeat game:GetService("VirtualInputManager"):SendMouseWheelEvent("0", "0", true, game)
                                    wait(0.000001)
                                    game:GetService("VirtualInputManager"):SendMouseWheelEvent("0", "0", false, game)
                                    wait(0.000001)
                        until SpeedGlitch == false
                    end
                end
            end)
        end)
