--=============================================================
--   🦖 PREHISTORIC FARM — HUB v3.1 (ES)  | Place: 139780970631001
--=============================================================
local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local LP         = Players.LocalPlayer
local LIGHT      = game:GetService("Lighting")

local function hum()
    local c = LP.Character or LP.CharacterAdded:Wait()
    return c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end
local function fire(obj, ...)
    if obj:IsA("RemoteFunction") then return obj:InvokeServer(...) else obj:FireServer(...) end
end
local function resolvePath(path)
    local o=RS
    for seg in path:gmatch("[^%.]+") do
        if seg~="ReplicatedStorage" and seg~="game" then o=o and o:FindFirstChild(seg) end
    end
    return o
end

-- ESTADO GLOBAL (declarado arriba para que todos los callbacks lo vean)
local spd = 16
local infjump = false
local flying, noclip = false, false
local autoDig, tpDig = false, true
local autoPrompt, radius = false, 30
local forcePrompt, instantHold = false, false
local autoMoneyOn = false
local moneyRemotePath = ""
local espP, espD, espDig = false, false, false
local antiVoid, antiAfk, followOn, walkWater = false, false, false, false

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Win = Rayfield:CreateWindow({
    Name = "🦖 Prehistoric Farm — Hub v3.1",
    LoadingTitle = "Cargando Hub",
    LoadingSubtitle = "por Venice",
    ConfigurationSaving = { Enabled = true, FolderName = "PFHub", FileName = "cfg" },
    KeySystem = false,
})
local T_Home  = Win:CreateTab("Inicio", 4483362458)
local T_Move  = Win:CreateTab("Movimiento", 4483345998)
local T_Vis   = Win:CreateTab("Visuales", 6031090687)
local T_Spots = Win:CreateTab("Spots", 6023426926)
local T_Auto  = Win:CreateTab("Auto Granja", 4483362458)
local T_Byp   = Win:CreateTab("Bypass", 4483345998)
local T_Money = Win:CreateTab("Dinero / Remotes", 6031090687)
local T_Plr   = Win:CreateTab("Jugador", 6023426926)
local T_Extra = Win:CreateTab("Extras", 4483362458)

