if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok or not Rayfield then return end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local CFG_FILE, KEY_FILE, STAFF_FILE = "BRPHelper_full.json", "BRPHelper_keys.json", "BRPHelper_staff.json"
local STAFF_USERS, STAFF_WORDS = {}, {"staff","admin","leitung","moderator","mod","owner","inhaber","projektleitung","serverleitung","teamleitung","verwaltung","developer","dev","management","sl","pl","tl"}
local S = {
    godmode=false, antiDown=false, hideDownUI=false, antiSit=false, antiVoid=false, antiAfk=true,
    antiTaser=false, antiCuff=false,
    speedOn=false, currentSpeed=16, jumpOn=false, currentJump=50, noclipOn=false, infJump=false,
    noDownSlow=true, sprintOn=false, autoGetUp=false, clickCarTP=false, clickFootTP=false,
    pushCars=false, pushPower=1000, tweenTime=1.2, freecamSpeed=60, gtaSpeed=60,
    keyPush="C", keyGta="N", keyBoost="G", keyJumpCar="H",
    fullbright=false, espOn=false, heliESP=false, showHud=true, currentFOV=70, noFog=false,
    tZoom=false, tThird=false, noFx=false, shadowsOff=false, autoRejoin=false, hlSelected=false,
    cruiseOn=false, hoverOn=false, carEsp=false, boostPower=120, gripOn=false, nitroOn=false,
    autoFlip=false, nightOn=false, lowOn=false, rainbow=false, cruiseSpeed=40,
    carFly=false, carInvis=false, lights=false, landHelp=false, slowFall=false,
    lowGrav=false, speedCap=false, capKmh=80, gps=false, freezeMe=false
}

local ICO = {ok=6023426926, info=6031071053, car=6031265976, eye=6031075938, warn=6031071057, user=6034287594, map=6031763426, key=6031280882, shield=6031280883, star=6031265978}
local alive = true

local function loadJSON(path)
    if isfile and isfile(path) then
        local ok2, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok2 and type(data)=="table" then return data end
    end
end
local function saveJSON(path, data)
    if writefile then pcall(function() writefile(path, HttpService:JSONEncode(data)) end) end
end
local function loadStaffFile()
    local data=loadJSON(STAFF_FILE)
    if data then for _,n in ipairs(data) do if type(n)=="string" then STAFF_USERS[string.lower(n)]=true end end end
end
local function saveStaffFile()
    local t={} for n,v in pairs(STAFF_USERS) do if v then table.insert(t,n) end end saveJSON(STAFF_FILE,t)
end
local function saveKeys()
    saveJSON(KEY_FILE, {keyPush=S.keyPush,keyGta=S.keyGta,keyBoost=S.keyBoost,keyJumpCar=S.keyJumpCar})
end
local function loadKeys()
    local d=loadJSON(KEY_FILE)
    if d then
        if d.keyPush then S.keyPush=d.keyPush end
        if d.keyGta then S.keyGta=d.keyGta end
        if d.keyBoost then S.keyBoost=d.keyBoost end
        if d.keyJumpCar then S.keyJumpCar=d.keyJumpCar end
    end
end
local function saveCfg()
    if not alive then return end
    saveJSON(CFG_FILE,S) saveKeys()
end
local function loadCfg()
    local data=loadJSON(CFG_FILE)
    if data then for k,v in pairs(data) do S[k]=v end end
    loadKeys()
end
loadStaffFile() loadCfg()

local Window = Rayfield:CreateWindow({
    Name="BRP Helper v2", LoadingTitle="BRP Helper v2", LoadingSubtitle="CoolStudios",
    Theme="Amethyst", ConfigurationSaving={Enabled=true, FolderName="BRPHelper", FileName="Config"}, KeySystem=false
})

local function notify(title, text, icon)
    if not alive then return end
    pcall(function()
        Rayfield:Notify({Title=tostring(title), Content=tostring(text), Duration=3, Image=icon or ICO.info})
    end)
end

local InfoTab=Window:CreateTab("Info", ICO.info)
local SchutzTab=Window:CreateTab("Schutz", ICO.shield)
local MoveTab=Window:CreateTab("Bewegung", ICO.user)
local AutoTab=Window:CreateTab("Auto & Helis", ICO.car)
local GtaTab=Window:CreateTab("GTA", ICO.star)
local OrteTab=Window:CreateTab("Orte", ICO.map)
local SpielerTab=Window:CreateTab("Spieler", ICO.user)
local VisualTab=Window:CreateTab("Visual", ICO.eye)
local GuiTab=Window:CreateTab("GUIs", ICO.ok)
local BindTab=Window:CreateTab("Tasten", ICO.key)
local ExtraTab=Window:CreateTab("Extra", ICO.warn)

local selectedPlayer="Niemand"
local currentTween,noclipConn,freecamConn,afkConn,gtaConn,speedHook,inputConn,jumpConn,charConn,hb1,hb2
local freecamOn,spectating,gtaOn=false,false,false
local gtaYaw,gtaPitch=0,0
local savedVehicle,wheelFreeze,carWp=nil,{},nil
local wp={nil,nil,nil}
local rejoinPending,fps,acc=false,0,0
local rainbowHue=0
local oldGravity=workspace.Gravity
local nextProtect=0

local STUN_ATTRS = {"Tased","Taser","Stunned","Stun","Electrocuted","Shocked","Ragdoll","Tripped","Cuffed","Handcuffed","Arrested","Detained","Restrained","Surrender","Dragging"}
local STUN_WORDS = {"taser","tased","stun","cuff","handcuff","arrest","fessel","elektro"}
local CHAIR_WORDS = {"stuhl","chair","sessel","sofa","bank","bench","sitz","hocker","office"}

local function getChar() return LocalPlayer.Character end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getACS() local c=getChar() return c and c:FindFirstChild("ACS_Client") end
local function camLocked() return alive and (gtaOn or freecamOn) end
local function copyText(t) t=tostring(t or "") if setclipboard then setclipboard(t) notify("Kopiert", t, ICO.ok) elseif toclipboard then toclipboard(t) notify("Kopiert", t, ICO.ok) end end
local function hasWord(text, list)
    text=string.lower(tostring(text or ""))
    for _,w in ipairs(list) do if text~="" and string.find(text,w,1,true) then return true end end
    return false
end
local function isStaff(plr)
    if not plr then return false end
    if STAFF_USERS[string.lower(plr.Name)] then return true end
    if hasWord(plr:GetAttribute("OverheadRoleText"), STAFF_WORDS) or hasWord(plr:GetAttribute("CurrentTeamName"), STAFF_WORDS) then return true end
    if plr.Team and hasWord(plr.Team.Name, STAFF_WORDS) then return true end
    return false
end
local function markStaff(name,on)
    if not name or name=="Niemand" then notify("Staff", "Kein Spieler", ICO.warn) return end
    STAFF_USERS[string.lower(name)]=on and true or nil saveStaffFile()
    notify("Staff", name.." = "..(on and "JA" or "nein"), ICO.user)
end
local function playerCard(plr)
    if not plr then return "Kein Spieler" end
    return table.concat({
        "Name: "..tostring(plr.DisplayName),
        "User: @"..tostring(plr.Name),
        "Team: "..tostring(plr:GetAttribute("CurrentTeamName") or (plr.Team and plr.Team.Name) or "-"),
        "Zustand: "..tostring(plr:GetAttribute("Med_Zustand") or "-"),
        "Notruf: "..tostring(plr:GetAttribute("BRP_Notrufkennung") or "-"),
        "Personalnummer: "..tostring(plr:GetAttribute("PersonalNumber") or "-"),
        "Staff: "..(isStaff(plr) and "JA" or "nein")
    },"\n")
end
local function hideBewusstlos(hide)
    for _,n in ipairs({"BewusstlosUI","dead","Damage"}) do local g=PlayerGui:FindFirstChild(n) if g then g.Enabled=not hide end end
end
local function toggleGui(name)
    local g=PlayerGui:FindFirstChild(name)
    if g then g.Enabled=not g.Enabled notify("GUI", name.." = "..tostring(g.Enabled), ICO.ok) else notify("GUI", name.." nicht da", ICO.warn) end
end
local function applyFullbright() Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=100000 Lighting.GlobalShadows=false end
local function freezeBody(on)
    local hum, root = getHum(), getRoot()
    if hum then
        hum.AutoRotate = not on
        hum.PlatformStand = on
        pcall(function() hum:Move(Vector3.zero, false) end)
        if on then hum.WalkSpeed=0 hum.JumpPower=0 elseif S.jumpOn then hum.JumpPower=S.currentJump end
    end
    if root then
        root.AssemblyLinearVelocity=Vector3.zero
        root.AssemblyAngularVelocity=Vector3.zero
        root.Anchored = on
    end
