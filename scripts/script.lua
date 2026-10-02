local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

local MANAGEMENT_ID = 10629049912
local ADMIN_ID = 3332191418
local MODERATOR_ID = 0
local VIP_ID = 11166928484

local WRENCH_ICON = "rbxassetid://86041844180011"
local VERIFIED_ICON = "rbxassetid://116749530433643"
local VIP_ICON = "rbxassetid://112894741812069"

local TAG_NAME = "GameStaffTag"
local OLD_TAG_NAMES = {
	GameStaffTag = true,
	ManagementTag = true,
	MyGameRankTag = true,
	RankTag = true,
	VipTag = true,
	StaffTag = true,
	AdminTag = true,
	ManagerTag = true,
}
local RANK_TEXTS = {
	MANAGEMENT = true,
	MANAGER = true,
	ADMINISTRATOR = true,
	MODERATOR = true,
	VIP = true,
}

local active = {}
local watches = {}

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

local function isRankBillboard(object)
	if not object:IsA("BillboardGui") then
		return false
	end
	if OLD_TAG_NAMES[object.Name] then
		return true
	end
	for _, child in ipairs(object:GetDescendants()) do
		if child:IsA("TextLabel") then
			local value = string.upper((child.Text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
			if RANK_TEXTS[value] then
				return true
			end
		end
	end
	return false
end

local function deleteTag(player)
	local character = player.Character
	if not character then
		return
	end
	for _, object in ipairs(character:GetDescendants()) do
		if isRankBillboard(object) then
			object:Destroy()
		end
	end
end

local function stopWatch(player)
	local list = watches[player]
	if not list then
		return
	end
	for _, conn in ipairs(list) do
		conn:Disconnect()
	end
	watches[player] = nil
end

local function startWatch(player, character)
	stopWatch(player)
	local function purge(object)
		if not object:IsA("BillboardGui") then
			return
		end
		if object.Name == TAG_NAME and active[player.UserId] then
			return
		end
		if isRankBillboard(object) then
			task.defer(function()
				if object.Parent then
					object:Destroy()
				end
			end)
		end
	end
	watches[player] = {
		character.DescendantAdded:Connect(purge),
		character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				stopWatch(player)
			end
		end),
	}
	for _, object in ipairs(character:GetDescendants()) do
		purge(object)
	end
end

local function makeBillboard(head, width, height)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = TAG_NAME
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(width, height)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 100
	billboard.LightInfluence = 0
	billboard.ResetOnSpawn = false
	billboard.ClipsDescendants = false
	billboard.AutoLocalize = false
	return billboard
end

local function makeIcon(parent, image)
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.fromOffset(21, 21)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.Image = image
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = parent
	return icon
end

local function makeText(parent, textValue, color)
	local text = Instance.new("TextLabel")
	text.Name = "RankText"
	text.AutomaticSize = Enum.AutomaticSize.X
	text.Size = UDim2.fromOffset(0, 24)
	text.BackgroundTransparency = 1
	text.BorderSizePixel = 0
	text.Text = textValue
	text.TextColor3 = color
	text.TextSize = 14
	text.TextScaled = false
	text.TextWrapped = false
	text.Font = Enum.Font.GothamBold
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextStrokeTransparency = 0.35
	text.Parent = parent
	return text
end

local function createIconTag(player, leftIcon, rankText, color, rightIcon)
	local character = player.Character
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	deleteTag(player)

	local width = 210
	if rankText == "VIP" then
		width = 100
	end

	local billboard = makeBillboard(head, width, 36)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(width, 36)
	frame.BackgroundTransparency = 1
	frame.Parent = billboard

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 5)
	layout.Parent = frame

	if leftIcon and leftIcon ~= "" and leftIcon ~= "rbxassetid://0" then
		makeIcon(frame, leftIcon)
	end
	makeText(frame, rankText, color)
	if rightIcon and rightIcon ~= "" and rightIcon ~= "rbxassetid://0" then
		makeIcon(frame, rightIcon)
	end

	billboard.Parent = head
end

local function createTextTag(player, rankText, color)
	local character = player.Character
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	deleteTag(player)

	local billboard = makeBillboard(head, 160, 28)
	local label = makeText(billboard, rankText, color)
	label.Size = UDim2.fromOffset(160, 28)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextScaled = false
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	billboard.Parent = head
end

local function showTag(player, rank)
	if rank == "management" then
		createIconTag(player, WRENCH_ICON, "MANAGEMENT", Color3.fromRGB(255, 255, 255), VERIFIED_ICON)
	elseif rank == "admin" then
		createTextTag(player, "ADMINISTRATOR", Color3.fromRGB(255, 70, 70))
	elseif rank == "moderator" then
		createTextTag(player, "MODERATOR", Color3.fromRGB(0, 200, 100))
	elseif rank == "vip" then
		createIconTag(player, VIP_ICON, "VIP", Color3.fromRGB(255, 220, 80), nil)
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
	player.CharacterAdded:Connect(function(character)
		task.wait(0.4)
		startWatch(player, character)
		deleteTag(player)
		if active[player.UserId] then
			showTag(player, active[player.UserId])
		end
	end)
	if player.Character then
		startWatch(player, player.Character)
	end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	active[player.UserId] = nil
	stopWatch(player)
end)