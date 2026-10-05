if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat
    task.wait()
until game.Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function getCamera()
    return workspace.CurrentCamera
end

--==================================================
-- STATUS
--==================================================

local godmode = false
local antiDown = false
local antiBleed = false
local hideDownUI = false

local antiSit = false
local antiVoid = false
local antiAfk = true
local antiTaser = false

local speedOn = false
local currentSpeed = 16

local noclipOn = false
local infJump = false

local clickCarTP = false
local clickFootTP = false
local pushCars = false

local pushPower = 1000
local tweenTime = 1.4

local selectedPlayer = "Niemand"

local freecamOn = false
local freecamSpeed = 60
local spectating = false
local moving = false

local freecamYaw = 0
local freecamPitch = 0
local freezeCFrame = nil

local bodyToCam = false

local fullbright = false
local espOn = false
local heliESP = false

local currentFOV = 70
local heliDetectionRange = 300

local trollFly = false
local trollSpin = false
local trollInvisible = false

local trollFlySpeed = 60
local trollSpinSpeed = 8

local autoPushPullEnabled = false

local aimedName = "-"

local noclipConn = nil
local freecamConn = nil
local afkConn = nil
local moveConn = nil
local trollFlyConn = nil
local trollSpinConn = nil

--==================================================
-- RAYFIELD
--==================================================

local Window = Rayfield:CreateWindow({
    Name = "BRP Helper v2",
    LoadingTitle = "BRP Helper v2",
    LoadingSubtitle = "by CoolStudios",
    Theme = "Amethyst",

    ConfigurationSaving = {
        Enabled = false
    },

    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = false
    },

    KeySystem = false
})

local InfoTab = Window:CreateTab("Info", nil)
local SchutzTab = Window:CreateTab("Schutz", nil)
local MoveTab = Window:CreateTab("Bewegung", nil)
local AutoTab = Window:CreateTab("Auto & Helis", nil)
local SpielerTab = Window:CreateTab("Spieler", nil)
local VisualTab = Window:CreateTab("Visual", nil)
local ExtraTab = Window:CreateTab("Extra", nil)
local TrollTab = Window:CreateTab("TROLL", nil)

--==================================================
-- HELPERS
--==================================================

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    end)
end

local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getACS()
    local char = getChar()
    return char and char:FindFirstChild("ACS_Client")
end

--==================================================
-- GUI
--==================================================

local specGui = Instance.new("ScreenGui")
specGui.Name = "BRPSpectateGui"
specGui.ResetOnSpawn = false
specGui.IgnoreGuiInset = true
specGui.DisplayOrder = 3000
specGui.Enabled = false
specGui.Parent = PlayerGui

local specBtn = Instance.new("TextButton")
specBtn.AnchorPoint = Vector2.new(1, 1)
specBtn.Position = UDim2.new(1, -24, 1, -24)
specBtn.Size = UDim2.new(0, 170, 0, 46)
specBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 55)
specBtn.Text = "Spectate aus"
specBtn.Font = Enum.Font.GothamBold
specBtn.TextColor3 = Color3.new(1, 1, 1)
specBtn.TextSize = 18
specBtn.Parent = specGui

Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 12)

local aimGui = Instance.new("ScreenGui")
aimGui.Name = "BRPAimGui"
aimGui.ResetOnSpawn = false
aimGui.IgnoreGuiInset = true
aimGui.DisplayOrder = 2500
aimGui.Parent = PlayerGui

local aimLab = Instance.new("TextLabel")
aimLab.AnchorPoint = Vector2.new(0.5, 0)
aimLab.Position = UDim2.new(0.5, 0, 0, 70)
aimLab.Size = UDim2.new(0, 420, 0, 28)
aimLab.BackgroundTransparency = 1
aimLab.Font = Enum.Font.GothamBold
aimLab.TextSize = 16
aimLab.TextColor3 = Color3.fromRGB(180, 240, 255)
aimLab.Text = ""
aimLab.Parent = aimGui