end
local function holdBodyStill()
    if not camLocked() then return end
    local hum, root = getHum(), getRoot()
    if hum then
        if hum.WalkSpeed ~= 0 then hum.WalkSpeed=0 end
        hum.PlatformStand=true
        hum.AutoRotate=false
        pcall(function() hum:Move(Vector3.zero, false) end)
    end
    if root then
        if not root.Anchored then root.Anchored=true end
        root.AssemblyLinearVelocity=Vector3.zero
    end
end
local function applySpeed(hum)
    if not alive or not hum or camLocked() then return end
    if not (S.speedOn or S.noDownSlow or S.sprintOn) then return end
    local want=S.speedOn and S.currentSpeed or 16
    if S.sprintOn and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then want=math.max(want,S.currentSpeed+10) end
    if math.abs(hum.WalkSpeed-want)>0.5 then hum.WalkSpeed=want end
    if S.jumpOn and math.abs(hum.JumpPower-S.currentJump)>0.5 then hum.UseJumpPower=true hum.JumpPower=S.currentJump end
end
local function hookSpeed(hum)
    if speedHook then speedHook:Disconnect() speedHook=nil end
    if not hum then return end
    speedHook=hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not alive then return end
        if camLocked() then if hum.WalkSpeed~=0 then hum.WalkSpeed=0 end return end
        if S.speedOn or S.noDownSlow or S.sprintOn then applySpeed(hum) end
    end)
