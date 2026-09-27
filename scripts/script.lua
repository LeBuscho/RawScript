local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MANAGER_ID = 10629049912
local ADMIN_ID = 3332191418

local remote = ReplicatedStorage:FindFirstChild("CoolStudioFlyRemote")

if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "CoolStudioFlyRemote"
	remote.Parent = ReplicatedStorage
end

local command = TextChatService:FindFirstChild("FlyCommand")

if not command then
	command = Instance.new("TextChatCommand")
	command.Name = "FlyCommand"
	command.PrimaryAlias = "/fly"
	command.Parent = TextChatService
end

local function findPlayer(name)
	if not name then
		return nil
	end

	name = string.lower(name)

	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name) == name then
			return player
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #name) == name then
			return player
		end
	end

	return nil
end

command.Triggered:Connect(function(textSource, message)
	local sender = Players:GetPlayerByUserId(textSource.UserId)

	if not sender then
		return
	end

	if sender.UserId ~= MANAGER_ID and sender.UserId ~= ADMIN_ID then
		return
	end

	local args = string.split(message, " ")
	local targetName = args[2]

	if not targetName or targetName == "" then
		return
	end

	local target = findPlayer(targetName)

	if not target then
		return
	end

	remote:FireClient(target)
end)