--==================================================
-- ESP FOLDERS
--==================================================

local marker = Instance.new("Part")
marker.Name = "BRPMarker"
marker.Anchored = true
marker.CanCollide = false
marker.CanTouch = false
marker.CanQuery = false
marker.Transparency = 1
marker.Size = Vector3.new(1, 1, 1)
marker.Parent = workspace

local espFolder = Instance.new("Folder")
espFolder.Name = "BRPESP"
espFolder.Parent = workspace

local heliEspFolder = Instance.new("Folder")
heliEspFolder.Name = "BRPHeliESP"
heliEspFolder.Parent = workspace

--==================================================
-- CHARACTER / PROTECTION
--==================================================

local function hideBewusstlos(hide)
    for _, name in ipairs({
        "BewusstlosUI",
        "BewusstlosUI_Script",
        "dead",
        "Damage"
    }) do
        local gui = PlayerGui:FindFirstChild(name)

        if gui then
            pcall(function()
                gui.Enabled = not hide
            end)
        end
    end
end

local function applyFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
end

local function clearDown()
    local char = getChar()
    local hum = getHum()

    if not char or not hum then
        return
    end

    pcall(function()
        hum.Health = math.max(hum.Health, 100)
    end)

    hum.PlatformStand = false

    if antiSit and not hum.SeatPart then
        hum.Sit = false
    end

    local down = char:FindFirstChild("IsDown")

    if down and down:IsA("BoolValue") then
        down.Value = false
    end

    local acs = getACS()

    if acs then
        pcall(function()
            acs:SetAttribute("Injured", false)
            acs:SetAttribute("Bleeding", false)
            acs:SetAttribute("Collapsed", false)
        end)
    end

    if hideDownUI then
        hideBewusstlos(true)
    end
end

--==================================================
-- VEHICLES
--==================================================

local function getVehicle()
    local hum = getHum()

    if not hum or not hum.SeatPart then
        return nil
    end

    return hum.SeatPart:FindFirstAncestorOfClass("Model")
end

local function getMovePart(vehicle)
    if not vehicle then
        return nil
    end

    return vehicle.PrimaryPart
        or vehicle:FindFirstChildWhichIsA("VehicleSeat", true)
        or vehicle:FindFirstChildWhichIsA("BasePart", true)
end

local function isVehicleModel(model)
    if not model then
        return false
    end

    return model:FindFirstChildWhichIsA("VehicleSeat", true)
        or model:FindFirstChildWhichIsA("Seat", true)
end

local function isHelicopter(model)
    if not model then
        return false
    end

    local name = string.lower(model.Name)

    return string.find(name, "heli") ~= nil
        or string.find(name, "hubsch") ~= nil
        or string.find(name, "christoph") ~= nil
        or string.find(name, "luft") ~= nil
end

local function zeroVel(vehicle)
    if not vehicle then
        return
    end

    for _, part in ipairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

local function vehicleFromHit(instance)
    if not instance then
        return nil
    end

    local model = instance:FindFirstAncestorOfClass("Model")
    local guard = 0

    while model and guard < 8 do
        guard += 1

        if isVehicleModel(model) and not Players:GetPlayerFromCharacter(model) then
            return model
        end

        model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
    end

    return nil
end

local function getAimedVehicle()
    local camera = getCamera()

    if not camera then
        return nil
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        getChar(),
        marker,
        espFolder,
        heliEspFolder
    }

    local result = workspace:Raycast(
        camera.CFrame.Position,
        camera.CFrame.LookVector * 160,
        params
    )

    if result then
        local vehicle = vehicleFromHit(result.Instance)

        if vehicle then
            return vehicle
        end
    end

    local boxPos = camera.CFrame.Position + camera.CFrame.LookVector * 10

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = {
        getChar(),
        marker,
        espFolder,
        heliEspFolder
    }

    local hits = workspace:GetPartBoundsInBox(
        CFrame.new(boxPos),
        Vector3.new(24, 16, 24),
        overlap
    )

    for _, part in ipairs(hits) do
        local vehicle = vehicleFromHit(part)

        if vehicle then
            return vehicle
        end
    end

    return nil