end
local function setNoclip(on)
    S.noclipOn=on
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    if on and alive then
        noclipConn=RunService.Stepped:Connect(function()
            if not alive then return end
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    end
    if alive then notify("Noclip", on and "AN" or "AUS", ICO.eye) saveCfg() end
end
local function clearAttrs(inst)
    if not inst then return end
    for _,a in ipairs(STUN_ATTRS) do
        pcall(function() if inst:GetAttribute(a)~=nil then inst:SetAttribute(a,false) end end)
    end
end
local function antiTaserNow()
    if not alive or camLocked() then return end
    local char,hum=getChar(),getHum()
    if not char or not hum then return end
    clearAttrs(char) clearAttrs(LocalPlayer)
    local acs=getACS()
    if acs then clearAttrs(acs) pcall(function() acs:SetAttribute("Injured",false) acs:SetAttribute("Surrender",false) end) end
    if hum.PlatformStand and not hum.SeatPart then hum.PlatformStand=false end
end
local function antiCuffNow()
    if not alive or camLocked() then return end
    local char,hum=getChar(),getHum()
    if not char or not hum then return end
    clearAttrs(char) clearAttrs(LocalPlayer)
    local acs=getACS() if acs then clearAttrs(acs) pcall(function() acs:SetAttribute("Surrender",false) acs:SetAttribute("Dragging",false) end) end
    if not hum.SeatPart and hum.Sit then hum.Sit=false end
    for _,v in ipairs(char:GetDescendants()) do
        local n=string.lower(v.Name)
        if (v:IsA("Weld") or v:IsA("WeldConstraint")) and hasWord(n, STUN_WORDS) then pcall(function() v:Destroy() end) end
    end
end
local function clearDown()
    if not alive or camLocked() then return end
    local char,hum=getChar(),getHum() if not char or not hum then return end
    hum.Health=100
    if not hum.SeatPart then if hum.PlatformStand then hum.PlatformStand=false end if S.antiSit and hum.Sit then hum.Sit=false end end
    local down=char:FindFirstChild("IsDown") if down and down:IsA("BoolValue") and down.Value then down.Value=false end
    local acs=getACS()
    if acs then pcall(function() acs:SetAttribute("Injured",false) acs:SetAttribute("Bleeding",false) acs:SetAttribute("Collapsed",false) end) end
    if S.hideDownUI then hideBewusstlos(true) end
end
local function getVehicle()
    local hum=getHum() if not hum or not hum.SeatPart then return nil end
    return hum.SeatPart:FindFirstAncestorOfClass("Model")
end
local function isWheel(p)
    local n=string.lower(p.Name)
    return string.find(n,"wheel") or string.find(n,"reifen") or string.find(n,"tire") or string.find(n,"rim") or string.find(n,"tyre")
end
local function getMovePart(v)
    if not v then return nil end
    if v.PrimaryPart and not isWheel(v.PrimaryPart) then return v.PrimaryPart end
    local best,vol=nil,0
    for _,p in ipairs(v:GetDescendants()) do
        if p:IsA("BasePart") and not isWheel(p) then local s=p.Size.X*p.Size.Y*p.Size.Z if s>vol then best,vol=p,s end end
    end
    return best or v:FindFirstChildWhichIsA("BasePart")
end
local function getSeat(v) return v and v:FindFirstChildWhichIsA("VehicleSeat", true) end
local function driveDir(v)
    local seat=getSeat(v)
    if seat then return seat.CFrame.LookVector end
    local m=getMovePart(v)
    return m and -m.CFrame.LookVector or Vector3.new(0,0,-1)
end
local function isRealVehicle(m)
    if not m or Players:GetPlayerFromCharacter(m) then return false end
    if hasWord(m.Name, CHAIR_WORDS) then return false end
    local seat=getSeat(m)
    if not seat then return false end
    if hasWord(seat.Name, CHAIR_WORDS) then return false end
    local wheels, parts = 0, 0
    for _,p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") then
            parts += 1
            if isWheel(p) then wheels += 1 end
        end
    end
    return wheels>=2 or parts>=10
end
local function isHelicopter(m)
    if not m then return false end
    local n=string.lower(m.Name)
    return string.find(n,"heli") or string.find(n,"christoph") or string.find(n,"hubsch")
end
local function zeroVehicle(veh)
    if not veh then return end
    for _,p in ipairs(veh:GetDescendants()) do
        if p:IsA("BasePart") then p.AssemblyLinearVelocity=Vector3.zero p.AssemblyAngularVelocity=Vector3.zero end
    end
end
local function setVehSeeThrough(veh,on)
    if not veh then return end
    for _,p in ipairs(veh:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier=on and 1 or 0 pcall(function() p.CanQuery=not on end)
        elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency=on and 1 or 0 end
    end
end
local function freezeVehicle(veh,on)
    if not veh then return end
    if on then
        wheelFreeze={}
        for _,p in ipairs(veh:GetDescendants()) do
            if p:IsA("BasePart") then
                wheelFreeze[p]=p.Anchored p.AssemblyLinearVelocity=Vector3.zero p.AssemblyAngularVelocity=Vector3.zero p.Anchored=true
            end
        end
        setVehSeeThrough(veh,true)
    else
        setVehSeeThrough(veh,false)
        for p,was in pairs(wheelFreeze) do
            if p.Parent then p.Anchored=was p.AssemblyLinearVelocity=Vector3.zero p.AssemblyAngularVelocity=Vector3.zero end
        end
        wheelFreeze={} zeroVehicle(veh)
    end
end
local function placeVehicle(veh,cf)
    if not veh then return end
    local move=getMovePart(veh) if not move then return end
    zeroVehicle(veh) local old=move.Anchored move.Anchored=true move.CFrame=cf zeroVehicle(veh)
    task.delay(0.2,function() if move.Parent then move.Anchored=old zeroVehicle(veh) end end)
end
local function nearestVehicle(maxD)
    local root=getRoot() if not root then return nil end
    local best,bestD,seen=nil,nil,{}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local m=obj:FindFirstAncestorOfClass("Model")
            if m and not seen[m] and isRealVehicle(m) then
                seen[m]=true local p=getMovePart(m)
                if p then local d=(p.Position-root.Position).Magnitude if d<=(maxD or 25) and (not bestD or d<bestD) then best,bestD=m,d end end
            end
        end
    end
    return best
end
local function enterNearest()
    local m,hum=nearestVehicle(20),getHum()
    if not (m and hum) then notify("Auto", "Kein Auto nah", ICO.warn) return end
    local seat=getSeat(m)
    if seat then pcall(function() seat:Sit(hum) end) notify("Auto", "Eingestiegen", ICO.car) end
end
local function setLocalInvis(on)
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier=on and 1 or 0
        elseif p:IsA("Decal") then p.Transparency=on and 1 or 0 end
    end
end
local function anglesFromCam()
    local look=Camera.CFrame.LookVector
    gtaYaw=math.deg(math.atan2(-look.X,-look.Z))
    gtaPitch=math.deg(math.asin(math.clamp(look.Y,-1,1)))
end
local function stopGta()
    if not gtaOn then return end
    gtaOn=false if gtaConn then gtaConn:Disconnect() gtaConn=nil end
    pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
    local goal=Camera.CFrame
    freezeBody(false)
    Camera.CameraType=Enum.CameraType.Custom
    local hum,root=getHum(),getRoot()
    if hum then Camera.CameraSubject=hum hum.PlatformStand=false end
    setLocalInvis(false)
    local veh=savedVehicle
    if veh and veh.Parent then
        freezeVehicle(veh,false) placeVehicle(veh,goal+Vector3.new(0,6,0))
        if root then task.delay(0.05,function() if root.Parent then root.Anchored=false root.CFrame=goal+Vector3.new(0,7,0) end end) end
    elseif root then root.Anchored=false root.CFrame=goal+Vector3.new(0,3,0) root.AssemblyLinearVelocity=Vector3.zero end
    savedVehicle=nil
    if alive then notify("GTA Noclip", "AUS", ICO.eye) end
end
local function startGta()
    if not alive or freecamOn then return end
    savedVehicle=getVehicle() if savedVehicle then freezeVehicle(savedVehicle,true) end
    gtaOn=true anglesFromCam() freezeBody(true)
    pcall(function() LocalPlayer.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Invisicam end)
    Camera.CameraType=Enum.CameraType.Scriptable
    local root=getRoot() if root then Camera.CFrame=root.CFrame+Vector3.new(0,8,0) end
    setLocalInvis(true)
    pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter end)
    notify("GTA Noclip", "AN  "..S.keyGta, ICO.eye)
    if gtaConn then gtaConn:Disconnect() end
    gtaConn=RunService.RenderStepped:Connect(function(dt)
        if not alive or not gtaOn then return end
        holdBodyStill()
        local d=UserInputService:GetMouseDelta()
        gtaYaw-=d.X*0.15 gtaPitch=math.clamp(gtaPitch-d.Y*0.15,-80,80)
        local pos=Camera.CFrame.Position
        local rot=CFrame.Angles(0,math.rad(gtaYaw),0)*CFrame.Angles(math.rad(gtaPitch),0,0)
        local move=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move+=rot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move-=rot.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move-=rot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move+=rot.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move-=Vector3.yAxis end
        local speed=UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and S.gtaSpeed*2.5 or S.gtaSpeed
        if move.Magnitude>0 then pos+=move.Unit*speed*dt end
        Camera.CFrame=CFrame.new(pos)*rot setLocalInvis(true)
        if savedVehicle and savedVehicle.Parent then setVehSeeThrough(savedVehicle,true) zeroVehicle(savedVehicle) end
    end)
end
local function isCharModel(m) return m and m:FindFirstChildOfClass("Humanoid")~=nil end
local function biggestPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then return obj end
    local best,vol=nil,0
    for _,d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") and not isCharModel(d.Parent) then local v=d.Size.X*d.Size.Y*d.Size.Z if v>vol then vol,best=v,d end end
    end
    return best
end
local function findNamed(names)
    for _,n in ipairs(names) do
        local top=workspace:FindFirstChild(n) or workspace:FindFirstChild(n,true)
        if top and not isCharModel(top) then local p=biggestPart(top) or (top:IsA("BasePart") and top) if p then return p end end
    end
end
local function tweenVehicle(goal)
    local part=getMovePart(getVehicle()) if not part then notify("Auto", "Kein Auto", ICO.warn) return end
    if currentTween then currentTween:Cancel() end
    currentTween=TweenService:Create(part,TweenInfo.new(S.tweenTime,Enum.EasingStyle.Quad),{CFrame=goal}) currentTween:Play()
end
local function killFx()
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("BlurEffect") or o:IsA("BloomEffect") or o:IsA("DepthOfFieldEffect") or o:IsA("SunRaysEffect") then o.Enabled=false end
    end
end
local function boostCar()
    local veh=getVehicle()
    local move=getMovePart(veh)
    if not move then notify("Auto", "Kein Auto", ICO.warn) return end
    local dir=driveDir(veh)
    if dir.Magnitude<0.05 then dir=Camera.CFrame.LookVector end
    dir=Vector3.new(dir.X,0,dir.Z)
    if dir.Magnitude<0.05 then dir=Vector3.new(0,0,-1) else dir=dir.Unit end
    move.AssemblyLinearVelocity = dir * S.boostPower + Vector3.new(0, math.max(move.AssemblyLinearVelocity.Y, 0), 0)
    move.AssemblyAngularVelocity = Vector3.zero
    notify("Auto", "Boost vorwaerts", ICO.car)
end
local function stopCar() zeroVehicle(getVehicle()) notify("Auto", "Stop", ICO.car) end
local function flipCar()
    local v,m=getVehicle(),getMovePart(getVehicle()) if not m then notify("Auto", "Kein Auto", ICO.warn) return end
    local p=m.Position+Vector3.new(0,4,0)
    local look=Vector3.new(driveDir(v).X,0,driveDir(v).Z) if look.Magnitude<0.1 then look=Vector3.new(0,0,-1) end
    placeVehicle(v,CFrame.new(p,p+look.Unit)) notify("Auto", "Aufrecht", ICO.car)
end
local function jumpCar() local m=getMovePart(getVehicle()) if m then m.AssemblyLinearVelocity=m.AssemblyLinearVelocity+Vector3.new(0,80,0) end end
local function shiftCar(off) local v,m=getVehicle(),getMovePart(getVehicle()) if m then placeVehicle(v,m.CFrame*CFrame.new(off)) end end
local function turnYaw(deg)
    local v,m=getVehicle(),getMovePart(getVehicle())
    if m then placeVehicle(v,m.CFrame*CFrame.Angles(0,math.rad(deg),0)+Vector3.new(0,2,0)) end
end
local function paintCar(color)
    local v=getVehicle() if not v then return end
    for _,p in ipairs(v:GetDescendants()) do if p:IsA("BasePart") and not isWheel(p) then p.Color=color end end
end
local function snapGround()
    local v,m=getVehicle(),getMovePart(getVehicle()) if not m then return end
    local ray=workspace:Raycast(m.Position+Vector3.new(0,8,0), Vector3.new(0,-80,0))
    local y=ray and ray.Position.Y+4 or m.Position.Y
    local look=Vector3.new(driveDir(v).X,0,driveDir(v).Z) if look.Magnitude<0.1 then look=Vector3.new(0,0,-1) end
    placeVehicle(v,CFrame.new(Vector3.new(m.Position.X,y,m.Position.Z), Vector3.new(m.Position.X,y,m.Position.Z)+look.Unit))
end
local function unstuck()
    local root=getRoot() if not root then return end
    root.CFrame=root.CFrame+Vector3.new(0,8,0) root.AssemblyLinearVelocity=Vector3.zero
    notify("Move", "Unstuck", ICO.user)
end
local function stepForward(n) local root=getRoot() if root then root.CFrame=root.CFrame*CFrame.new(0,0,-n) end end
local function setLights(on)
    local v=getVehicle() if not v then return end
    local old=v:FindFirstChild("BRPLight") if old then old:Destroy() end
    if on then
        local m=getMovePart(v) if not m then return end
        local l=Instance.new("PointLight") l.Name="BRPLight" l.Brightness=4 l.Range=40 l.Color=Color3.fromRGB(255,240,200) l.Parent=m
    end
end

local hud=Instance.new("ScreenGui") hud.Name="CoolStudiosHUD" hud.ResetOnSpawn=false hud.IgnoreGuiInset=true hud.DisplayOrder=4000 hud.Parent=PlayerGui
local brand=Instance.new("TextLabel") brand.AnchorPoint=Vector2.new(0.5,1) brand.Position=UDim2.new(0.5,0,1,-12) brand.Size=UDim2.new(0,280,0,22)
brand.BackgroundTransparency=1 brand.Font=Enum.Font.GothamBold brand.TextSize=16 brand.TextColor3=Color3.fromRGB(190,140,255) brand.Text="CoolStudios" brand.Parent=hud
local hudLab=Instance.new("TextLabel") hudLab.Position=UDim2.new(0,16,0,68) hudLab.Size=UDim2.new(0,360,0,70)
hudLab.BackgroundTransparency=1 hudLab.Font=Enum.Font.GothamBold hudLab.TextSize=16 hudLab.TextXAlignment=Enum.TextXAlignment.Left hudLab.TextYAlignment=Enum.TextYAlignment.Top
hudLab.TextColor3=Color3.fromRGB(230,230,255) hudLab.TextStrokeTransparency=0.35 hudLab.Parent=hud
local pushLab=Instance.new("TextLabel") pushLab.AnchorPoint=Vector2.new(0.5,0) pushLab.Position=UDim2.new(0.5,0,0,72) pushLab.Size=UDim2.new(0,720,0,28)
pushLab.BackgroundTransparency=1 pushLab.Font=Enum.Font.GothamBold pushLab.TextSize=18 pushLab.TextColor3=Color3.fromRGB(120,255,160) pushLab.TextStrokeTransparency=0.3 pushLab.Text="" pushLab.Parent=hud
local specGui=Instance.new("ScreenGui") specGui.ResetOnSpawn=false specGui.IgnoreGuiInset=true specGui.DisplayOrder=3000 specGui.Enabled=false specGui.Parent=PlayerGui
local specBtn=Instance.new("TextButton") specBtn.AnchorPoint=Vector2.new(1,1) specBtn.Position=UDim2.new(1,-24,1,-48) specBtn.Size=UDim2.new(0,170,0,40)
specBtn.BackgroundColor3=Color3.fromRGB(150,40,55) specBtn.Text="Spectate aus" specBtn.Font=Enum.Font.GothamBold specBtn.TextColor3=Color3.new(1,1,1) specBtn.TextSize=16 specBtn.Parent=specGui
Instance.new("UICorner",specBtn).CornerRadius=UDim.new(0,10)

local espGui = Instance.new("ScreenGui")
espGui.Name = "BRPESPGui"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2500
espGui.Parent = PlayerGui
local espFolder = Instance.new("Folder")
espFolder.Name = "BRPESP"
espFolder.Parent = espGui
local heliEspFolder=Instance.new("Folder",workspace) heliEspFolder.Name="BRPHeliESP"
local carEspFolder=Instance.new("Folder",workspace) carEspFolder.Name="BRPCarESP"
local selFolder=Instance.new("Folder",workspace) selFolder.Name="BRPSelected"
local gpsFolder=Instance.new("Folder",workspace) gpsFolder.Name="BRPGPS"

local function clearEsp()
    for _,v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end

local function addEsp(plr, my)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not (head and root and my) then return end
    local dist = math.floor((root.Position - my.Position).Magnitude)
    local staff = isStaff(plr)
    local tel = tostring(plr:GetAttribute("BRP_Notrufkennung") or "-")
    local col = staff and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(160, 90, 255)
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillColor = col
    hl.OutlineColor = col
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espFolder
    local b = Instance.new("BillboardGui")
    b.Name = "ESP_"..plr.Name
    b.Size = UDim2.new(0, 240, 0, 54)
    b.StudsOffset = Vector3.new(0, 3.2, 0)
    b.AlwaysOnTop = true
    b.MaxDistance = 5000
    b.LightInfluence = 0
    b.Adornee = head
    b.Parent = espFolder
    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, 0, 0, 22)
    t1.BackgroundTransparency = 1
    t1.Font = Enum.Font.GothamBold
    t1.TextSize = 15
    t1.TextStrokeTransparency = 0.25
    t1.TextColor3 = staff and Color3.fromRGB(255, 90, 90) or Color3.new(1, 1, 1)
    t1.Text = (staff and "[STAFF] " or "") .. plr.DisplayName
    t1.Parent = b
    local t2 = Instance.new("TextLabel")
    t2.Position = UDim2.new(0, 0, 0, 20)
    t2.Size = UDim2.new(1, 0, 0, 32)
    t2.BackgroundTransparency = 1
    t2.Font = Enum.Font.Gotham
    t2.TextSize = 13
    t2.TextStrokeTransparency = 0.3
    t2.TextColor3 = Color3.fromRGB(220, 220, 230)
    t2.Text = "@"..plr.Name.."   "..dist.."m\nTel: "..tel
    t2.Parent = b
