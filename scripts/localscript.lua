local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("CoolStudioFlyRemote")

local flySpeed = 408
local flying = false
local noclip = false
local bodyVelocity
local bodyGyro
local flyConnection
local stateConnection
local flyKeyConnection
local noclipConnection
local minimized = false
local isAnimating = false
local allowSitting = true
local autoJumpOnDisable = true
local sliding = false

local gui = Instance.new("ScreenGui")
gui.Name = "CoolStudioFly"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Parent = gui
frame.Size = UDim2.fromOffset(210, 210)
frame.Position = UDim2.new(0.5, -105, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(16, 0, 28)
frame.BorderSizePixel = 0
frame.Active = true

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(210, 70, 255)
frameStroke.Parent = frame

local dragging = false
local dragStart
local startPos

local dragArea = Instance.new("Frame")
dragArea.Parent = frame
dragArea.BackgroundTransparency = 1
dragArea.Size = UDim2.new(1, -60, 0, 42)
dragArea.Position = UDim2.fromOffset(0, 0)
dragArea.Active = true

dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

dragArea.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		dragStart = dragStart or input.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not frameStroke.Parent then
		return
	end

	local i = (math.sin(tick() * 2) + 1) / 2
	frameStroke.Color = Color3.fromRGB(160 + 80 * i, 50, 255)
end)

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -70, 0, 38)
title.Position = UDim2.fromOffset(8, 2)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextColor3 = Color3.fromRGB(230, 120, 255)
title.Text = "CoolStudio"
title.TextXAlignment = Enum.TextXAlignment.Left

local function makeIcon(text, x)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.fromOffset(25, 25)
	b.Position = UDim2.new(1, x, 0, 7)
	b.BackgroundColor3 = Color3.fromRGB(92, 28, 168)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(230, 140, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.AutoButtonColor = false

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = b

	local normalSize = UDim2.fromOffset(25, 25)
	local hoverSize = UDim2.fromOffset(30, 30)

	b.MouseEnter:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = hoverSize,
				Position = UDim2.new(1, x - 2.5, 0, 4.5)
			}
		):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = normalSize,
				Position = UDim2.new(1, x, 0, 7)
			}
		):Play()
	end)

	b.MouseButton1Down:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.07),
			{
				Size = UDim2.fromOffset(22, 22)
			}
		):Play()
	end)

	b.MouseButton1Up:Connect(function()
		TweenService:Create(
			b,
			TweenInfo.new(0.07),
			{
				Size = hoverSize
			}
		):Play()
	end)

	return b
end

local minBtn = makeIcon("-", -58)
local closeBtn = makeIcon("X", -28)

local speedText = Instance.new("TextLabel")
speedText.Parent = frame
speedText.BackgroundTransparency = 1
speedText.Size = UDim2.new(1, -20, 0, 18)
speedText.Position = UDim2.fromOffset(10, 38)
speedText.Font = Enum.Font.Gotham
speedText.TextSize = 12
speedText.TextColor3 = Color3.fromRGB(210, 140, 255)
speedText.Text = "FlySpeed: 408"

local bar = Instance.new("Frame")
bar.Parent = frame
bar.Size = UDim2.new(1, -40, 0, 6)
bar.Position = UDim2.fromOffset(20, 60)
bar.BackgroundColor3 = Color3.fromRGB(70, 20, 120)
bar.BorderSizePixel = 0

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = bar

local fill = Instance.new("Frame")
fill.Parent = bar
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(200, 80, 255)
fill.BorderSizePixel = 0

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local knob = Instance.new("Frame")
knob.Parent = bar
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Size = UDim2.fromOffset(14, 14)
knob.Position = UDim2.new(1, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(230, 150, 255)
knob.BorderSizePixel = 0
knob.ZIndex = 3

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

local function makeToggle(name, y, on)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(1, -40, 0, 27)
	b.Position = UDim2.fromOffset(20, y)
	b.BackgroundColor3 = on and Color3.fromRGB(0, 200, 95) or Color3.fromRGB(70, 20, 110)
	b.Text = name .. ": " .. (on and "ON" or "OFF")
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b

	return b
end

local sitBtn = makeToggle("Sitzen", 72, true)
local jumpBtn = makeToggle("Auto-Jump", 104, true)
local noclipBtn = makeToggle("Noclip", 136, false)

local flyBtn = Instance.new("TextButton")
flyBtn.Parent = frame
flyBtn.Size = UDim2.new(1, -40, 0, 28)
flyBtn.Position = UDim2.fromOffset(20, 168)
flyBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 230)
flyBtn.Text = "FLY OFF"
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 14

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyBtn

local extras = {
	speedText,
	bar,
	sitBtn,
	jumpBtn,
	noclipBtn,
	flyBtn
}

local function setSpeed(v)
	flySpeed = math.clamp(math.floor(v + 0.5), 10, 500)
	speedText.Text = "FlySpeed: " .. flySpeed

	local a = (flySpeed - 10) / 490

	fill.Size = UDim2.new(a, 0, 1, 0)
	knob.Position = UDim2.new(a, 0, 0.5, 0)