end

local function findNearbyHelicopters()
    local root = getRoot()

    if not root then
        return {}
    end

    local list = {}
    local seen = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not seen[obj] and isHelicopter(obj) then
            seen[obj] = true

            local part =
                obj.PrimaryPart
                or obj:FindFirstChildWhichIsA("BasePart", true)

            if part then
                local distance = (part.Position - root.Position).Magnitude

                if distance <= heliDetectionRange then
                    table.insert(list, {
                        Model = obj,
                        Part = part,
                        Distance = distance
                    })
                end
            end
        end
    end

    return list
end

--==================================================
-- VEHICLE TWEEN
--==================================================

local function stopMove()
    moving = false

    if moveConn then
        moveConn:Disconnect()
        moveConn = nil
    end
end

local function tweenVehicle(goal)
    local vehicle = getVehicle()

    if not vehicle then
        notify("Auto", "Kein Fahrzeug")
        return
    end

    if typeof(goal) ~= "CFrame" then
        return
    end

    stopMove()

    local startCF = vehicle:GetPivot()
    local startTime = tick()

    moving = true

    moveConn = RunService.Heartbeat:Connect(function()
        if not moving or not vehicle.Parent then
            stopMove()
            return
        end

        local duration = math.max(tweenTime, 0.05)
        local alpha = math.clamp(
            (tick() - startTime) / duration,
            0,
            1
        )

        local smooth = alpha * alpha * (3 - 2 * alpha)

        pcall(function()
            vehicle:PivotTo(startCF:Lerp(goal, smooth))
            zeroVel(vehicle)
        end)

        if alpha >= 1 then
            pcall(function()
                vehicle:PivotTo(goal)
                zeroVel(vehicle)
            end)

            stopMove()
        end
    end)
end

--==================================================
-- FREECAM
--==================================================

local function freezeBody()
    local root = getRoot()
    local hum = getHum()

    if root then
        freezeCFrame = root.CFrame
        root.Anchored = true
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    if hum then
        hum.WalkSpeed = 0
        hum.AutoRotate = false
        hum:Move(Vector3.zero, false)
    end
end

local function unfreezeBody()
    local root = getRoot()
    local hum = getHum()

    if root then
        root.Anchored = false

        if bodyToCam then
            local camera = getCamera()

            if camera then
                local _, yaw = camera.CFrame:ToEulerAnglesYXZ()

                root.CFrame =
                    CFrame.new(
                        camera.CFrame.Position - Vector3.new(0, 3, 0)
                    )
                    * CFrame.Angles(0, yaw, 0)
            end
        elseif freezeCFrame then
            root.CFrame = freezeCFrame
        end
    end

    if hum then
        hum.AutoRotate = true
        hum.WalkSpeed = speedOn and currentSpeed or 12
    end

    freezeCFrame = nil
end

local function stopFreecam()
    if not freecamOn then
        return
    end

    freecamOn = false

    if freecamConn then
        freecamConn:Disconnect()
        freecamConn = nil
    end

    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)

    unfreezeBody()

    if not spectating then
        local camera = getCamera()

        if camera then
            camera.CameraType = Enum.CameraType.Custom

            local hum = getHum()

            if hum then
                camera.CameraSubject = hum
            end
        end
    end

    aimLab.Text = ""
    notify("Freecam", "Aus")
end