end

local function refreshEsp()
    clearEsp()
    if not (alive and S.espOn) then return end
    local my = getRoot()
    if not my then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            addEsp(plr, my)
        end
    end
end

local function stopFreecam()
    if not freecamOn then return end
    freecamOn=false if freecamConn then freecamConn:Disconnect() freecamConn=nil end
    freezeBody(false)
    if not spectating and not gtaOn then Camera.CameraType=Enum.CameraType.Custom local hum=getHum() if hum then Camera.CameraSubject=hum end end
    if alive then notify("Freecam", "AUS", ICO.eye) end
end
local function startFreecam()
    if gtaOn then stopGta() end
    if not alive then return end
    spectating=false specGui.Enabled=false freecamOn=true freezeBody(true)
    Camera.CameraType=Enum.CameraType.Scriptable
    if freecamConn then freecamConn:Disconnect() end
    notify("Freecam", "AN", ICO.eye)
    freecamConn=RunService.RenderStepped:Connect(function(dt)
        if not alive or not freecamOn then return end
        holdBodyStill()
        local move,cf=Vector3.zero,Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move+=cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move-=cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move-=cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move+=cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move-=Vector3.yAxis end
        local speed=UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and S.freecamSpeed*2 or S.freecamSpeed
        if move.Magnitude>0 then Camera.CFrame+=move.Unit*speed*dt end
    end)
end
local function stopSpectate()
    spectating=false if specGui then specGui.Enabled=false end
    if not freecamOn and not gtaOn then Camera.CameraType=Enum.CameraType.Custom local hum=getHum() if hum then Camera.CameraSubject=hum end end
    if alive then notify("Spectate", "AUS", ICO.user) end
end
local function startSpectate(plr)
    if not (plr and plr.Character) then notify("Spectate", "Kein Ziel", ICO.warn) return end
    local hum=plr.Character:FindFirstChildOfClass("Humanoid") if not hum then return end
    if freecamOn then stopFreecam() end if gtaOn then stopGta() end
    spectating=true specGui.Enabled=true Camera.CameraType=Enum.CameraType.Custom Camera.CameraSubject=hum
    notify("Spectate", plr.DisplayName, ICO.user)
end
specBtn.MouseButton1Click:Connect(stopSpectate)
local function goPlace(label,names)
    local part,root=findNamed(names),getRoot()
    if part and root then root.CFrame=CFrame.new(part.Position+Vector3.new(0,7,0)) notify("Ort", label, ICO.map) else notify("Ort", label.." nicht gefunden", ICO.warn) end
end
local function saveWp(i) local r=getRoot() if r then wp[i]=r.CFrame notify("WP", i.." gespeichert", ICO.map) end end
local function loadWp(i) local r=getRoot() if r and wp[i] then r.CFrame=wp[i] notify("WP", i.." geladen", ICO.map) else notify("WP", i.." leer", ICO.warn) end end

local function hardOff()
    alive = false
    if gtaOn then stopGta() end
    if freecamOn then stopFreecam() end
    stopSpectate()
    if currentTween then pcall(function() currentTween:Cancel() end) end
    if noclipConn then noclipConn:Disconnect() end
    if afkConn then afkConn:Disconnect() end
    if gtaConn then gtaConn:Disconnect() end
    if freecamConn then freecamConn:Disconnect() end
    if speedHook then speedHook:Disconnect() end
    if inputConn then inputConn:Disconnect() end
    if jumpConn then jumpConn:Disconnect() end
    if charConn then charConn:Disconnect() end
    if hb1 then hb1:Disconnect() end
    if hb2 then hb2:Disconnect() end
    freezeBody(false)
    setLocalInvis(false)
    workspace.Gravity = oldGravity
    local night=Lighting:FindFirstChild("BRPNight") if night then night:Destroy() end
    local hum,root=getHum(),getRoot()
    if hum then hum.PlatformStand=false hum.AutoRotate=true end
    if root then root.Anchored=false end
    Camera.CameraType=Enum.CameraType.Custom
    if hum then Camera.CameraSubject=hum end
    pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
    for _,f in ipairs({espGui,espFolder,heliEspFolder,carEspFolder,selFolder,gpsFolder,hud,specGui}) do
        pcall(function() if f then f:Destroy() end end)
    end
    pcall(function()
        for _,g in ipairs(PlayerGui:GetChildren()) do
            local n=string.lower(g.Name)
            if string.find(n,"rayfield") or string.find(n,"brp") or string.find(n,"coolstudios") then g:Destroy() end
        end
    end)
    pcall(function()
        local cg=game:GetService("CoreGui")
        for _,g in ipairs(cg:GetChildren()) do
            local n=string.lower(g.Name)
            if string.find(n,"rayfield") then g:Destroy() end
        end
    end)
    pcall(function() if Rayfield.Destroy then Rayfield:Destroy() end end)
end