--==================== INICIO ====================
T_Home:CreateSection("Guía")
T_Home:CreateParagraph({ Title="Cómo usarlo", Content=[[1) Dinero/Remotes -> Detectar.
2) Pulsa MODO FARM COMPLETO.
3) Listo.]] })
T_Home:CreateParagraph({ Title="Mejores huevos", Content=[[T-Rex y Spinosaurus (Legendario).
Fósiles Giant Skull / Volcanic Core en Jungle y Volcano.]] })
T_Home:CreateSection("Acciones")
T_Home:CreateButton({ Name="⚡ MODO FARM COMPLETO (todo ON)", Callback=function()
    autoDig=true; tpDig=true; forcePrompt=true; instantHold=true; autoPrompt=true; autoMoneyOn=true
    Rayfield:Notify({Title="Modo Farm",Content="Auto Cavar + Bypass + Auto Dinero ON",Duration=5})
end })
T_Home:CreateButton({ Name="🔌 Unload", Callback=function() pcall(function() Rayfield:Destroy() end) end })
T_Home:CreateSection("Servidor")
T_Home:CreateButton({ Name="Rejoin", Callback=function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end })
T_Home:CreateButton({ Name="Info servidor", Callback=function()
    Rayfield:Notify({Title="Servidor",Content=#Players:GetPlayers().." jugadores",Duration=4}) end })
T_Home:CreateButton({ Name="Guardar Config", Callback=function() Rayfield:SaveConfiguration() end })
T_Home:CreateButton({ Name="Cargar Config", Callback=function() Rayfield:LoadConfiguration() end })

--==================== MOVIMIENTO ====================
T_Move:CreateSection("Velocidad")
T_Move:CreateSlider({ Name="Velocidad", Range={16,1000}, Increment=1, Suffix=" studs",
    CurrentValue=16, Flag="spd", Callback=function(v) spd=v
        local h=hum(); if h then h.WalkSpeed=v end end })
T_Move:CreateSlider({ Name="Salto", Range={50,1000}, Increment=1, Suffix=" pw",
    CurrentValue=50, Flag="jp", Callback=function(v)
        local h=hum(); if h then h.UseJumpPower=true; h.JumpPower=v end end })
T_Move:CreateToggle({ Name="Salto Infinito", CurrentValue=false, Flag="infjump",
    Callback=function(v) infjump=v end })
UIS.JumpRequest:Connect(function()
    if infjump then local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
T_Move:CreateSection("Volar / Noclip")
local function toggleFly()
    flying=not flying
    if not flying then return end
    local _,root=hum()
    local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=Vector3.zero; bv.Parent=root
    local keys,speed={},80; local conn
    conn=RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then bv:Destroy(); conn:Disconnect(); return end
        local cam=workspace.CurrentCamera.CFrame; local m=Vector3.zero
        if keys[Enum.KeyCode.W] then m+=cam.LookVector end
        if keys[Enum.KeyCode.S] then m-=cam.LookVector end
        if keys[Enum.KeyCode.A] then m-=cam.RightVector end
        if keys[Enum.KeyCode.D] then m+=cam.RightVector end
        if keys[Enum.KeyCode.Space] then m+=Vector3.new(0,1,0) end
        if keys[Enum.KeyCode.LeftControl] then m-=Vector3.new(0,1,0) end
        bv.Velocity = m.Magnitude>0 and m.Unit*speed or Vector3.zero
    end)
    UIS.InputBegan:Connect(function(i,g) if not g then keys[i.KeyCode]=true end end)
    UIS.InputEnded:Connect(function(i) keys[i.KeyCode]=false end)
end
T_Move:CreateToggle({ Name="Volar", CurrentValue=false, Flag="fly",
    Callback=function(v) flying=v; if v then toggleFly() end end })
T_Move:CreateToggle({ Name="Noclip", CurrentValue=false, Flag="noclip", Callback=function(v) noclip=v end })
RunService.Stepped:Connect(function()
    if noclip and LP.Character then
        for _,p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end
end)
T_Move:CreateSection("Ingeniosos")
local function clickTP()
    local m=UIS:GetMouseLocation()
    local ray=workspace.CurrentCamera:ViewportPointToRay(m.X,m.Y)
    local par=RaycastParams.new(); par.FilterDescendantsInstances={LP.Character}
    local res=workspace:Raycast(ray.Origin,ray.Direction*3000,par)
    if res then local _,hrp=hum(); hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,4,0)) end
end
T_Move:CreateButton({ Name="Teleport al cursor (Click TP)", Callback=clickTP })
local savedPos
T_Move:CreateButton({ Name="Guardar posición", Callback=function()
    local _,hrp=hum(); savedPos=hrp.CFrame
    Rayfield:Notify({Title="Pos",Content="Guardada",Duration=2}) end })
T_Move:CreateButton({ Name="Ir a posición guardada", Callback=function()
    if savedPos then local _,hrp=hum(); hrp.CFrame=savedPos end end })
T_Move:CreateToggle({ Name="Seguir jugador más cercano", CurrentValue=false, Flag="follow",
    Callback=function(v)
        followOn=v; if not v then return end
        task.spawn(function()
            while followOn do
                task.wait(0.1)
                local _,hrp=hum(); local best,bd
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP and p.Character then
                        local r=p.Character:FindFirstChild("HumanoidRootPart")
                        if r then local d=(r.Position-hrp.Position).Magnitude
                            if not bd or d<bd then best,bd=r,d end end
                    end
                end
                if best then hrp.CFrame=best.CFrame*CFrame.new(0,0,6) end
            end
        end)
    end })
T_Move:CreateSection("Agua")
local waterY
T_Move:CreateToggle({ Name="Caminar sobre el agua", CurrentValue=false, Flag="ww",
    Callback=function(v)
        walkWater=v
        if v then
            local _,hrp=hum(); waterY=hrp.Position.Y
            local bp=Instance.new("BodyPosition"); bp.Name="PF_WW"
            bp.MaxForce=Vector3.new(1e5,1e5,1e5); bp.P=25000; bp.D=1500
            bp.Position=hrp.Position; bp.Parent=hrp
            task.spawn(function()
                while walkWater and hrp.Parent do
                    task.wait()
                    bp.Position=Vector3.new(hrp.Position.X, waterY, hrp.Position.Z)
                end
                if bp then bp:Destroy() end
            end)
        end
    end })

--==================== VISUALES ====================
T_Vis:CreateSection("Mundo")
T_Vis:CreateToggle({ Name="Fullbright", CurrentValue=false, Flag="fb", Callback=function(v)
    LIGHT.Brightness = v and 3 or 2
    if v then LIGHT.FogEnd=1e6; LIGHT.GlobalShadows=false end
end })
T_Vis:CreateToggle({ Name="Forzar NOCHE", CurrentValue=false, Flag="night",
    Callback=function(v) if v then LIGHT.ClockTime=0 end end })
T_Vis:CreateToggle({ Name="Forzar DÍA", CurrentValue=false, Flag="day",
    Callback=function(v) if v then LIGHT.ClockTime=14 end end })
T_Vis:CreateSection("ESP")
local function setESP(parent, on, color, flag)
    local ex=parent:FindFirstChild(flag)
    if on then
        if not ex then local h=Instance.new("Highlight")
            h.Name=flag; h.FillColor=color; h.Parent=parent end
    elseif ex then ex:Destroy() end
end
T_Vis:CreateToggle({ Name="ESP Jugadores", CurrentValue=false, Flag="ep", Callback=function(v)
    espP=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then setESP(p.Character, v, Color3.fromRGB(0,255,0), "PF_EP") end
    end
end })
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) if espP then setESP(c,true,Color3.fromRGB(0,255,0),"PF_EP") end end)
end)
T_Vis:CreateToggle({ Name="ESP Dinos/NPCs", CurrentValue=false, Flag="ed", Callback=function(v)
    espD=v
    for _,d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") and d~=LP.Character then
            setESP(d, v, Color3.fromRGB(255,170,0), "PF_ED")
        end
    end
end })