local function startFreecam()
    if freecamOn then
        return
    end

    spectating = false
    specGui.Enabled = false

    local camera = getCamera()

    if not camera then
        return
    end

    freezeBody()

    local look = camera.CFrame

    freecamYaw = math.atan2(
        -look.LookVector.X,
        -look.LookVector.Z
    )

    freecamPitch = math.asin(
        math.clamp(look.LookVector.Y, -1, 1)
    )

    freecamOn = true

    camera.CameraType = Enum.CameraType.Scriptable

    pcall(function()
        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

        UserInputService.MouseIconEnabled = false
    end)

    if freecamConn then
        freecamConn:Disconnect()
    end

    freecamConn = RunService.RenderStepped:Connect(function(dt)
        if not freecamOn then
            return
        end

        local currentCamera = getCamera()

        if not currentCamera then
            return
        end

        currentCamera.CameraType = Enum.CameraType.Scriptable

        local alt =
            UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)

        pcall(function()
            UserInputService.MouseBehavior =
                alt
                and Enum.MouseBehavior.Default
                or Enum.MouseBehavior.LockCenter

            UserInputService.MouseIconEnabled = alt
        end)

        if not alt then
            local delta = UserInputService:GetMouseDelta()

            freecamYaw -= delta.X * 0.0025

            freecamPitch = math.clamp(
                freecamPitch - delta.Y * 0.0025,
                math.rad(-80),
                math.rad(80)
            )
        end

        local rot =
            CFrame.Angles(0, freecamYaw, 0)
            * CFrame.Angles(freecamPitch, 0, 0)

        local move = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move += rot.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move -= rot.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move -= rot.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move += rot.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            move += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            move -= Vector3.new(0, 1, 0)
        end

        local speed =
            UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            and freecamSpeed * 2
            or freecamSpeed

        local position = currentCamera.CFrame.Position

        if move.Magnitude > 0 then
            position += move.Unit * speed * dt
        end

        currentCamera.CFrame =
            CFrame.new(position) * rot

        local root = getRoot()
        local hum = getHum()

        if root and freezeCFrame then
            root.Anchored = true
            root.CFrame = freezeCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end

        if hum then
            hum.WalkSpeed = 0
            hum:Move(Vector3.zero, false)
        end
    end)

    notify(
        "Freecam",
        "WASD bewegen | Maus drehen | Alt = Maus frei"
    )
end

--==================================================
-- SPECTATE
--==================================================

local function stopSpectate()
    spectating = false
    specGui.Enabled = false

    if not freecamOn then
        local camera = getCamera()

        if camera then
            camera.CameraType = Enum.CameraType.Custom

            local hum = getHum()

            if hum then
                camera.CameraSubject = hum
            end
        end
    end
end

local function startSpectate(player)
    if not player or not player.Character then
        notify("Spectate", "Spieler nicht gefunden")
        return
    end

    local hum =
        player.Character:FindFirstChildOfClass("Humanoid")

    if not hum then
        notify("Spectate", "Humanoid nicht gefunden")
        return
    end

    if freecamOn then
        stopFreecam()
    end

    local camera = getCamera()

    if not camera then
        return
    end

    spectating = true
    specGui.Enabled = true

    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = hum
end

specBtn.MouseButton1Click:Connect(stopSpectate)

--==================================================
-- TRANSPARENCY
--==================================================

local function setCharTrans(value)
    local char = getChar()

    if not char then
        return
    end

    for _, object in ipairs(char:GetDescendants()) do
        if object:IsA("BasePart")
            and object.Name ~= "HumanoidRootPart" then

            object.LocalTransparencyModifier = value
        end
    end
end

--==================================================
-- TROLL
--==================================================

local function trollSpinRandom()
    local root = getRoot()

    if root then
        root.CFrame *= CFrame.Angles(
            math.rad(math.random(0, 360)),
            math.rad(math.random(0, 360)),
            math.rad(math.random(0, 360))
        )
    end
end

local function toggleInvisibility()
    trollInvisible = not trollInvisible

    setCharTrans(
        trollInvisible and 1 or 0
    )
end