hookSpeed(getHum())
charConn=LocalPlayer.CharacterAdded:Connect(function(c)
    if not alive then return end
    task.wait(0.4)
    hookSpeed(c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid",5))
    if camLocked() then freezeBody(true) end
end)

InfoTab:CreateParagraph({Title="Update Log", Content="v2.6\n- ESP wieder alt: Name, @User, [STAFF], Distanz, Tel\n- Extra: Alles aus ohne Config-Save"})
InfoTab:CreateButton({Name="Meine Infos kopieren",Callback=function() copyText(playerCard(LocalPlayer)) end})
InfoTab:CreateButton({Name="Ziel-Infos kopieren",Callback=function() local t=Players:FindFirstChild(selectedPlayer) if t then copyText(playerCard(t)) end end})
InfoTab:CreateButton({Name="Config jetzt speichern",Callback=function() saveCfg() notify("Save", "Gespeichert", ICO.ok) end})
InfoTab:CreateButton({Name="Staff-Liste kopieren",Callback=function()
    local t={"=== STAFF ==="} for _,p in ipairs(Players:GetPlayers()) do if isStaff(p) then table.insert(t,p.DisplayName.." @"..p.Name) end end
    copyText(table.concat(t,"\n"))
end})

SchutzTab:CreateToggle({Name="Anti AFK",CurrentValue=S.antiAfk,Flag="antiAfk",Callback=function(v)
    S.antiAfk=v saveCfg()
    if afkConn then afkConn:Disconnect() afkConn=nil end
    if v then afkConn=LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
end})
SchutzTab:CreateToggle({Name="Unsterblichkeit",CurrentValue=S.godmode,Flag="god",Callback=function(v) S.godmode=v saveCfg() end})
SchutzTab:CreateToggle({Name="Anti Down",CurrentValue=S.antiDown,Flag="antidown",Callback=function(v) S.antiDown=v if v then clearDown() end saveCfg() end})
SchutzTab:CreateToggle({Name="Anti Taser",CurrentValue=S.antiTaser,Flag="antitaser",Callback=function(v) S.antiTaser=v if v then antiTaserNow() end saveCfg() end})
SchutzTab:CreateToggle({Name="Anti Cuff",CurrentValue=S.antiCuff,Flag="anticuff",Callback=function(v) S.antiCuff=v if v then antiCuffNow() end saveCfg() end})
SchutzTab:CreateToggle({Name="Kein Down-Slowwalk",CurrentValue=S.noDownSlow,Flag="noslow",Callback=function(v) S.noDownSlow=v saveCfg() end})
SchutzTab:CreateToggle({Name="Bewusstlos-UI aus",CurrentValue=S.hideDownUI,Flag="hidedown",Callback=function(v) S.hideDownUI=v hideBewusstlos(v) saveCfg() end})
SchutzTab:CreateToggle({Name="Anti Sit",CurrentValue=S.antiSit,Flag="antisit",Callback=function(v) S.antiSit=v==true saveCfg() end})
SchutzTab:CreateToggle({Name="Anti Void",CurrentValue=S.antiVoid,Flag="antivoid",Callback=function(v) S.antiVoid=v saveCfg() end})
SchutzTab:CreateToggle({Name="Auto Aufstehen",CurrentValue=S.autoGetUp,Flag="getup",Callback=function(v) S.autoGetUp=v saveCfg() end})
SchutzTab:CreateButton({Name="Jetzt reanimieren",Callback=clearDown})

MoveTab:CreateToggle({Name="WalkSpeed",CurrentValue=S.speedOn,Flag="speed",Callback=function(v) S.speedOn=v hookSpeed(getHum()) applySpeed(getHum()) saveCfg() notify("Move", "Speed "..(v and "AN" or "AUS"), ICO.user) end})
MoveTab:CreateSlider({Name="Speed",Range={12,80},Increment=1,CurrentValue=S.currentSpeed,Flag="speedval",Callback=function(v) S.currentSpeed=v applySpeed(getHum()) saveCfg() end})
MoveTab:CreateToggle({Name="Sprint Shift",CurrentValue=S.sprintOn,Flag="sprint",Callback=function(v) S.sprintOn=v saveCfg() end})
MoveTab:CreateToggle({Name="JumpPower an",CurrentValue=S.jumpOn,Flag="jumpon",Callback=function(v) S.jumpOn=v saveCfg() end})
MoveTab:CreateSlider({Name="JumpPower",Range={50,120},Increment=1,CurrentValue=S.currentJump,Flag="jumpval",Callback=function(v) S.currentJump=v saveCfg() end})
MoveTab:CreateToggle({Name="Infinite Jump",CurrentValue=S.infJump,Flag="infjump",Callback=function(v) S.infJump=v saveCfg() end})
MoveTab:CreateToggle({Name="Noclip",CurrentValue=S.noclipOn,Flag="noclip",Callback=function(v) setNoclip(v) end})
MoveTab:CreateToggle({Name="GTA Noclip",CurrentValue=false,Flag="gta",Callback=function(v) if v then startGta() else stopGta() end end})
MoveTab:CreateSlider({Name="GTA Speed",Range={20,250},Increment=5,CurrentValue=S.gtaSpeed,Flag="gtaspd",Callback=function(v) S.gtaSpeed=v saveCfg() end})
MoveTab:CreateToggle({Name="Freecam",CurrentValue=false,Flag="freecam",Callback=function(v) if v then startFreecam() else stopFreecam() end end})
MoveTab:CreateSlider({Name="Freecam Speed",Range={20,200},Increment=5,CurrentValue=S.freecamSpeed,Flag="fcspd",Callback=function(v) S.freecamSpeed=v saveCfg() end})
MoveTab:CreateToggle({Name="Click TP zu Fuss",CurrentValue=S.clickFootTP,Flag="clicktp",Callback=function(v) S.clickFootTP=v saveCfg() end})
MoveTab:CreateButton({Name="Sitz verlassen",Callback=function() local h=getHum() if h then h.Sit=false end end})

AutoTab:CreateSlider({Name="Tween Dauer",Range={0.2,5},Increment=0.1,CurrentValue=S.tweenTime,Flag="tween",Callback=function(v) S.tweenTime=v saveCfg() end})
AutoTab:CreateButton({Name="Mit Auto zum Spieler tweenen",Callback=function()
    local t=Players:FindFirstChild(selectedPlayer)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then tweenVehicle(t.Character.HumanoidRootPart.CFrame*CFrame.new(0,4,8)) end
end})
AutoTab:CreateToggle({Name="Click Tween Auto",CurrentValue=S.clickCarTP,Flag="clickcar",Callback=function(v) S.clickCarTP=v saveCfg() end})
AutoTab:CreateToggle({Name="Autos schieben",CurrentValue=S.pushCars,Flag="push",Callback=function(v) S.pushCars=v saveCfg() notify("Auto", "Schieben "..(v and "AN" or "AUS"), ICO.car) end})
AutoTab:CreateSlider({Name="Schiebe-Staerke",Range={20,1000},Increment=10,CurrentValue=S.pushPower,Flag="pushp",Callback=function(v) S.pushPower=v saveCfg() end})
AutoTab:CreateToggle({Name="Helikopter ESP",CurrentValue=S.heliESP,Flag="heliesp",Callback=function(v) S.heliESP=v if not v then heliEspFolder:ClearAllChildren() end saveCfg() end})
AutoTab:CreateButton({Name="Tween stoppen",Callback=function() if currentTween then currentTween:Cancel() end end})

GtaTab:CreateButton({Name="Naechstes Auto einsteigen",Callback=enterNearest})
GtaTab:CreateButton({Name="Auto stoppen",Callback=stopCar})
GtaTab:CreateButton({Name="Auto aufrecht",Callback=flipCar})
GtaTab:CreateButton({Name="Auto Boost",Callback=boostCar})
GtaTab:CreateSlider({Name="Boost Staerke",Range={40,250},Increment=5,CurrentValue=S.boostPower,Flag="boostp",Callback=function(v) S.boostPower=v saveCfg() end})
GtaTab:CreateButton({Name="Auto springen",Callback=jumpCar})
GtaTab:CreateButton({Name="Reifen / Physik reset",Callback=function() zeroVehicle(getVehicle()) end})
GtaTab:CreateToggle({Name="Tempomat",CurrentValue=S.cruiseOn,Flag="cruise",Callback=function(v)
    S.cruiseOn=v local m=getMovePart(getVehicle())
    if m then S.cruiseSpeed=Vector3.new(m.AssemblyLinearVelocity.X,0,m.AssemblyLinearVelocity.Z).Magnitude end
    if not S.cruiseSpeed or S.cruiseSpeed<10 then S.cruiseSpeed=40 end saveCfg()
end})
GtaTab:CreateToggle({Name="Hover",CurrentValue=S.hoverOn,Flag="hover",Callback=function(v) S.hoverOn=v saveCfg() end})
GtaTab:CreateToggle({Name="Fahrzeug ESP",CurrentValue=S.carEsp,Flag="caresp",Callback=function(v) S.carEsp=v if not v then carEspFolder:ClearAllChildren() end saveCfg() end})
GtaTab:CreateButton({Name="Auto-Pos speichern",Callback=function() local m=getMovePart(getVehicle()) if m then carWp=m.CFrame end end})
GtaTab:CreateButton({Name="Auto-Pos laden",Callback=function() local v=getVehicle() if v and carWp then placeVehicle(v,carWp) end end})
GtaTab:CreateButton({Name="Auto 20 vor",Callback=function() shiftCar(Vector3.new(0,1,-20)) end})
GtaTab:CreateButton({Name="Auto +15 hoch",Callback=function() shiftCar(Vector3.new(0,15,0)) end})
GtaTab:CreateButton({Name="180 drehen",Callback=function() turnYaw(180) end})
GtaTab:CreateButton({Name="Lack rot",Callback=function() paintCar(Color3.fromRGB(200,30,30)) end})
GtaTab:CreateButton({Name="Lack schwarz",Callback=function() paintCar(Color3.fromRGB(20,20,20)) end})
GtaTab:CreateToggle({Name="Regenbogen-Lack",CurrentValue=S.rainbow,Flag="rain",Callback=function(v) S.rainbow=v saveCfg() end})
GtaTab:CreateToggle({Name="Extra Grip",CurrentValue=S.gripOn,Flag="grip",Callback=function(v) S.gripOn=v saveCfg() end})
GtaTab:CreateToggle({Name="Auto-Aufrecht Loop",CurrentValue=S.autoFlip,Flag="autoflip",Callback=function(v) S.autoFlip=v saveCfg() end})
GtaTab:CreateToggle({Name="Nitro halten",CurrentValue=S.nitroOn,Flag="nitro",Callback=function(v) S.nitroOn=v saveCfg() end})
GtaTab:CreateToggle({Name="Tieferlegen",CurrentValue=S.lowOn,Flag="low",Callback=function(v) S.lowOn=v saveCfg() end})
GtaTab:CreateToggle({Name="Nachtsicht",CurrentValue=S.nightOn,Flag="night",Callback=function(v)
    S.nightOn=v local cc=Lighting:FindFirstChild("BRPNight")
    if v then if not cc then cc=Instance.new("ColorCorrectionEffect") cc.Name="BRPNight" cc.Parent=Lighting end
        cc.Enabled=true cc.Contrast=0.4 cc.Saturation=-0.2 cc.TintColor=Color3.fromRGB(140,255,160)
    elseif cc then cc.Enabled=false end saveCfg()
end})
GtaTab:CreateToggle({Name="Auto fliegen",CurrentValue=S.carFly,Flag="carfly",Callback=function(v) S.carFly=v saveCfg() end})
GtaTab:CreateButton({Name="Boden-Snap",Callback=snapGround})
GtaTab:CreateButton({Name="90 links",Callback=function() turnYaw(90) end})
GtaTab:CreateButton({Name="90 rechts",Callback=function() turnYaw(-90) end})
GtaTab:CreateButton({Name="Rueckwaerts-Boost",Callback=function()
    local veh,m=getVehicle(),getMovePart(getVehicle())
    if m then m.AssemblyLinearVelocity=-driveDir(veh)*S.boostPower end
end})
GtaTab:CreateToggle({Name="Auto unsichtbar",CurrentValue=S.carInvis,Flag="carinv",Callback=function(v) S.carInvis=v setVehSeeThrough(getVehicle(),v) saveCfg() end})
GtaTab:CreateToggle({Name="Scheinwerfer",CurrentValue=S.lights,Flag="lights",Callback=function(v) S.lights=v setLights(v) saveCfg() end})
GtaTab:CreateButton({Name="Rauswerfen",Callback=function() local h=getHum() if h then h.Sit=false end end})
GtaTab:CreateButton({Name="Unstuck +8",Callback=unstuck})
GtaTab:CreateButton({Name="10 Studs vor (Fuss)",Callback=function() stepForward(10) end})
GtaTab:CreateToggle({Name="Langsamer Fall",CurrentValue=S.slowFall,Flag="slowfall",Callback=function(v) S.slowFall=v saveCfg() end})
GtaTab:CreateToggle({Name="Wenig Gravity",CurrentValue=S.lowGrav,Flag="lowgrav",Callback=function(v)
    S.lowGrav=v workspace.Gravity=v and 40 or oldGravity saveCfg()
end})
GtaTab:CreateToggle({Name="Mich einfrieren",CurrentValue=S.freezeMe,Flag="freezeme",Callback=function(v)
    S.freezeMe=v local r=getRoot() if r and not camLocked() then r.Anchored=v end saveCfg()
end})
GtaTab:CreateToggle({Name="GPS zu WP1",CurrentValue=S.gps,Flag="gps",Callback=function(v) S.gps=v if not v then gpsFolder:ClearAllChildren() end saveCfg() end})
GtaTab:CreateToggle({Name="Landehilfe Auto",CurrentValue=S.landHelp,Flag="land",Callback=function(v) S.landHelp=v saveCfg() end})
GtaTab:CreateToggle({Name="Tempo-Limit",CurrentValue=S.speedCap,Flag="cap",Callback=function(v) S.speedCap=v saveCfg() end})
GtaTab:CreateSlider({Name="Limit KMH",Range={20,150},Increment=5,CurrentValue=S.capKmh or 80,Flag="capkmh",Callback=function(v) S.capKmh=v saveCfg() end})
GtaTab:CreateButton({Name="Sitz irgendwo",Callback=function() local h=getHum() if h then h.Sit=true end end})
GtaTab:CreateButton({Name="Auto-CFrame kopieren",Callback=function()
    local m=getMovePart(getVehicle())
    if m then copyText(string.format("%.1f, %.1f, %.1f",m.Position.X,m.Position.Y,m.Position.Z)) end
end})
GtaTab:CreateButton({Name="Wetter klar",Callback=function() applyFullbright() S.fullbright=true saveCfg() end})
GtaTab:CreateButton({Name="Look zum Ziel",Callback=function()
    local t,root=Players:FindFirstChild(selectedPlayer),getRoot()
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and root then
        root.CFrame=CFrame.lookAt(root.Position,t.Character.HumanoidRootPart.Position)
    end
end})

OrteTab:CreateButton({Name="Polizei Wache",Callback=function() goPlace("Wache",{"Polizei Wache Bodensee"}) end})
OrteTab:CreateButton({Name="Krankenhaus",Callback=function() goPlace("KH",{"Krankenhaus","Krankenhaus1"}) end})
OrteTab:CreateButton({Name="Feuerwehr",Callback=function() goPlace("FW",{"Feuerwehr"}) end})
OrteTab:CreateButton({Name="Leitstelle",Callback=function() goPlace("LS",{"Leitstelle"}) end})
OrteTab:CreateButton({Name="Wasserrettung",Callback=function() goPlace("WR",{"Wasserrettung"}) end})
OrteTab:CreateButton({Name="Luftrettung",Callback=function() goPlace("Luft",{"DRS Luftrettung Wache"}) end})
OrteTab:CreateButton({Name="Volksbank",Callback=function() goPlace("Bank",{"Volksbank 2"}) end})
OrteTab:CreateButton({Name="Sparkasse",Callback=function() goPlace("Sparkasse",{"neon_sparkasse"}) end})
OrteTab:CreateButton({Name="Busbahnhof",Callback=function() goPlace("Bahnhof",{"Busbahnhof"}) end})
OrteTab:CreateButton({Name="Shop",Callback=function() goPlace("Shop",{"circle_shop"}) end})
OrteTab:CreateButton({Name="WP1 speichern",Callback=function() saveWp(1) end})
OrteTab:CreateButton({Name="WP1 teleport",Callback=function() loadWp(1) end})
OrteTab:CreateButton({Name="WP2 speichern",Callback=function() saveWp(2) end})
OrteTab:CreateButton({Name="WP2 teleport",Callback=function() loadWp(2) end})
OrteTab:CreateButton({Name="WP3 speichern",Callback=function() saveWp(3) end})
OrteTab:CreateButton({Name="WP3 teleport",Callback=function() loadWp(3) end})

local dropdown=SpielerTab:CreateDropdown({Name="Spieler",Options={"Niemand"},CurrentOption={"Niemand"},MultipleOptions=false,Callback=function(opt) selectedPlayer=type(opt)=="table" and opt[1] or opt end})
local function refreshPlayers()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(list,p.Name) end end
    if #list==0 then list={"Niemand"} end
    pcall(function() dropdown:Refresh(list) end)
end
SpielerTab:CreateButton({Name="Liste aktualisieren",Callback=function() refreshPlayers() notify("Spieler", "Liste neu", ICO.user) end})
SpielerTab:CreateButton({Name="Als Staff markieren",Callback=function() markStaff(selectedPlayer,true) refreshPlayers() end})
SpielerTab:CreateButton({Name="Staff-Markierung weg",Callback=function() markStaff(selectedPlayer,false) refreshPlayers() end})
SpielerTab:CreateButton({Name="Spectate",Callback=function() startSpectate(Players:FindFirstChild(selectedPlayer)) end})
SpielerTab:CreateButton({Name="Spectate aus",Callback=stopSpectate})
SpielerTab:CreateButton({Name="Zu Fuss zum Spieler",Callback=function()
    local t,root=Players:FindFirstChild(selectedPlayer),getRoot()
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and root then
        root.CFrame=t.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,4)
    end
end})
SpielerTab:CreateToggle({Name="Ziel highlighten",CurrentValue=S.hlSelected,Flag="hl",Callback=function(v) S.hlSelected=v if not v then selFolder:ClearAllChildren() end saveCfg() end})
SpielerTab:CreateButton({Name="Spielerinfo kopieren",Callback=function() local t=Players:FindFirstChild(selectedPlayer) if t then copyText(playerCard(t)) end end})

