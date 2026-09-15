Kaserne Admin Panel – so einbauen

1. Roblox Studio auf, Place oeffnen.
2. Explorer links.
3. ServerScriptService -> Rechtsklick -> Insert Object -> Script
4. Script umbenennen zu: AdminServer
5. Alles im Script loeschen und CODE 1 komplett rein.
6. StarterPlayer aufklappen -> StarterPlayerScripts
7. Rechtsklick -> LocalScript
8. LocalScript umbenennen zu: AdminPanel
9. Alles loeschen und CODE 2 komplett rein.
10. In BEIDEN Codes bei ADMINS die echten Roblox-Usernames eintragen (nicht DisplayName).
11. Optional: Tools Salutieren, Ruehren, Stillgestanden nach ServerStorage kopieren.
12. Play druecken. F2 oeffnet das Panel. Chat z.B. :help

Commands:
:kick Name Grund
:team Name Teamname
:rang Name Rang
:durchsage Text
:bring Name
:to Name
:spawn
:zelle Name
:frei Name
:karriere
:barriere auf
:barriere zu
:salut
:ruhren
:still
:speed Name 16
:hp Name 100
:respawn Name
:freeze Name
:thaw Name
:mannschaft

========== CODE 1 AdminServer (muss Script sein) ==========

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage")

local ADMINS = {
	["LeBuschOG"] = true,
	["mynameistim9999"] = true,
	["mynametim9"] = true,
}

local folder = ReplicatedStorage:FindFirstChild("KaserneAdmin") or Instance.new("Folder")
folder.Name = "KaserneAdmin"
folder.Parent = ReplicatedStorage

local cmdRemote = folder:FindFirstChild("Command") or Instance.new("RemoteEvent")
cmdRemote.Name = "Command"
cmdRemote.Parent = folder

local noteRemote = folder:FindFirstChild("Notify") or Instance.new("RemoteEvent")
noteRemote.Name = "Notify"
noteRemote.Parent = folder

local function admin(plr)
	return plr and ADMINS[plr.Name] == true
end

local function note(plr, title, text)
	noteRemote:FireClient(plr, title, text)
end

local function shout(title, text)
	for _, p in ipairs(Players:GetPlayers()) do
		note(p, title, text)
	end
end

local function findP(q)
	q = string.lower(q or "")
	if q == "" then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name) == q or string.lower(p.DisplayName) == q then
			return p
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(p.Name), q, 1, true) or string.find(string.lower(p.DisplayName), q, 1, true) then
			return p
		end
	end
end

local function root(plr)
	return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
end

