if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    local np = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
    if np then
        if np:IsA("ScreenGui") then np.Enabled = false end
        np:Destroy()
    end
end)

local autoWinFire = false
local autoWinTP = false
local autoPadsToMe = false
local autoSpeed = false
local speedAmount = 4
local minimized = false

local gui = Instance.new("ScreenGui")
gui.Name = "Michael Jackson"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 360)
frame.Position = UDim2.new(0.5, -110, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 30)
top.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Helper"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 22)
minBtn.Position = UDim2.new(1, -58, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = top
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 22)
closeBtn.Position = UDim2.new(1, -30, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = top
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = frame

local function makeToggle(name, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 32)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = name .. ": " .. (on and "ON" or "OFF")
        btn.BackgroundColor3 = on and Color3.fromRGB(70, 120, 70) or Color3.fromRGB(60, 60, 60)
        callback(on)
    end)
end

makeToggle("Auto Win Fire", 10, function(v) autoWinFire = v end)
makeToggle("World4 Pads Reihe", 50, function(v) autoWinTP = v end)
makeToggle("Zu 3 Pads Reverse", 90, function(v) autoPadsToMe = v end)
makeToggle("Auto Speed", 130, function(v) autoSpeed = v end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.85, 0, 0, 20)
speedLabel.Position = UDim2.new(0.075, 0, 0, 170)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 4"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.Parent = content

local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 36, 0, 24)
minus.Position = UDim2.new(0.075, 0, 0, 194)
minus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minus.Text = "-"
minus.TextColor3 = Color3.new(1, 1, 1)
minus.Font = Enum.Font.GothamBold
minus.TextSize = 16
minus.Parent = content
Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 6)

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 36, 0, 24)
plus.Position = UDim2.new(0.85, -36, 0, 194)
plus.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
plus.Text = "+"
plus.TextColor3 = Color3.new(1, 1, 1)
plus.Font = Enum.Font.GothamBold
plus.TextSize = 16
plus.Parent = content
Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 6)

minus.MouseButton1Click:Connect(function()
    speedAmount = math.max(1, speedAmount - 1)
    speedLabel.Text = "Speed: " .. speedAmount
end)

local listBtn = Instance.new("TextButton")
listBtn.Size = UDim2.new(0.85, 0, 0, 24)
listBtn.Position = UDim2.new(0.075, 0, 0, 184)
listBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
listBtn.Text = "Positionen"
listBtn.TextColor3 = Color3.new(1, 1, 1)
listBtn.Font = Enum.Font.Gotham
listBtn.TextSize = 13
listBtn.Parent = content
Instance.new("UICorner", listBtn).CornerRadius = UDim.new(0, 6)

listBtn.MouseButton1Click:Connect(function()
    local rows = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Name == "SectionAwardPart" and o:IsA("BasePart") then
            table.insert(rows, string.format(
                "%.1f, %.1f, %.1f",
                o.Position.X,
                o.Position.Y,
                o.Position.Z
            ))
        end
    end
    print(table.concat(rows, "\n"))
    if setclipboard then
        setclipboard(table.concat(rows, "\n"))
    end
end)

local petBtn = Instance.new("TextButton")
petBtn.Size = UDim2.new(0.85, 0, 0, 24)
petBtn.Position = UDim2.new(0.075, 0, 0, 212)
petBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
petBtn.Text = "Pets Slot 0 loeschen"
petBtn.TextColor3 = Color3.new(1, 1, 1)
petBtn.Font = Enum.Font.Gotham
petBtn.TextSize = 13
petBtn.Parent = content
Instance.new("UICorner", petBtn).CornerRadius = UDim.new(0, 6)

petBtn.MouseButton1Click:Connect(function()
    local pets = LocalPlayer:FindFirstChild("Pets")
    if not pets then return end

    local n = 0
    for _, pet in ipairs(pets:GetChildren()) do
        if pet:GetAttribute("Slot") == 0 then
            pet:Destroy()
            n += 1
        end
    end
    print("Pets geloescht: " .. n)
end)

plus.MouseButton1Click:Connect(function()
    speedAmount = math.min(50, speedAmount + 1)
    speedLabel.Text = "Speed: " .. speedAmount
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    frame.Size = minimized
        and UDim2.new(0, 220, 0, 30)
        or UDim2.new(0, 220, 0, 360)
end)

closeBtn.MouseButton1Click:Connect(function()
    autoWinFire = false
    autoWinTP = false
    autoPadsToMe = false
    autoSpeed = false
    gui:Destroy()
end)

local dragging, dragStart, startPos

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