VisualTab:CreateToggle({Name="ESP",CurrentValue=S.espOn,Flag="esp",Callback=function(v)
    S.espOn=v
    refreshEsp()
    notify("ESP", v and "AN" or "AUS", ICO.eye)
    saveCfg()
end})
VisualTab:CreateToggle({Name="HUD",CurrentValue=S.showHud,Flag="hud",Callback=function(v) S.showHud=v hudLab.Visible=v saveCfg() end})
VisualTab:CreateToggle({Name="Fullbright",CurrentValue=S.fullbright,Flag="fb",Callback=function(v) S.fullbright=v==true saveCfg() end})
VisualTab:CreateToggle({Name="Kein Nebel",CurrentValue=S.noFog,Flag="nofog",Callback=function(v) S.noFog=v saveCfg() end})
VisualTab:CreateToggle({Name="Schatten aus",CurrentValue=S.shadowsOff,Flag="noshad",Callback=function(v) S.shadowsOff=v Lighting.GlobalShadows=not v saveCfg() end})
VisualTab:CreateToggle({Name="Blur/Bloom aus",CurrentValue=S.noFx,Flag="nofx",Callback=function(v) S.noFx=v if v then killFx() end saveCfg() end})
VisualTab:CreateSlider({Name="FOV",Range={50,120},Increment=1,CurrentValue=S.currentFOV,Flag="fov",Callback=function(v) S.currentFOV=v saveCfg() end})
VisualTab:CreateToggle({Name="Zoom",CurrentValue=S.tZoom,Flag="zoom",Callback=function(v) S.tZoom=v saveCfg() end})
VisualTab:CreateToggle({Name="Third Person",CurrentValue=S.tThird,Flag="third",Callback=function(v)
    S.tThird=v local hum=getHum() if hum then hum.CameraOffset=v and Vector3.new(0,1.5,8) or Vector3.zero end saveCfg()
end})