local function biggest(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj end
	local best, vol = nil, 0
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("BasePart") then
			local v = d.Size.X * d.Size.Y * d.Size.Z
			if v > vol then best, vol = d, v end
		end
	end
	return best
end

local function tpToName(plr, names)
	local r = root(plr)
	if not r then return end
	for _, n in ipairs(names) do
		local obj = workspace:FindFirstChild(n, true)
		local p = biggest(obj)
		if p then
			r.CFrame = p.CFrame + Vector3.new(0, 5, 0)
			return true
		end
	end
end

local function giveTool(plr, toolName)
	local src = ServerStorage:FindFirstChild(toolName)
	if not src then return false end
	local bag = plr:FindFirstChild("Backpack")
	if bag then
		src:Clone().Parent = bag
		return true
	end
end

local function setBarriers(open)
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and string.find(string.lower(d.Name), "barriere") then
			d.CanCollide = not open
			d.Transparency = open and 0.7 or 0
		end
	end
end

local cmds = {}

cmds.help = function(a)
	note(a, "Commands", "kick team rang durchsage bring to spawn zelle frei karriere barriere salut ruhren still speed hp respawn freeze thaw mannschaft")
end

cmds.kick = function(a, x)
	local t = findP(x[1])
	if not t then return note(a, "Fehler", "Spieler?") end
	t:Kick(table.concat(x, " ", 2))
	shout("Feldjaeger", a.Name .. " hat " .. t.DisplayName .. " entfernt")
end

cmds.team = function(a, x)
	local t = findP(x[1])
	local name = table.concat(x, " ", 2)
	local team = Teams:FindFirstChild(name)
	if not t or not team then return note(a, "Fehler", "Spieler oder Team?") end
	t.Team = team
	t:SetAttribute("TeamName", team.Name)
	note(a, "Versetzung", t.DisplayName .. " -> " .. team.Name)
end

cmds.rang = function(a, x)
	local t = findP(x[1])
	if not t then return note(a, "Fehler", "Spieler?") end
	local rang = table.concat(x, " ", 2)
	t:SetAttribute("Rang", rang)
	shout("Befoerderung", t.DisplayName .. " ist jetzt " .. rang)
end

cmds.durchsage = function(a, x)
	shout("Durchsage", table.concat(x, " "))
end
cmds.say = cmds.durchsage

cmds.bring = function(a, x)
	local t = findP(x[1])
	local ar, tr = root(a), t and root(t)
	if ar and tr then tr.CFrame = ar.CFrame * CFrame.new(0, 0, -4) end
end

cmds.to = function(a, x)
	local t = findP(x[1])
	local ar, tr = root(a), t and root(t)
	if ar and tr then ar.CFrame = tr.CFrame * CFrame.new(0, 0, 4) end
end

cmds.spawn = function(a, x)
	tpToName(findP(x[1]) or a, {"SpawnLocation"})
end

cmds.zelle = function(a, x)
	local t = findP(x[1]) or a
	if tpToName(t, {"JailCell", "JailCell1"}) then
		shout("Arrest", t.DisplayName .. " in die Zelle")
	end
end

cmds.frei = function(a, x)
	local t = findP(x[1]) or a
	tpToName(t, {"SpawnLocation"})
	note(a, "Frei", t.DisplayName .. " entlassen")
end

cmds.karriere = function(a, x)
	tpToName(findP(x[1]) or a, {"tuer karrire center", "tur karrire center", "tür karrire center"})
end

cmds.barriere = function(a, x)
	local open = string.lower(x[1] or "") ~= "zu"
	setBarriers(open)
	shout("Absperrung", open and "Barrieren offen" or "Barrieren zu")
end

cmds.salut = function(a, x)
	local t = findP(x[1]) or a
	if giveTool(t, "Salutieren") then note(a, "Tool", "Salutieren an " .. t.DisplayName) end
end

cmds.ruhren = function(a, x)
	local t = findP(x[1]) or a
	if giveTool(t, "Ruehren") or giveTool(t, "Rühren") then
		note(a, "Tool", "Ruhren an " .. t.DisplayName)
	end
end

cmds.still = function(a, x)
	local t = findP(x[1]) or a
	if giveTool(t, "Stillgestanden") then note(a, "Tool", "Stillgestanden an " .. t.DisplayName) end
end

cmds.speed = function(a, x)
	local t = findP(x[1]) or a
	local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = tonumber(x[#x]) or 16 end
end

cmds.hp = function(a, x)
	local t = findP(x[1]) or a
	local hum = t.Character and t.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = tonumber(x[#x]) or 100 end
end

cmds.respawn = function(a, x)
	local t = findP(x[1]) or a
	t:LoadCharacter()
end

cmds.freeze = function(a, x)
	local t = findP(x[1])
	local r = t and root(t)
	if r then r.Anchored = true end
end

cmds.thaw = function(a, x)
	local t = findP(x[1])
	local r = t and root(t)
	if r then r.Anchored = false end
end

cmds.mannschaft = function(a)
	local lines = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(lines, p.DisplayName .. " | " .. tostring(p:GetAttribute("Rang") or "-") .. " | " .. (p.Team and p.Team.Name or "-"))
	end
	note(a, "Mannschaft", table.concat(lines, "\n"))
end

local function run(plr, raw)
	if not admin(plr) then return end
	raw = string.gsub(raw or "", "^:+", "")
	local bits = {}
	for w in string.gmatch(raw, "%S+") do
		table.insert(bits, w)
	end
	if #bits == 0 then return end
	local name = string.lower(table.remove(bits, 1))
	local fn = cmds[name]
	if fn then fn(plr, bits) else note(plr, "Unbekannt", name) end
end

cmdRemote.OnServerEvent:Connect(function(plr, raw)
	run(plr, raw)
end)

Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		if string.sub(msg, 1, 1) == ":" then run(plr, msg) end
	end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	plr.Chatted:Connect(function(msg)
		if string.sub(msg, 1, 1) == ":" then run(plr, msg) end
	end)
end

========== CODE 2 AdminPanel (muss LocalScript sein) ==========

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local ADMINS = {
	["LeBuschOG"] = true,
	["mynameistim9999"] = true,
	["mynametim9"] = true,
}
if not ADMINS[player.Name] then return end

local folder = ReplicatedStorage:WaitForChild("KaserneAdmin")
local cmdRemote = folder:WaitForChild("Command")
local noteRemote = folder:WaitForChild("Notify")

local gui = Instance.new("ScreenGui")
gui.Name = "KaserneAdminPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 520)
frame.Position = UDim2.new(0, 24, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(18, 8, 32)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(170, 90, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(210, 170, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Kaserne Admin"
title.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -20, 0, 34)
box.Position = UDim2.new(0, 10, 0, 50)
box.BackgroundColor3 = Color3.fromRGB(32, 16, 52)
box.TextColor3 = Color3.new(1, 1, 1)
box.PlaceholderText = ":durchsage Appell in 5 Minuten"
box.PlaceholderColor3 = Color3.fromRGB(140, 120, 160)
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Text = ""
box.ClearTextOnFocus = false
box.Parent = frame
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

local log = Instance.new("TextLabel")
log.Size = UDim2.new(1, -20, 0, 70)
log.Position = UDim2.new(0, 10, 0, 90)
log.BackgroundTransparency = 1
log.Font = Enum.Font.Gotham
log.TextSize = 13
log.TextColor3 = Color3.fromRGB(220, 210, 240)
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextWrapped = true
log.Text = "F2 = Panel  |  Chat mit :command"
log.Parent = frame

local function send(cmd)
	cmdRemote:FireServer(cmd)
end

box.FocusLost:Connect(function(enter)
	if enter and box.Text ~= "" then
		send(box.Text)
		box.Text = ""
	end
end)

local buttons = {
	{":help", "Hilfe"},
	{":mannschaft", "Mannschaft"},
	{":durchsage Appell!", "Durchsage"},
	{":barriere auf", "Barriere auf"},
	{":barriere zu", "Barriere zu"},
	{":spawn", "Zum Spawn"},
	{":karriere", "Karriere-Center"},
	{":zelle ", "Zelle (Name)"},
	{":frei ", "Entlassen"},
	{":salut", "Salut-Tool"},
	{":ruhren", "Ruhren-Tool"},
	{":still", "Still-Tool"},
}

local grid = Instance.new("Frame")
grid.Size = UDim2.new(1, -20, 0, 300)
grid.Position = UDim2.new(0, 10, 0, 165)
grid.BackgroundTransparency = 1
grid.Parent = frame
local lay = Instance.new("UIGridLayout", grid)
lay.CellSize = UDim2.new(0.5, -6, 0, 36)
lay.CellPadding = UDim2.new(0, 8, 0, 8)

for _, item in ipairs(buttons) do
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Color3.fromRGB(48, 22, 78)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = item[2]
	b.Parent = grid
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function()
		if string.sub(item[1], -1) == " " then
			box.Text = item[1]
			box:CaptureFocus()
		else
			send(item[1])
		end
	end)
end

noteRemote.OnClientEvent:Connect(function(titleText, body)
	log.Text = tostring(titleText) .. "\n" .. tostring(body)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		frame.Visible = not frame.Visible
	end
end)