--==================== SPOTS ====================
local function isDig(d)
    if not d:IsA("BasePart") then return false end
    local n=d.Name:lower()
    return n:find("dig") or n:find("mound") or n:find("fossil") or n:find("dirt") or n:find("spot")
end
local function scanZones()
    local z={}
    for _,d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            local n=d.Name:lower()
            if n:find("island") or n:find("jungle") or n:find("volcano")
               or n:find("cretaceous") or n:find("jurassic") or n:find("triassic")
               or n:find("cambrian") or n:find("devonian") or n:find("desert")
               or n:find("lab") or n:find("home") or n:find("ranch") or n:find("grotto") then
                if not z[d.Name] then z[d.Name]=d.Position end
            end
        end
    end
    return z
end
T_Spots:CreateSection("Zonas")
local zoneList={}
for n,_ in pairs(scanZones()) do table.insert(zoneList,n) end
if #zoneList==0 then zoneList={"Refrescar primero"} end
T_Spots:CreateButton({ Name="Refrescar zonas", Callback=function()
    zoneList={}; for n,_ in pairs(scanZones()) do table.insert(zoneList,n) end
    if #zoneList==0 then zoneList={"Refrescar primero"} end
    Rayfield:Notify({Title="Spots",Content=#zoneList.." zonas",Duration=3}) end })
T_Spots:CreateDropdown({ Name="Teleport a zona", Options=zoneList, Flag="tz",
    Callback=function(c) local z=scanZones()[c]
        if z then local _,hrp=hum(); hrp.CFrame=CFrame.new(z+Vector3.new(0,8,0)) end end })
local function tpByName(key)
    for _,d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.Name:lower():find(key) then
            local _,hrp=hum(); hrp.CFrame=CFrame.new(d.Position+Vector3.new(0,8,0)); return true end
    end
end
T_Spots:CreateButton({ Name="→ Jungle (legendario)", Callback=function() tpByName("jungle") end })
T_Spots:CreateButton({ Name="→ Volcano (legendario)", Callback=function() tpByName("volcano") end })
T_Spots:CreateButton({ Name="→ Vender (shop)", Callback=function() tpByName("sell") end })
T_Spots:CreateButton({ Name="→ Dr. Ivy / Lab", Callback=function() tpByName("lab") end })
T_Spots:CreateSection("Excavación")
T_Spots:CreateToggle({ Name="Resaltar montículos", CurrentValue=false, Flag="edg",
    Callback=function(v)
        espDig=v
        for _,d in ipairs(workspace:GetDescendants()) do
            if isDig(d) then
                local ex=d:FindFirstChild("PF_DIG")
                if v and not ex then local h=Instance.new("Highlight")
                    h.Name="PF_DIG"; h.FillColor=Color3.fromRGB(0,170,255); h.Parent=d
                elseif not v and ex then ex:Destroy() end
            end
        end
    end })

--==================== AUTO GRANJA ====================
local function promptOf(part)
    if part:IsA("ProximityPrompt") then return part end
    return part:FindFirstChildWhichIsA("ProximityPrompt", true)
end
local function triggerPrompt(p)
    pcall(function()
        if fireproximityprompt then fireproximityprompt(p)
        else p:InputHoldBegin(); task.wait(math.max(p.HoldDuration,0.05)); p:InputHoldEnd() end
    end)
end
local function nearestDig(origin)
    local best,bd
    for _,d in ipairs(workspace:GetDescendants()) do
        if isDig(d) then local dist=(d.Position-origin).Magnitude
            if not bd or dist<bd then best,bd=d,dist end end
    end
    return best,bd
end
local function getTool(m)
    local c=LP.Character; if not c then return end
    for _,t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find(m) then return t end end
end
T_Auto:CreateSection("Excavar")
T_Auto:CreateToggle({ Name="Auto Cavar (perfecto)", CurrentValue=false, Flag="adig",
    Callback=function(v) autoDig=v end })
T_Auto:CreateToggle({ Name="Teleport al montículo", CurrentValue=true, Flag="tpdig",
    Callback=function(v) tpDig=v end })
task.spawn(function()
    while true do task.wait(0.3)
        if autoDig then
            local _,hrp=hum(); local best,dist=nearestDig(hrp.Position)
            if best then
                if tpDig and dist and dist>12 then hrp.CFrame=CFrame.new(best.Position+Vector3.new(0,4,0)) end
                local p=promptOf(best)
                if p then triggerPrompt(p) else local t=getTool("shovel") or getTool("pala")
                    if t then t:Activate() end end
            end
        end
    end
end)
T_Auto:CreateSection("Pesca / Interacción")
T_Auto:CreateToggle({ Name="Auto Pescar", CurrentValue=false, Flag="afish", Callback=function(v) autoFish=v end })
local autoFish=false
task.spawn(function()
    while true do task.wait(0.5)
        if autoFish then local t=getTool("rod") or getTool("fishing") or getTool("caña")
            if t then t:Activate() end end
    end
end)
T_Auto:CreateSlider({ Name="Radio de interacción", Range={5,200}, Increment=1, Suffix=" studs",
    CurrentValue=30, Callback=function(v) radius=v end })
T_Auto:CreateToggle({ Name="Auto Interactuar", CurrentValue=false, Flag="aprompt",
    Callback=function(v) autoPrompt=v end })
task.spawn(function()
    while true do task.wait(0.35)
        if autoPrompt then
            local _,hrp=hum()
            for _,d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    local part=d.Parent
                    if part and part:IsA("BasePart") and (part.Position-hrp.Position).Magnitude<=radius then
                        triggerPrompt(d)
                    end
                end
            end
        end
    end
end)

--==================== BYPASS ====================
T_Byp:CreateSection("Pala / Prompts")
T_Byp:CreateToggle({ Name="Bypass de Pala (forzar prompts)", CurrentValue=false, Flag="fp",
    Callback=function(v) forcePrompt=v end })
T_Byp:CreateToggle({ Name="Hold Instantáneo", CurrentValue=false, Flag="ih",
    Callback=function(v) instantHold=v end })
task.spawn(function()
    while true do task.wait(1)
        if forcePrompt or instantHold then
            for _,d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    if forcePrompt then d.Enabled=true; d.MaxActivationDistance=1000; d.RequiresLineOfSight=false end
                    if instantHold then d.HoldDuration=0 end
                end
            end
        end
    end
end)
T_Byp:CreateSection("Supervivencia")
T_Byp:CreateSlider({ Name="Gravedad", Range={0,300}, Increment=1, CurrentValue=196,
    Callback=function(v) workspace.Gravity=v end })
T_Byp:CreateToggle({ Name="Anti-Void", CurrentValue=false, Flag="av", Callback=function(v) antiVoid=v end })
task.spawn(function()
    while true do task.wait(0.2)
        if antiVoid then local _,hrp=hum()
            if hrp.Position.Y < -50 then hrp.CFrame=CFrame.new(hrp.Position.X, 200, hrp.Position.Z) end end
    end
end)
T_Byp:CreateToggle({ Name="Anti-AFK", CurrentValue=false, Flag="afk", Callback=function(v) antiAfk=v end })
task.spawn(function()
    while true do task.wait(60)
        if antiAfk then local v=game:GetService("VirtualUser")
            v:CaptureController(); v:ClickButton2(Vector2.new()) end end
end)

--==================== DINERO / REMOTES ====================
local function coinStat()
    local ls=LP:FindFirstChild("leaderstats"); if not ls then return end
    for _,v in ipairs(ls:GetChildren()) do
        local n=v.Name:lower()
        if (n:find("coin") or n:find("cash") or n:find("money") or n:find("dollar") or n:find("gem"))
           and v:IsA("ValueBase") then return v end
    end
end
T_Money:CreateSection("Auto-Dinero")
T_Money:CreateButton({ Name="🔎 Detectar remote de dinero", Callback=function()
    local stat=coinStat()
    local cands={}
    for _,d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local n=d.Name:lower()
            if n:find("sell") or n:find("claim") or n:find("collect") or n:find("reward")
               or n:find("money") or n:find("coin") or n:find("cash") or n:find("give") then
                table.insert(cands,d) end
        end
    end
    if #cands==0 then Rayfield:Notify({Title="Auto-Dinero",Content="Sin candidatos",Duration=5}); return end
    local found
    for _,r in ipairs(cands) do
        local before = stat and stat.Value or 0
        pcall(function() fire(r) end); task.wait(0.45)
        if stat and stat.Value > before then found=r; break end
    end
    if found then moneyRemotePath=found:GetFullName()
        Rayfield:Notify({Title="Auto-Dinero",Content="✅ Detectado: "..found.Name,Duration=7})
    else Rayfield:Notify({Title="Auto-Dinero",Content="Ninguno dio monedas. Usa Logger/Replay.",Duration=7}) end
end })
T_Money:CreateToggle({ Name="💰 AUTO MONEY", CurrentValue=false, Flag="amoney",
    Callback=function(v) autoMoneyOn=v end })
task.spawn(function()
    while true do task.wait(0.15)
        if autoMoneyOn and moneyRemotePath~="" then
            local o=resolvePath(moneyRemotePath)
            if o then pcall(function() fire(o) end) end
        end
    end
end)
T_Money:CreateSection("Descubrir")
T_Money:CreateButton({ Name="Volcar remotes a consola", Callback=function()
    local c=0
    for _,d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then print(d:GetFullName()); c=c+1 end end
    Rayfield:Notify({Title="Remotes",Content=c.." en consola",Duration=5}) end })
local lastRemote, lastArgs
local remoteLog=false
T_Money:CreateToggle({ Name="Logger (captura último remote)", CurrentValue=false, Flag="rlog",
    Callback=function(v) remoteLog=v end })
do
    local ok=pcall(function()
        local mt=getrawmetatable(game); local old=mt.__namecall; setreadonly(mt,false)
        mt.__namecall=newcclosure(function(self,...)
            local m=getnamecallmethod()
            if (m=="FireServer" or m=="InvokeServer") and typeof(self)=="Instance" then
                lastRemote=self; lastArgs={...}
                if remoteLog then
                    local a={...}; local p={}
                    for i=1,math.min(#a,6) do p[i]=tostring(a[i]) end
                    print("[FIRE]",self:GetFullName(),m,table.concat(p," | "))
                end
            end
            return old(self,...)
        end)
        setreadonly(mt,true)
    end)
end
T_Money:CreateSection("Replay")
T_Money:CreateButton({ Name="Repetir último remote x10", Callback=function()
    if not lastRemote then Rayfield:Notify({Title="Replay",Content="Sin remote (usa Logger)",Duration=4}); return end
    for _=1,10 do pcall(function() fire(lastRemote, unpack(lastArgs or {})) end); task.wait(0.05) end
end })
T_Money:CreateButton({ Name="Repetir último remote x100", Callback=function()
    if not lastRemote then Rayfield:Notify({Title="Replay",Content="Sin remote (usa Logger)",Duration=4}); return end
    for _=1,100 do pcall(function() fire(lastRemote, unpack(lastArgs or {})) end); task.wait(0.05) end
end })
T_Money:CreateSection("Códigos")
local CODES={"GOGRINDNESSIENEW","NESSIEISHERE","UPDATE05","SORRYFORDELAY","UICHANGES"}
T_Money:CreateButton({ Name="Canjear códigos activos", Callback=function()
    local remote
    for _,d in ipairs(RS:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
            local n=d.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("promo") then remote=d break end
        end
    end
    if not remote then Rayfield:Notify({Title="Códigos",Content="Sin remote de códigos",Duration=5}); return end
    for _,c in ipairs(CODES) do pcall(function() fire(remote,c) end); task.wait(0.3) end
    Rayfield:Notify({Title="Códigos",Content="Canjeados en "..remote.Name,Duration=6})
end })

--==================== JUGADOR ====================
T_Plr:CreateSection("Personaje")
T_Plr:CreateButton({ Name="Reset", Callback=function() local c=LP.Character; if c then c:BreakJoints() end end })
T_Plr:CreateButton({ Name="Invisible (toggle)", Callback=function()
    local c=LP.Character; if c then
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Transparency = p.Transparency==1 and 0 or 1 end end end end })
T_Plr:CreateButton({ Name="Ver stats (consola)", Callback=function()
    local ls=LP:FindFirstChild("leaderstats")
    if ls then for _,v in ipairs(ls:GetChildren()) do print("STAT:",v.Name,"=",v.Value) end end
    Rayfield:Notify({Title="Stats",Content="En consola",Duration=4}) end })

--==================== EXTRAS ====================
T_Extra:CreateSection("Consola Lua")
T_Extra:CreateInput({ Name="Ejecutar Lua", PlaceholderText="print('hola')",
    RemoveTextAfterFocusLost=false, Callback=function(t)
        local f=loadstring(t)
        if f then local ok,err=pcall(f); print(ok and "[OK]" or ("[ERR] "..tostring(err))) end
    end })

Rayfield:Notify({Title="🦖 PF Hub v3.1",Content="Cargado",Duration=5})
