local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local MANAGEMENT_ID = 10629049912
local ADMIN_ID = 3332191418
local MODERATOR_ID = 0
local VIP_ID = 11166928484

local WRENCH_ICON = "rbxassetid://86041844180011"
local VERIFIED_ICON = "rbxassetid://116749530433643"
local VIP_ICON = "rbxassetid://104106258195387"

local TAG_NAME = "MyGameRankTag"
local active = {}

local function getOrCreateCommand(name, alias)
	local command = TextChatService:FindFirstChild(name)

	if not command then
		command = Instance.new("TextChatCommand")
		command.Name = name
		command.Parent = TextChatService
	end

	command.PrimaryAlias = alias
	return command
end

local managementCommand = getOrCreateCommand("ManagementCommand", "!management")
local staffCommand = getOrCreateCommand("StaffToggleCommand", "!staff")
local vipCommand = getOrCreateCommand("VipToggleCommand", "!vip")

local function deleteTag(player)
	local character = player.Character
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	for _, object in ipairs(head:GetChildren()) do
		if object:IsA("BillboardGui") then
			if object.Name == TAG_NAME or object.Name == "ManagementTag" or object.Name == "RankTag" then
				object:Destroy()
			end
		end
	end
end

local function createTextTag(player, textValue, color)
	local character = player.Character
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	deleteTag(player)

	local tag = Instance.new("BillboardGui")
	tag.Name = TAG_NAME
	tag.Adornee = head
	tag.Size = UDim2.fromOffset(160, 28)
	tag.StudsOffset = Vector3.new(0, 3.2, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 100
	tag.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = textValue
	label.TextColor3 = color
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0.35
	label.Parent = tag
end

local function createManagementTag(player)
	local character = player.Character
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	deleteTag(player)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = TAG_NAME
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(210, 36)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 100
	billboard.Parent = head

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local wrench = Instance.new("ImageLabel")
	wrench.Name = "Wrench"
	wrench.Size = UDim2.fromOffset(21, 21)
	wrench.Position = UDim2.new(0, 5, 0.5, -10)
	wrench.BackgroundTransparency = 1
	wrench.Image = WRENCH_ICON
	wrench.Parent = frame

	local text = Instance.new("TextLabel")
	text.Name = "ManagementText"
	text.Size = UDim2.fromOffset(120, 24)
	text.Position = UDim2.new(0.5, -60, 0.5, -12)
	text.BackgroundTransparency = 1
	text.Text = "MANAGEMENT"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextSize = 14
	text.Font = Enum.Font.GothamBold
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextStrokeTransparency = 0.35
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Parent = frame

	local verified = Instance.new("ImageLabel")
	verified.Name = "Verified"
	verified.Size = UDim2.fromOffset(21, 21)
	verified.Position = UDim2.new(1, -26, 0.5, -10)
	verified.BackgroundTransparency = 1
	verified.Image = VERIFIED_ICON
	verified.Parent = frame
end

local function createVipTag(player)
	local character = player.Character
	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	deleteTag(player)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = TAG_NAME
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(120, 36)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 100
	billboard.Parent = head

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local icon = Instance.new("ImageLabel")
	icon.Name = "VipIcon"
	icon.Size = UDim2.fromOffset(21, 21)
	icon.Position = UDim2.new(0, 5, 0.5, -10)
	icon.BackgroundTransparency = 1
	icon.Image = VIP_ICON
	icon.Parent = frame

	local text = Instance.new("TextLabel")
	text.Name = "VipText"
	text.Size = UDim2.fromOffset(70, 24)
	text.Position = UDim2.new(0, 35, 0.5, -12)
	text.BackgroundTransparency = 1
	text.Text = "VIP"
	text.TextColor3 = Color3.fromRGB(255, 220, 80)
	text.TextSize = 14
	text.Font = Enum.Font.GothamBold
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextStrokeTransparency = 0.35
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Parent = frame
end

local function showTag(player, rank)
	if rank == "management" then
		createManagementTag(player)
	elseif rank == "admin" then
		createTextTag(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))
	elseif rank == "moderator" then
		createTextTag(player, "MODERATOR", Color3.fromRGB(0, 200, 100))
	elseif rank == "vip" then
		createVipTag(player)
	end
end

local function toggle(player, rank)
	if active[player.UserId] == rank then
		active[player.UserId] = nil
		deleteTag(player)
	else
		active[player.UserId] = rank
		showTag(player, rank)
	end
end

managementCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)

	if not player then
		return
	end

	if player.UserId == MANAGEMENT_ID then
		toggle(player, "management")
	end
end)

staffCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)

	if not player then
		return
	end

	if player.UserId == ADMIN_ID then
		toggle(player, "admin")
	elseif player.UserId == MODERATOR_ID and MODERATOR_ID ~= 0 then
		toggle(player, "moderator")
	end
end)

vipCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)

	if not player then
		return
	end

	if player.UserId == VIP_ID then
		toggle(player, "vip")
	end
end)

local function setupPlayer(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)

		local rank = active[player.UserId]

		if rank then
			showTag(player, rank)
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	active[player.UserId] = nil
end)