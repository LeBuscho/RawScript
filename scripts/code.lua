local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

Player.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- GITHUB GAME SCAN
local GameScanSuccess, GameScanResult = pcall(function()
    return loadstring(game:HttpGet("https://githubusercontent.com"))()
end)

local function CheckGameValidity()
    if GameScanSuccess and type(GameScanResult) == "function" then
        return GameScanResult()
    elseif GameScanSuccess and type(GameScanResult) == "boolean" then
        return GameScanResult
    else
        return (game.PlaceId == 103874780798870 or game.GameId == 7247348934 or string.find(Workspace.Name:lower(), "bunker"))
    end
end

-- RAYFIELD AMETHYST WINDOW
local Rayfield = loadstring(game:HttpGet("https://sirius.menu"))()
local Window = Rayfield:CreateWindow({
    Name = "CoolStudios Hub | Build a Bunker",
    LoadingTitle = "CoolStudios Hub",
    LoadingSubtitle = "by CoolStudios",
    Theme = "Amethyst",
    ConfigurationSaving = { Enabled = false, FolderName = "CoolStudios", FileName = "BuildABunker" },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main Features", 4483362458)
local ItemTab = Window:CreateTab("Item TPN", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- VARIABLEN
local ItemTPNEnabled = false
local IgnoreItemsInBase = false
local AutoKillEnabled = false
local TargetFilter = "All"
local KillRange = 50
local TPNRange = 200
local TPNHeight = 5

local WalkSpeedEnabled = false
local CustomSpeed = 16
local InfiniteOxygen = false
local NoClipEnabled = false
local FullBrightEnabled = false

-- MAUS FREISCHALTEN MIT LINKER ALT-TASTE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        if _G.RayfieldWindowHidden then
            Window:Open()
            _G.RayfieldWindowHidden = false
        else
            Window:Close()
            _G.RayfieldWindowHidden = true
        end
    end
end)

local function GetPlayerBunkerPosition()
    local bunker = Workspace:FindFirstChild("Bunkers") or Workspace:FindFirstChild("Bunker")
    if bunker then
        local playerBunker = bunker:FindFirstChild(Player.Name) or bunker:FindFirstChild(Player.Name .. "Bunker")
        if playerBunker and playerBunker.PrimaryPart then return playerBunker.PrimaryPart.Position end
    end
    local spawns = Workspace:FindFirstChild("Spawns") or Workspace:FindFirstChild("SpawnLocations")
    if spawns then
        local pSpawn = spawns:FindFirstChild(Player.Name) or spawns:FindFirstChildWhichIsA("SpawnLocation")
        if pSpawn then return pSpawn.Position end
    end
    return nil
end

local function IsItem(model)
    if not model:IsA("Model") and not model:IsA("Tool") then return false end
    local toolType = model:GetAttribute("ToolType")
    local interactionClass = model:GetAttribute("InteractionClass")
    if toolType or interactionClass == "Tool" then return true end
    
    local itemNames = {"Fireaxe", "Repeater", "Repair Hammer", "Large Medkit", "Worn Sawn-Off", "Mosberg", 
                       "Basic Sack", "Face Shield", "Military Vest", "Motorcycle Helmet", "Police Vest"}
    for _, name in pairs(itemNames) do
        if string.find(model.Name, name) then return true end
    end
    return false
end

local function GetItemType(item)
    local toolType = item:GetAttribute("ToolType")
    if toolType then return toolType end
    local name = item.Name:lower()
    if string.find(name, "gun") or string.find(name, "rifle") or string.find(name, "shotgun") or string.find(name, "axe") or string.find(name, "scythe") then
        return "Weapon"
    elseif string.find(name, "medkit") or string.find(name, "vest") or string.find(name, "helmet") or string.find(name, "armor") or string.find(name, "shield") then
        return "Medical"
    elseif string.find(name, "sack") or string.find(name, "bag") or string.find(name, "hammer") or string.find(name, "tool") then
        return "Tool"
    else
        return "Other"
    end
end

local function FilterItem(item, filter)
    if filter == "All" then return true end
    local itemType = GetItemType(item)
    if filter == "Weapons" and (itemType == "Weapon" or itemType == "Gun") then return true
    elseif filter == "Medical" and itemType == "Medical" then return true
    elseif filter == "Tools" and itemType == "Tool" then return true end
    return false
end

RunService.Stepped:Connect(function()
    if NoClipEnabled and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            if WalkSpeedEnabled then Character:FindFirstChildOfClass("Humanoid").WalkSpeed = CustomSpeed end
            if InfiniteOxygen then
                Character:SetAttribute("Oxygen", 100)
                Character:SetAttribute("Stamina", 100)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if FullBrightEnabled then
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 2
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if ItemTPNEnabled and Character and HumanoidRootPart then
            local basePos = GetPlayerBunkerPosition()
            for _, item in pairs(Workspace:GetDescendants()) do
                if IsItem(item) and FilterItem(item, TargetFilter) then
                    local primaryPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
                    if primaryPart then
                        local distanceToPlayer = (HumanoidRootPart.Position - primaryPart.Position).Magnitude
                        local inBase = false
                        if IgnoreItemsInBase and basePos then
                            if (basePos - primaryPart.Position).Magnitude <= 60 then inBase = true end
                        end
                        if distanceToPlayer <= TPNRange and not inBase then
                            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                            local goal = { Position = HumanoidRootPart.Position + Vector3.new(0, TPNHeight, 0) }
                            TweenService:Create(primaryPart, tweenInfo, goal):Play()
                        end
                    end
                end
            end
        end
    end
end)

local function GetToolRemote()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    local index = packages and packages:FindFirstChild("_Index")
    if not index then return nil end
    for _, child in pairs(index:GetChildren()) do
        if string.find(child.Name, "sleitnick_knit") then
            local knit = child:FindFirstChild("knit")
            local services = knit and knit:FindFirstChild("Services")
            local toolService = services and services:FindFirstChild("ToolService")
            return toolService and toolService:FindFirstChild("RE")
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.1) do
        if AutoKillEnabled and Character then
            local currentTool = Character:FindFirstChildWhichIsA("Tool")
            if currentTool then
                local closestNPC, closestDistance = nil, KillRange
                for _, npc in pairs(Workspace:GetChildren()) do
                    if npc:IsA("Model") and npc ~= Character and npc:FindFirstChildOfClass("Humanoid") then
                        local humanoid = npc:FindFirstChildOfClass("Humanoid")
                        local rootPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        if humanoid and humanoid.Health > 0 and rootPart then
                            local distance = (HumanoidRootPart.Position - rootPart.Position).Magnitude
                            if distance <= closestDistance then closestNPC, closestDistance = npc, distance end
                        end
                    end
                end
                if closestNPC then
                    local npcRoot = closestNPC:FindFirstChild("HumanoidRootPart") or closestNPC:FindFirstChild("Torso")
                    local toolRemote = GetToolRemote()
                    if npcRoot and toolRemote then toolRemote:FireServer(currentTool, npcRoot.Position, closestNPC) end
                end
            end
        end
    end
end)

