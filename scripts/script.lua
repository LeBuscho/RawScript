local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local MANAGER_ID = 10629049912
local ADMIN_ID = 3332191418
local VIP_ID = 11166928484

local staffEnabled = {}
local vipEnabled = {}

local staffCommand = Instance.new("TextChatCommand")
staffCommand.Name = "StaffCommand"
staffCommand.PrimaryAlias = "!staff"
staffCommand.Parent = TextChatService

local vipCommand = Instance.new("TextChatCommand")
vipCommand.Name = "VIPCommand"
vipCommand.PrimaryAlias = "!vip"
vipCommand.Parent = TextChatService

local function removeRankTag(player)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local tag = head:FindFirstChild("RankTag")
	if tag then
		tag:Destroy()
	end
end

local function createRankTag(player, rank, color)
	local character = player.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	removeRankTag(player)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RankTag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = rank
	text.TextColor3 = color
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextStrokeTransparency = 0.3
	text.Parent = billboard
end

staffCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then return end

	if player.UserId == MANAGER_ID then
		staffEnabled[player.UserId] = not staffEnabled[player.UserId]

		if staffEnabled[player.UserId] then
			createRankTag(player, "MANAGER", Color3.fromRGB(170, 0, 255))
		else
			removeRankTag(player)
		end

	elseif player.UserId == ADMIN_ID then
		staffEnabled[player.UserId] = not staffEnabled[player.UserId]

		if staffEnabled[player.UserId] then
			createRankTag(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))
		else
			removeRankTag(player)
		end
	end
end)

vipCommand.Triggered:Connect(function(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then return end

	if player.UserId == VIP_ID then
		vipEnabled[player.UserId] = not vipEnabled[player.UserId]

		if vipEnabled[player.UserId] then
			createRankTag(player, "VIP", Color3.fromRGB(255, 220, 80))
		else
			removeRankTag(player)
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)

		if player.UserId == MANAGER_ID and staffEnabled[player.UserId] then
			createRankTag(player, "MANAGER", Color3.fromRGB(170, 0, 255))

		elseif player.UserId == ADMIN_ID and staffEnabled[player.UserId] then
			createRankTag(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))

		elseif player.UserId == VIP_ID and vipEnabled[player.UserId] then
			createRankTag(player, "VIP", Color3.fromRGB(255, 220, 80))
		end
	end)
end)