for _,name in ipairs({"StatusUI","Handy","Radio","PagerUI","LeitstellenpanelUI","polizei","CarSpawnUI","IngameShopGui","BewusstlosUI"}) do
    GuiTab:CreateButton({Name=name,Callback=function() toggleGui(name) end})
end

local keyList={"C","N","G","H","X","V","J","K","L","T","Y","U","M","F","Q","B"}
BindTab:CreateDropdown({Name="Taste Auto schieben",Options=keyList,CurrentOption={S.keyPush},MultipleOptions=false,Flag="keyPush",Callback=function(opt) S.keyPush=type(opt)=="table" and opt[1] or opt saveKeys() saveCfg() notify("Taste", "Schieben = "..S.keyPush, ICO.key) end})
BindTab:CreateDropdown({Name="Taste GTA Noclip",Options=keyList,CurrentOption={S.keyGta},MultipleOptions=false,Flag="keyGta",Callback=function(opt) S.keyGta=type(opt)=="table" and opt[1] or opt saveKeys() saveCfg() notify("Taste", "GTA = "..S.keyGta, ICO.key) end})
BindTab:CreateDropdown({Name="Taste Auto Boost",Options=keyList,CurrentOption={S.keyBoost},MultipleOptions=false,Flag="keyBoost",Callback=function(opt) S.keyBoost=type(opt)=="table" and opt[1] or opt saveKeys() saveCfg() notify("Taste", "Boost = "..S.keyBoost, ICO.key) end})
BindTab:CreateDropdown({Name="Taste Auto Sprung",Options=keyList,CurrentOption={S.keyJumpCar},MultipleOptions=false,Flag="keyJumpCar",Callback=function(opt) S.keyJumpCar=type(opt)=="table" and opt[1] or opt saveKeys() saveCfg() notify("Taste", "Sprung = "..S.keyJumpCar, ICO.key) end})
local function addBind(name,key,fn) pcall(function() BindTab:CreateKeybind({Name=name,CurrentKeybind=key,HoldToInteract=false,Callback=fn}) end) end
addBind("Infinite Jump","F6",function() S.infJump=not S.infJump saveCfg() end)
addBind("WalkSpeed","F8",function() S.speedOn=not S.speedOn hookSpeed(getHum()) applySpeed(getHum()) saveCfg() end)
addBind("Freecam","F9",function() if freecamOn then stopFreecam() else startFreecam() end end)
addBind("Fullbright","F10",function() S.fullbright=not S.fullbright saveCfg() end)
addBind("ESP","F4",function() S.espOn=not S.espOn refreshEsp() notify("ESP", S.espOn and "AN" or "AUS", ICO.eye) saveCfg() end)
addBind("Reanimieren","R",function() clearDown() end)
addBind("Auto aufrecht","F",function() flipCar() end)
addBind("Auto stoppen","X",function() stopCar() end)
addBind("Naechstes Auto","T",function() enterNearest() end)
addBind("Unstuck","U",function() unstuck() end)

ExtraTab:CreateToggle({Name="Auto Rejoin",CurrentValue=S.autoRejoin,Flag="rejoin",Callback=function(v) S.autoRejoin=v saveCfg() end})
ExtraTab:CreateButton({Name="Rejoin",Callback=function() saveCfg() TeleportService:Teleport(game.PlaceId,LocalPlayer) end})
ExtraTab:CreateButton({Name="Config speichern",Callback=function() saveCfg() notify("Save", "Gespeichert", ICO.ok) end})
ExtraTab:CreateButton({Name="Alles aus + GUI zu",Callback=function() hardOff() end})

if S.antiAfk then afkConn=LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end) end
inputConn=UserInputService.InputBegan:Connect(function(input,processed)
    if not alive then return end
    if input.KeyCode==Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not processed then
        if freecamOn then stopFreecam() else startFreecam() end
    end
    if processed then return end
    local name=input.KeyCode.Name
    if name==S.keyPush then S.pushCars=not S.pushCars saveCfg() notify("Taste", "Schieben "..(S.pushCars and "AN" or "AUS"), ICO.key) end
    if name==S.keyGta then if gtaOn then stopGta() else startGta() end end
    if name==S.keyBoost then boostCar() end
    if name==S.keyJumpCar then jumpCar() end
    if input.UserInputType==Enum.UserInputType.MouseButton3 then
        local hit=Mouse.Hit if not hit then return end
        if S.clickCarTP and getVehicle() then tweenVehicle(CFrame.new(hit.Position+Vector3.new(0,4,0)))
        elseif S.clickFootTP then local root=getRoot() if root then root.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0)) end end
    end