-- 1. MAIN TAB ELEMENTE
MainTab:CreateSection("Player Tweaks")
MainTab:CreateToggle({
    Name = "Enable Custom WalkSpeed", CurrentValue = false, Flag = "SpeedToggle",
    Callback = function(Value) WalkSpeedEnabled = Value end,
})
MainTab:CreateSlider({
    Name = "WalkSpeed Value", Min = 16, Max = 120, Increment = 1, Default = 16, ValueName = "Speed", Flag = "SpeedSlider",
    Callback = function(Value) CustomSpeed = Value end,
})
MainTab:CreateToggle({
    Name = "Infinite Stamina & Oxygen", CurrentValue = false, Flag = "StaminaToggle",
    Callback = function(Value) InfiniteOxygen = Value end,
})
MainTab:CreateToggle({
    Name = "NoClip (Durch Wände)", CurrentValue = false, Flag = "NoClipToggle",
    Callback = function(Value) NoClipEnabled = Value end,
})
MainTab:CreateSection("Teleports & World")
MainTab:CreateButton({
    Name = "Teleport to Surface (Town)",
    Callback = function() if HumanoidRootPart then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 140, 0) end end,
})
MainTab:CreateButton({
    Name = "Teleport to Own Bunker",
    Callback = function() local basePos = GetPlayerBunkerPosition() if HumanoidRootPart and basePos then HumanoidRootPart.CFrame = CFrame.new(basePos + Vector3.new(0, 3, 0)) end end,
})

-- 2. ITEM TPN TAB ELEMENTE
ItemTab:CreateSection("Teleport Items To You")
ItemTab:CreateToggle({
    Name = "Enable Item Teleport", CurrentValue = false, Flag = "ItemTPNToggle",
    Callback = function(Value) ItemTPNEnabled = Value end,
})
ItemTab:CreateToggle({
    Name = "Ignore Items Already in Base", CurrentValue = false, Flag = "IgnoreBaseToggle",
    Callback = function(Value) IgnoreItemsInBase = Value end,
})
ItemTab:CreateDropdown({
    Name = "Filter Type", Options = {"All", "Weapons", "Medical", "Tools"}, CurrentOption = {"All"}, MultipleOptions = false, Flag = "ItemFilterDropdown",
    Callback = function(Value) TargetFilter = Value end,
})
ItemTab:CreateSlider({
    Name = "Scan Range", Min = 10, Max = 500, Increment = 10, Default = 200, ValueName = "Studs", Flag = "TPNRangeSlider",
    Callback = function(Value) TPNRange = Value end,
})
ItemTab:CreateSlider({
    Name = "Teleport Height Offset", Min = 0, Max = 20, Increment = 1, Default = 5, ValueName = "Studs", Flag = "TPNHeightSlider",
    Callback = function(Value) TPNHeight = Value end,
})

-- 3. COMBAT TAB ELEMENTE (Aus deinem Bild übernommen & korrigiert)
CombatTab:CreateSection("Combat Assistant")
CombatTab:CreateToggle({
    Name = "Enable Auto Kill NPC", CurrentValue = false, Flag = "AutoKillToggle",
    Callback = function(Value) AutoKillEnabled = Value end,
})
CombatTab:CreateSlider({
    Name = "Attack Range", Min = 5, Max = 150, Default = 50, Increment = 5, ValueName = "Studs", Flag = "KillRangeSlider",
    Callback = function(Value) KillRange = Value end,
})

-- 4. SETTINGS TAB ELEMENTE
SettingsTab:CreateSection("Visuals & Performance")
SettingsTab:CreateToggle({
    Name = "FullBright (Nachtsicht)", CurrentValue = false, Flag = "BrightToggle",
    Callback = function(Value) FullBrightEnabled = Value end,
})
SettingsTab:CreateButton({
    Name = "FPS Boost (Remove Textures/Decals)",
    Callback = function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end end,
})
SettingsTab:CreateLabel("Maus freischalten: Drücke LINKES ALT")

-- SCANNER INITIALISIERUNG
if CheckGameValidity() then
    Rayfield:Notify({ Title = "CoolStudios Hub", Content = "Build a Bunker Script successfully loaded!", Duration = 5, Image = 4483362458 })
else
    Rayfield:Notify({ Title = "Game Scan Warning", Content = "Spielstruktur nicht optimal erkannt! Stelle sicher, dass du im richtigen Spiel bist.", Duration = 6, Image = 4483362458 })
end