local function trollFlyToggle(value)
    trollFly = value

    if trollFlyConn then
        trollFlyConn:Disconnect()
        trollFlyConn = nil
    end

    if not value then
        local root = getRoot()

        if root then
            root.AssemblyLinearVelocity = Vector3.zero
        end

        return
    end

    trollFlyConn = RunService.RenderStepped:Connect(function()
        if not trollFly then
            return
        end

        local root = getRoot()
        local camera = getCamera()

        if not root or not camera then
            return
        end

        local move = Vector3.zero
        local cf = camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move += cf.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move -= cf.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move -= cf.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move += cf.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            move -= Vector3.yAxis
        end

        if move.Magnitude > 0 then
            root.AssemblyLinearVelocity =
                move.Unit * trollFlySpeed
        else
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function trollSpinStart()
    if trollSpinConn then
        trollSpinConn:Disconnect()
        trollSpinConn = nil
    end

    trollSpin = true

    trollSpinConn = RunService.RenderStepped:Connect(function(dt)
        if not trollSpin then
            return
        end

        local root = getRoot()

        if root then
            root.CFrame *= CFrame.Angles(
                0,
                math.rad(trollSpinSpeed) * dt,
                0
            )
        end
    end)
end

local function trollSpinStop()
    trollSpin = false

    if trollSpinConn then
        trollSpinConn:Disconnect()
        trollSpinConn = nil
    end
end

--==================================================
-- INFO
--==================================================

local infoLabel = InfoTab:CreateParagraph({
    Title = "Status",
    Content = "Lädt..."
})

local function refreshInfo()
    pcall(function()
        infoLabel:Set(
            "Team: "
            .. tostring(
                LocalPlayer:GetAttribute("CurrentTeamName")
            )
            .. "\nFreecam: "
            .. tostring(freecamOn)
            .. "\nZiel-Auto: "
            .. tostring(aimedName)
        )
    end)
end

InfoTab:CreateButton({
    Name = "Status aktualisieren",
    Callback = refreshInfo
})

--==================================================
-- SCHUTZ
--==================================================

SchutzTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,

    Callback = function(value)
        antiAfk = value

        if afkConn then
            afkConn:Disconnect()
            afkConn = nil
        end

        if value then
            afkConn = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end
    end
})

SchutzTab:CreateToggle({
    Name = "Unsterblichkeit",
    CurrentValue = false,

    Callback = function(value)
        godmode = value

        if value then
            clearDown()
        end
    end
})

SchutzTab:CreateToggle({
    Name = "Anti Down",
    CurrentValue = false,

    Callback = function(value)
        antiDown = value

        if value then
            clearDown()
        end
    end
})

SchutzTab:CreateToggle({
    Name = "Anti Taser",
    CurrentValue = false,

    Callback = function(value)
        antiTaser = value
    end
})

SchutzTab:CreateToggle({
    Name = "Anti Blutung",
    CurrentValue = false,

    Callback = function(value)
        antiBleed = value
    end
})

SchutzTab:CreateToggle({
    Name = "Bewusstlos-UI aus",
    CurrentValue = false,

    Callback = function(value)
        hideDownUI = value
        hideBewusstlos(value)
    end
})

SchutzTab:CreateToggle({
    Name = "Anti Sit",
    CurrentValue = false,

    Callback = function(value)
        antiSit = value == true
    end
})

SchutzTab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = false,

    Callback = function(value)
        antiVoid = value
    end
})

SchutzTab:CreateButton({
    Name = "Jetzt reanimieren",
    Callback = clearDown
})

--==================================================
-- BEWEGUNG
--==================================================

MoveTab:CreateParagraph({
    Title = "Freecam",
    Content = "Shift+P | Maus drehen | Alt = Maus frei"
})

MoveTab:CreateToggle({
    Name = "WalkSpeed",
    CurrentValue = false,

    Callback = function(value)
        speedOn = value

        if not freecamOn then
            local hum = getHum()

            if hum then
                hum.WalkSpeed =
                    value and currentSpeed or 12
            end
        end
    end
})

MoveTab:CreateSlider({
    Name = "Speed",
    Range = {12, 50},
    Increment = 1,
    CurrentValue = 16,

    Callback = function(value)
        currentSpeed = value
    end
})

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,

    Callback = function(value)
        infJump = value
    end
})

MoveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,

    Callback = function(value)
        noclipOn = value

        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end

        if value then
            noclipConn = RunService.Stepped:Connect(function()
                local char = getChar()

                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

MoveTab:CreateToggle({
    Name = "Freecam",
    CurrentValue = false,

    Callback = function(value)
        if value then
            startFreecam()
        else
            stopFreecam()
        end
    end
})

MoveTab:CreateSlider({
    Name = "Freecam Speed",
    Range = {20, 200},
    Increment = 5,
    CurrentValue = 60,

    Callback = function(value)
        freecamSpeed = value
    end
})

MoveTab:CreateToggle({
    Name = "Körper zur Cam beim Aus",
    CurrentValue = false,

    Callback = function(value)
        bodyToCam = value
    end
})

MoveTab:CreateToggle({
    Name = "Click TP zu Fuß",
    CurrentValue = false,

    Callback = function(value)
        clickFootTP = value
    end
})

--==================================================
-- AUTO & HELIS
--==================================================

AutoTab:CreateSlider({
    Name = "Tween Dauer",
    Range = {0.4, 6},
    Increment = 0.1,
    CurrentValue = 1.4,

    Callback = function(value)
        tweenTime = value
    end
})

AutoTab:CreateButton({
    Name = "Fahrzeug zum Spieler gleiten",

    Callback = function()
        local target =
            Players:FindFirstChild(selectedPlayer)

        local vehicle = getVehicle()

        if vehicle
            and target
            and target.Character then

            local targetRoot =
                target.Character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if targetRoot then
                tweenVehicle(
                    targetRoot.CFrame
                    * CFrame.new(
                        0,
                        isHelicopter(vehicle) and 18 or 5,
                        12
                    )
                )
            end
        end
    end
})

AutoTab:CreateToggle({
    Name = "Click Tween Fahrzeug",
    CurrentValue = false,

    Callback = function(value)
        clickCarTP = value
    end
})

AutoTab:CreateToggle({
    Name = "Autos schieben",
    CurrentValue = false,

    Callback = function(value)
        pushCars = value

        notify(
            "Schieben",
            value
            and "LMB = weg | RMB = her"
            or "Aus"
        )
    end
})

AutoTab:CreateSlider({
    Name = "Schiebe-Stärke",
    Range = {20, 1000},
    Increment = 10,
    CurrentValue = 1000,

    Callback = function(value)
        pushPower = value
    end
})

AutoTab:CreateToggle({
    Name = "Helikopter ESP",
    CurrentValue = false,

    Callback = function(value)
        heliESP = value

        if not value then
            heliEspFolder:ClearAllChildren()
        end
    end
})

AutoTab:CreateButton({
    Name = "Tween stoppen",
    Callback = stopMove
})

--==================================================
-- SPIELER
--==================================================

local dropdown = SpielerTab:CreateDropdown({
    Name = "Spieler",
    Options = {"Niemand"},
    CurrentOption = {"Niemand"},
    MultipleOptions = false,

    Callback = function(option)
        if type(option) == "table" then
            selectedPlayer = option[1] or "Niemand"
        else
            selectedPlayer = option
        end
    end
})

local function refreshPlayers()
    local list = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end

    if #list == 0 then
        list = {"Niemand"}
    end

    pcall(function()
        dropdown:Refresh(list)
    end)

    if not table.find(list, selectedPlayer) then
        selectedPlayer = "Niemand"
    end
end

SpielerTab:CreateButton({
    Name = "Liste aktualisieren",
    Callback = refreshPlayers
})

SpielerTab:CreateButton({
    Name = "Spectate",

    Callback = function()
        startSpectate(
            Players:FindFirstChild(selectedPlayer)
        )
    end
})

SpielerTab:CreateButton({
    Name = "Spectate aus",
    Callback = stopSpectate
})

--==================================================
-- VISUAL
--==================================================

VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,

    Callback = function(value)
        fullbright = value == true

        if fullbright then
            applyFullbright()
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
        end
    end
})

VisualTab:CreateSlider({
    Name = "FOV",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = 70,

    Callback = function(value)
        currentFOV = value
    end
})

