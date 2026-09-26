local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local MANAGER_ID = 10629049912
local ADMIN_ID = 3332191418
local MODERATOR_ID = 0
local VIP_ID = 11166928484

local active = {}

local staffCommand = Instance.new("TextChatCommand")
staffCommand.Name = "StaffToggleCommand"
staffCommand.PrimaryAlias = "!staff"
staffCommand.Parent = TextChatService

local managerCommand = Instance.new("TextChatCommand")
managerCommand.Name = "ManagerToggleCommand"
managerCommand.PrimaryAlias = "!manager"
managerCommand.Parent = TextChatService

local vipCommand = Instance.new("TextChatCommand")
vipCommand.Name = "VipToggleCommand"
vipCommand.PrimaryAlias = "!vip"
vipCommand.Parent = TextChatService

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
			if object.Name == "MyGameRankTag" or object.Name == "RankTag" then
				object:Destroy()
			end
		end
	end
end

local function createTag(player, text, color)
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
	tag.Name = "MyGameRankTag"
	tag.Adornee = head
	tag.Size = UDim2.fromOffset(250, 55)
	tag.StudsOffset = Vector3.new(0, 3, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 100
	tag.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0.2
	label.Parent = tag
end

local function toggle(player, rank, color)
	if active[player.UserId] then
		active[player.UserId] = nil
		deleteTag(player)
	else
		active[player.UserId] = true
		createTag(player, rank, color)
	end
end

staffCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then
		return
	end

	if player.UserId == ADMIN_ID then
		toggle(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))
	elseif player.UserId == MODERATOR_ID and MODERATOR_ID ~= 0 then
		toggle(player, "MODERATOR", Color3.fromRGB(0, 200, 100))
	end
end)

managerCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then
		return
	end

	if player.UserId == MANAGER_ID then
		toggle(player, "MANAGER", Color3.fromRGB(13, 105, 172))
	end
end)

vipCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then
		return
	end

	if player.UserId == VIP_ID then
		toggle(player, "VIP", Color3.fromRGB(255, 220, 80))
	end
end)

local function setupPlayer(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)

		if not active[player.UserId] then
			return
		end

		if player.UserId == MANAGER_ID then
			createTag(player, "MANAGER", Color3.fromRGB(13, 105, 172))
		elseif player.UserId == ADMIN_ID then
			createTag(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))
		elseif player.UserId == MODERATOR_ID and MODERATOR_ID ~= 0 then
			createTag(player, "MODERATOR", Color3.fromRGB(0, 200, 100))
		elseif player.UserId == VIP_ID then
			createTag(player, "VIP", Color3.fromRGB(255, 220, 80))
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