end

local function speedFromX(x)
	local rel = math.clamp(
		(x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1),
		0,
		1
	)

	setSpeed(10 + rel * 490)
end

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		sliding = true
		speedFromX(input.Position.X)
	end
end)

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		sliding = true
	end
end)

UIS.InputChanged:Connect(function(input)
	if sliding and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		speedFromX(input.Position.X)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		sliding = false
	end
end)

local function paintToggle(btn, on, label)
	btn.BackgroundColor3 = on
		and Color3.fromRGB(0, 200, 95)
		or Color3.fromRGB(70, 20, 110)

	btn.Text = label .. ": " .. (on and "ON" or "OFF")
end

sitBtn.MouseButton1Click:Connect(function()
	allowSitting = not allowSitting
	paintToggle(sitBtn, allowSitting, "Sitzen")
end)

jumpBtn.MouseButton1Click:Connect(function()
	autoJumpOnDisable = not autoJumpOnDisable
	paintToggle(jumpBtn, autoJumpOnDisable, "Auto-Jump")
end)

local function setNoclip(state)
	noclip = state

	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	if noclip then
		noclipConnection = RunService.Stepped:Connect(function()
			local char = player.Character

			if not char then
				return
			end

			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		local char = player.Character

		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end

	paintToggle(noclipBtn, noclip, "Noclip")
end

noclipBtn.MouseButton1Click:Connect(function()
	setNoclip(not noclip)
end)

local function updateFlyButton()
	if flying then
		flyBtn.Text = "FLY ON"
		flyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 95)
	else
		flyBtn.Text = "FLY OFF"
		flyBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 230)
	end
end

local function stopFly(silent)
	flying = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if stateConnection then
		stateConnection:Disconnect()
		stateConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if hum then
		hum.PlatformStand = false

		if autoJumpOnDisable then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	if not silent then
		updateFlyButton()
	end
end

local function startFly()
	local char = player.Character

	if not char then
		return
	end

	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")

	if not root or not hum then
		return
	end

	if flying then
		stopFly(true)
	end

	flying = true

	if not allowSitting then
		hum.Sit = false
	end

	hum.PlatformStand = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.P = 12500
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.P = 20000
	bodyGyro.D = 500
	bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	bodyGyro.Parent = root

	stateConnection = hum.StateChanged:Connect(function()
		if flying and hum then
			hum.PlatformStand = true
		end
	end)

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying then
			return
		end

		char = player.Character
		root = char and char:FindFirstChild("HumanoidRootPart")
		hum = char and char:FindFirstChildOfClass("Humanoid")

		if not root or not hum then
			return
		end

		if not bodyVelocity or not bodyGyro then
			return
		end

		local cam = workspace.CurrentCamera.CFrame
		local move = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			move += cam.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.S) then
			move -= cam.LookVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.A) then
			move -= cam.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.D) then
			move += cam.RightVector
		end

		if UIS:IsKeyDown(Enum.KeyCode.E) then
			move += Vector3.new(0, 1, 0)
		end

		if UIS:IsKeyDown(Enum.KeyCode.Q) then
			move -= Vector3.new(0, 1, 0)
		end

		if move.Magnitude > 0 then
			bodyVelocity.Velocity = move.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.zero
		end

		bodyGyro.CFrame = cam
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	updateFlyButton()
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly(false)
	else
		startFly()
	end
end)

minBtn.MouseButton1Click:Connect(function()
	if isAnimating then
		return
	end

	isAnimating = true
	minimized = not minimized

	if minimized then
		TweenService:Create(
			frame,
			TweenInfo.new(0.2),
			{Size = UDim2.fromOffset(210, 45)}
		):Play()

		for _, o in ipairs(extras) do
			o.Visible = false
		end

		minBtn.Text = "+"
	else
		TweenService:Create(
			frame,
			TweenInfo.new(0.2),
			{Size = UDim2.fromOffset(210, 210)}
		):Play()

		for _, o in ipairs(extras) do
			o.Visible = true
		end

		minBtn.Text = "-"
	end

	task.delay(0.25, function()
		isAnimating = false
	end)
end)

closeBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly(true)
	end

	setNoclip(false)

	if flyKeyConnection then
		flyKeyConnection:Disconnect()
	end

	gui.Enabled = false
end)

flyKeyConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not gui.Enabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		if flying then
			stopFly(false)
		else
			startFly()
		end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.5)

	if noclip then
		setNoclip(true)
	end

	if flying then
		flying = false
		startFly()
	end
end)

player.CharacterRemoving:Connect(function()
	if flying then
		stopFly(true)
	end
end)

remote.OnClientEvent:Connect(function()
	gui.Enabled = true

	if flying then
		stopFly(false)
	else
		startFly()
	end

	updateFlyButton()
end)

updateFlyButton()
setSpeed(408)