VisualTab:CreateToggle({
    Name = "Spieler ESP",
    CurrentValue = false,

    Callback = function(value)
        espOn = value

        if not value then
            espFolder:ClearAllChildren()
        end
    end
})

--==================================================
-- EXTRA
--==================================================

ExtraTab:CreateButton({
    Name = "Rejoin",

    Callback = function()
        pcall(function()
            TeleportService:Teleport(
                game.PlaceId,
                LocalPlayer
            )
        end)
    end
})

--==================================================
-- TROLL TAB
--==================================================

TrollTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,

    Callback = function(value)
        trollFlyToggle(value)
    end
})

TrollTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,

    Callback = function(value)
        if value then
            trollSpinStart()
        else
            trollSpinStop()
        end
    end
})

TrollTab:CreateButton({
    Name = "Troll Unsichtbar toggeln",

    Callback = function()
        toggleInvisibility()
    end
})

TrollTab:CreateButton({
    Name = "Troll Zufälliges Drehen",

    Callback = function()
        trollSpinRandom()
    end
})

--==================================================
-- AUTO PUSH/PULL
--==================================================

MoveTab:CreateToggle({
    Name = "Auto Push/Pull",
    CurrentValue = false,

    Callback = function(value)
        autoPushPullEnabled = value
    end
})

local function doAutoPushPull()
    if not autoPushPullEnabled then
        return
    end

    local vehicle = getAimedVehicle()

    if not vehicle then
        return
    end

    local movePart = getMovePart(vehicle)

    if not movePart then
        return
    end

    local camera = getCamera()

    if not camera then
        return
    end

    local direction = camera.CFrame.LookVector

    if UserInputService:IsKeyDown(Enum.KeyCode.R) then
        direction = -direction
    end

    pcall(function()
        movePart.AssemblyLinearVelocity =
            direction.Unit * pushPower

        movePart.AssemblyAngularVelocity =
            Vector3.zero
    end)
end

--==================================================
-- INPUT
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    --================================================
    -- C = AUTOS SCHIEBEN AN/AUS
    --================================================

    if input.KeyCode == Enum.KeyCode.C then
        pushCars = not pushCars

        notify(
            "Autos schieben",
            pushCars
            and "An | LMB = weg | RMB = her"
            or "Aus",
            3
        )
    end

    -- Shift + P = Freecam
    if input.KeyCode == Enum.KeyCode.P
        and UserInputService:IsKeyDown(
            Enum.KeyCode.LeftShift
        ) then

        if freecamOn then
            stopFreecam()
        else
            startFreecam()
        end
    end

    -- Mittlere Maustaste
    if input.UserInputType ==
        Enum.UserInputType.MouseButton3
        and not freecamOn then

        local mouse = LocalPlayer:GetMouse()
        local hit = mouse.Hit

        if not hit then
            return
        end

        if clickCarTP then
            local vehicle = getVehicle()

            if vehicle then
                tweenVehicle(
                    CFrame.new(
                        hit.Position
                        + Vector3.new(
                            0,
                            isHelicopter(vehicle) and 16 or 4,
                            0
                        )
                    )
                )
            end

        elseif clickFootTP then
            local root = getRoot()

            if root then
                root.CFrame =
                    CFrame.new(
                        hit.Position
                        + Vector3.new(0, 3, 0)
                    )
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if freecamOn then
        return
    end

    if infJump then
        local hum = getHum()

        if hum then
            hum:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    if trollInvisible then
        setCharTrans(1)
    end

    if speedOn and not freecamOn then
        local hum = getHum()

        if hum then
            hum.WalkSpeed = currentSpeed
        end
    end

    if antiDown then
        clearDown()
    end
end)

--==================================================
-- HEARTBEAT
--==================================================