end)
jumpConn=UserInputService.JumpRequest:Connect(function()
    if not alive or camLocked() then return end
    if S.infJump then local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

hb1=RunService.Heartbeat:Connect(function()
    if not alive then return end
    if camLocked() then holdBodyStill() else applySpeed(getHum()) end
end)

hb2=RunService.Heartbeat:Connect(function(dt)
    if not alive then return end
    acc+=dt fps=math.floor(1/math.max(dt,0.001))
    local char,hum,root=getChar(),getHum(),getRoot()
    specGui.Enabled=spectating
    if S.fullbright then applyFullbright() end
    if S.noFog then Lighting.FogEnd=100000 end
    if S.shadowsOff then Lighting.GlobalShadows=false end
    if S.noFx then killFx() end
    if S.godmode and hum then hum.Health=100 end
    if not camLocked() and tick()>=nextProtect then
        nextProtect=tick()+0.35
        if S.antiDown then clearDown() end
        if S.antiTaser then antiTaserNow() end
        if S.antiCuff then antiCuffNow() end
        if S.autoGetUp and hum and hum.PlatformStand and not hum.SeatPart then hum.PlatformStand=false end
        if S.antiSit==true and hum and hum.Sit and not hum.SeatPart then hum.Sit=false end
        if S.hideDownUI then hideBewusstlos(true) end
    end
    if S.antiVoid and root and root.Position.Y<-50 and not camLocked() then root.CFrame=CFrame.new(0,20,0) end
    if S.tThird and hum and not camLocked() then hum.CameraOffset=Vector3.new(0,1.5,8) end
    if not camLocked() then Camera.FieldOfView=S.tZoom and 35 or S.currentFOV end
    if S.freezeMe and root and not camLocked() then root.Anchored=true end
    if S.slowFall and root and not camLocked() and root.AssemblyLinearVelocity.Y<-60 then
        root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,-25,root.AssemblyLinearVelocity.Z)
    end
    local veh,vehMove=getVehicle(),getMovePart(getVehicle())
    if S.carInvis then setVehSeeThrough(veh,true) end
    if S.cruiseOn and vehMove then
        local dir=driveDir(veh)
        local flat=Vector3.new(dir.X,0,dir.Z)
        if flat.Magnitude>0.05 then vehMove.AssemblyLinearVelocity=flat.Unit*(S.cruiseSpeed or 40)+Vector3.new(0,vehMove.AssemblyLinearVelocity.Y,0) end
    end
    if S.hoverOn and vehMove then vehMove.AssemblyLinearVelocity=Vector3.new(vehMove.AssemblyLinearVelocity.X,6,vehMove.AssemblyLinearVelocity.Z) end
    if S.nitroOn and vehMove then
        local flat=Vector3.new(driveDir(veh).X,0,driveDir(veh).Z)
        if flat.Magnitude>0.05 then vehMove.AssemblyLinearVelocity=vehMove.AssemblyLinearVelocity+flat.Unit*8 end
    end
    if S.carFly and vehMove then
        local dir=Camera.CFrame.LookVector local fly=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then fly+=dir end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then fly-=dir end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then fly-=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then fly+=Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then fly+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then fly-=Vector3.yAxis end
        if fly.Magnitude>0 then vehMove.AssemblyLinearVelocity=fly.Unit*80 else vehMove.AssemblyLinearVelocity=Vector3.zero end
        vehMove.AssemblyAngularVelocity=Vector3.zero
    end
    if S.gripOn and veh then for _,p in ipairs(veh:GetDescendants()) do if p:IsA("BasePart") then p.AssemblyAngularVelocity=Vector3.zero end end end
    if S.autoFlip and vehMove and vehMove.CFrame.UpVector.Y<0.2 then flipCar() end
    if S.rainbow and veh then rainbowHue=(rainbowHue+dt*0.25)%1 paintCar(Color3.fromHSV(rainbowHue,0.85,1)) end
    if S.lowOn and vehMove then vehMove.AssemblyLinearVelocity=vehMove.AssemblyLinearVelocity+Vector3.new(0,-4,0) end
    if S.landHelp and vehMove and vehMove.AssemblyLinearVelocity.Y<-40 then
        vehMove.AssemblyLinearVelocity=Vector3.new(vehMove.AssemblyLinearVelocity.X,-15,vehMove.AssemblyLinearVelocity.Z)
    end
    if S.speedCap and vehMove then
        local cap=S.capKmh or 80
        if vehMove.AssemblyLinearVelocity.Magnitude>cap then vehMove.AssemblyLinearVelocity=vehMove.AssemblyLinearVelocity.Unit*cap end
    end
    if S.pushCars then pushLab.TextColor3=Color3.fromRGB(120,255,160) pushLab.Text="Auto schieben AN  |  "..S.keyPush.." aus"
    elseif gtaOn then pushLab.TextColor3=Color3.fromRGB(180,140,255) pushLab.Text="GTA NOCLIP AN  |  "..S.keyGta.." aus"
    elseif freecamOn then pushLab.TextColor3=Color3.fromRGB(180,200,255) pushLab.Text="FREECAM AN  |  Koerper steht"
    else pushLab.Text="" end
    if S.pushCars and char and root and hum and not hum.SeatPart and not camLocked() then
        local params=OverlapParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={char}
        local hits=workspace:GetPartBoundsInBox(root.CFrame,Vector3.new(10,8,10),params)
        local seen={} local dir=hum.MoveDirection.Magnitude>0.05 and hum.MoveDirection or root.CFrame.LookVector
        for _,part in ipairs(hits) do
            local model=part:FindFirstAncestorOfClass("Model")
            if model and not seen[model] and isRealVehicle(model) then
                seen[model]=true local move=getMovePart(model)
                if move then move.AssemblyLinearVelocity=dir.Unit*S.pushPower move.AssemblyAngularVelocity=Vector3.zero end
            end
        end
    end
    if S.showHud and acc>0.25 then
        acc=0
        local kmh=vehMove and math.floor(vehMove.AssemblyLinearVelocity.Magnitude) or 0
        local pn=tostring(LocalPlayer:GetAttribute("PersonalNumber") or "-")
        hudLab.Text="KMH  "..kmh.."\nPN   "..pn.."\nFPS  "..fps
    end
end)

task.spawn(function()
    while alive do
        task.wait(8)
        if alive then saveCfg() end
    end
end)
task.spawn(function()
    while alive do
        task.wait(1)
        if not alive then break end
        refreshEsp()
        selFolder:ClearAllChildren()
        if S.hlSelected then
            local t=Players:FindFirstChild(selectedPlayer)
            if t and t.Character then
                local hl=Instance.new("Highlight") hl.Adornee=t.Character hl.FillColor=Color3.fromRGB(255,220,80) hl.Parent=selFolder
            end
        end
        gpsFolder:ClearAllChildren()
        if S.gps and wp[1] then
            local my=getRoot()
            if my then
                local a0=Instance.new("Attachment",my) local p=Instance.new("Part")
                p.Anchored=true p.CanCollide=false p.Transparency=1 p.Size=Vector3.new(1,1,1) p.CFrame=wp[1] p.Parent=gpsFolder
                local a1=Instance.new("Attachment",p)
                local beam=Instance.new("Beam") beam.Attachment0=a0 beam.Attachment1=a1 beam.Color=ColorSequence.new(Color3.fromRGB(80,255,160))
                beam.Width0=0.15 beam.Width1=0.15 beam.FaceCamera=true beam.Parent=gpsFolder
            end
        end
        carEspFolder:ClearAllChildren()
        if S.carEsp then
            local my=getRoot()
            if my then
                local seen={}
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("VehicleSeat") then
                        local m=obj:FindFirstAncestorOfClass("Model")
                        if m and not seen[m] and isRealVehicle(m) then
                            seen[m]=true local p=getMovePart(m)
                            if p and (p.Position-my.Position).Magnitude<250 then
                                local hl=Instance.new("Highlight") hl.Adornee=m hl.FillColor=Color3.fromRGB(80,255,140) hl.FillTransparency=0.7 hl.Parent=carEspFolder
                            end
                        end
                    end
                end
            end
        end
        if S.heliESP then
            heliEspFolder:ClearAllChildren()
            local my=getRoot()
            if my then
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("VehicleSeat") then
                        local m=obj:FindFirstAncestorOfClass("Model")
                        if m and isHelicopter(m) then
                            local p=getMovePart(m)
                            if p and (p.Position-my.Position).Magnitude<400 then
                                local hl=Instance.new("Highlight") hl.Adornee=m hl.FillColor=Color3.fromRGB(80,200,255) hl.FillTransparency=0.6 hl.Parent=heliEspFolder
                            end
                        end
                    end
                end
            end
        else heliEspFolder:ClearAllChildren() end
        if S.autoRejoin and #Players:GetPlayers()<2 and not rejoinPending then
            rejoinPending=true
            task.delay(5,function() if alive and S.autoRejoin then pcall(function() TeleportService:Teleport(game.PlaceId,LocalPlayer) end) end rejoinPending=false end)
        elseif #Players:GetPlayers()>=2 then rejoinPending=false end
    end
end)

refreshPlayers()
refreshEsp()
notify("BRP Helper", "v2.6 geladen", ICO.star)