top.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local cachedPart

local function findAward(targetPos)
    if cachedPart and cachedPart.Parent
        and (cachedPart.Position - targetPos).Magnitude < 12 then
        return cachedPart
    end

    local best, bestD
    local worlds = {
        workspace:FindFirstChild("World4"),
        workspace:FindFirstChild("World3"),
        workspace
    }

    for _, world in ipairs(worlds) do
        if world then
            for _, o in ipairs(world:GetDescendants()) do
                if o.Name == "SectionAwardPart" and o:IsA("BasePart") then
                    local d = (o.Position - targetPos).Magnitude
                    if d < 12 and (not bestD or d < bestD) then
                        best, bestD = o, d
                    end
                end
            end
        end
        if best then break end
    end

    cachedPart = best
    return best
end

task.spawn(function()
    while gui.Parent do
        task.wait(0.4)

        if autoWinTP then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then return end

                local world = workspace:FindFirstChild("World4")
                if not world then return end

                local pads = {}
                for _, o in ipairs(world:GetDescendants()) do
                    if o.Name == "SectionAwardPart" and o:IsA("BasePart") then
                        table.insert(pads, o)
                    end
                end

                table.sort(pads, function(a, b)
                    return a.Position.Magnitude < b.Position.Magnitude
                end)

                for _, pad in ipairs(pads) do
                    if not autoWinTP then return end
                    if not root.Parent then return end
                    root.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.6)
                end

                if not autoWinTP then return end
                if hum and hum.Parent and hum.Health > 0 then
                    hum.Health = 0
                end

                local t0 = os.clock()
                while LocalPlayer.Character == char and os.clock() - t0 < 6 do
                    task.wait(0.2)
                end
                task.wait(0.4)
            end)

        elseif autoPadsToMe then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum or hum.Health <= 0 then return end

                -- Pad 1 -> Pad 2 -> Pad 3
                local padCFrames = {
                    -- Pad 1
                    CFrame.new(
                        -604.657471, 680.416504, 1935.35535,
                        1, 0, 0, 0, 1, 0, 0, 0, 1
                    ),
                    -- Pad 2
                    CFrame.new(
                        -604.657471, 680.416504, 2317.35547,
                        1, 0, 0, 0, 1, 0, 0, 0, 1
                    ),
                    -- Pad 3
                    CFrame.new(
                        -604.657471, 680.416504, 3227.35547,
                        1, 0, 0, 0, 1, 0, 0, 0, 1
                    )
                }

                for i = 1, #padCFrames do
                    if not autoPadsToMe or not root.Parent then return end

                    root.CFrame = padCFrames[i] + Vector3.new(0, 3, 0)

                    -- Wartezeit zwischen den Pads: 0,5 Sekunden
                    task.wait(0.5)

                    pcall(function()
                        if LocalPlayer.RequestStreamAroundAsync then
                            LocalPlayer:RequestStreamAroundAsync(
                                padCFrames[i].Position
                                + (padCFrames[i].Position - Vector3.zero).Unit * 200
                            )
                        end
                    end)
                end

                if not autoPadsToMe then return end
                if hum and hum.Parent and hum.Health > 0 then
                    hum.Health = 0
                end

                local t0 = os.clock()
                while LocalPlayer.Character == char and os.clock() - t0 < 6 do
                    task.wait(0.2)
                end
                task.wait(0.4)
            end)

        elseif autoWinFire then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local targetPos = Vector3.new(
                    -604.657471,
                    680.416504,
                    3227.35547
                )

                if (root.Position - targetPos).Magnitude > 30 then
                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                    task.wait(0.3)
                end

                local part = findAward(targetPos)
                if part and firetouchinterest then
                    local touch = part:FindFirstChild("TouchInterest")
                        or part:FindFirstChildOfClass("TouchTransmitter")

                    if touch then
                        firetouchinterest(root, part, 0)
                        task.wait(0.05)
                        firetouchinterest(root, part, 1)
                    end

                    task.wait(0.2)

                    local hum = LocalPlayer.Character
                        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

                    if hum and hum.Health > 0 then
                        hum.Health = 0
                    end

                    local t0 = os.clock()
                    while LocalPlayer.Character == char and os.clock() - t0 < 6 do
                        task.wait(0.2)
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        task.wait(0.15)

        if autoSpeed then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")

                if hum and root then
                    local pos = root.CFrame
                    hum:Move(Vector3.new(0, 0, -1), false)
                    task.wait(0.08)
                    if root and root.Parent then
                        root.CFrame = pos
                    end
                end
            end)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("Hehe Michael Jackson")