RunService.Heartbeat:Connect(function()
    local char = getChar()
    local hum = getHum()
    local root = getRoot()
    local camera = getCamera()

    specGui.Enabled = spectating

    if fullbright then
        applyFullbright()
    end

    if godmode and hum then
        pcall(function()
            hum.Health = math.max(hum.Health, 100)
        end)
    end

    if antiDown then
        clearDown()
    end

    if antiTaser and hum then
        hum.PlatformStand = false
    end

    if antiSit
        and hum
        and hum.Sit
        and not hum.SeatPart then

        hum.Sit = false
    end

    if antiVoid
        and root
        and root.Position.Y < -50
        and not freecamOn then

        root.CFrame = CFrame.new(0, 20, 0)
    end

    if speedOn
        and hum
        and not hum.SeatPart
        and not freecamOn then

        hum.WalkSpeed = currentSpeed
    end

    if hideDownUI then
        hideBewusstlos(true)
    end

    if camera then
        camera.FieldOfView = currentFOV
    end

    if trollInvisible then
        setCharTrans(1)
    end

    if freecamOn
        and root
        and freezeCFrame then

        root.Anchored = true
        root.CFrame = freezeCFrame
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    --==============================================
    -- VEHICLE TARGET
    --==============================================

    local vehicle = getAimedVehicle()

    aimedName =
        vehicle and vehicle.Name or "-"

    if pushCars then
        if vehicle then
            aimLab.Text =
                "Ziel: "
                .. vehicle.Name
                .. " | LMB weg | RMB her"
        else
            aimLab.Text =
                "Kein Auto im Fadenkreuz"
        end

        local lmb =
            UserInputService:IsMouseButtonPressed(
                Enum.UserInputType.MouseButton1
            )

        local rmb =
            UserInputService:IsMouseButtonPressed(
                Enum.UserInputType.MouseButton2
            )

        if vehicle and (lmb or rmb) then
            local movePart =
                getMovePart(vehicle)

            if movePart and camera then
                local direction =
                    camera.CFrame.LookVector

                if rmb then
                    direction = -direction
                end

                pcall(function()
                    movePart.AssemblyLinearVelocity =
                        direction.Unit * pushPower

                    movePart.AssemblyAngularVelocity =
                        Vector3.zero
                end)
            end
        end

        -- Auto Push/Pull
        if autoPushPullEnabled then
            doAutoPushPull()
        end
    else
        aimLab.Text =
            freecamOn and "Freecam" or ""
    end
end)

--==================================================
-- PERIODISCHER REFRESH
--==================================================

task.spawn(function()
    while task.wait(1) do
        refreshInfo()
        refreshPlayers()

        -- Spieler ESP
        if espOn then
            espFolder:ClearAllChildren()

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer
                    and player.Character then

                    local highlight =
                        Instance.new("Highlight")

                    highlight.Name = "PlayerESP"
                    highlight.Adornee =
                        player.Character

                    highlight.FillColor =
                        Color3.fromRGB(
                            140,
                            90,
                            255
                        )

                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                end
            end
        else
            espFolder:ClearAllChildren()
        end

        -- Helikopter ESP
        if heliESP then
            heliEspFolder:ClearAllChildren()

            for _, data in ipairs(
                findNearbyHelicopters()
            ) do

                if data.Model
                    and data.Model.Parent then

                    local highlight =
                        Instance.new("Highlight")

                    highlight.Name = "HeliESP"
                    highlight.Adornee =
                        data.Model

                    highlight.FillColor =
                        Color3.fromRGB(
                            80,
                            200,
                            255
                        )

                    highlight.FillTransparency = 0.65
                    highlight.OutlineTransparency = 0
                    highlight.Parent =
                        heliEspFolder
                end
            end
        else
            heliEspFolder:ClearAllChildren()
        end
    end
end)

--==================================================
-- ANTI AFK DIREKT STARTEN
--==================================================

if antiAfk then
    afkConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

--==================================================
-- START
--==================================================

refreshPlayers()
refreshInfo()

notify(
    "BRP Helper v2",
    "Geladen | C = Autos schieben | Shift+P Freecam | LMB/RMB Fahrzeug",
    5
)