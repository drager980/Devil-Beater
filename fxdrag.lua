local player = game.Players.LocalPlayer
local damage = player and require(workspace.Lobby.DamageModule) or require(game.ServerStorage.DamageModule) 
local infinity
local debounces = {}
local dictionary = {
                [-1] = {30,1},
                [1] = {1,0},
        }

local fx = {}
fx.Slow = function(target)
	if math.random(5) == 1 and target.Parent and target.Parent:FindFirstChild("Humanoid") then
		game.ReplicatedStorage.stun:FireServer("Slow",target)
	end
end
fx.Rope = function(ropeto,roped,duration) -- parts, not attachment
	game.ReplicatedStorage.UpdateData:FireServer("Rope",ropeto,roped,duration)
	print("You're a sap!")
end
fx.Stun = function(target,duration)
	if target.Parent and target.Parent:FindFirstChild("Torso") then
		game.ReplicatedStorage.stun:FireServer(duration,target.Parent.Torso)
	end
end

fx.GetFlame = function(flame,division)
	local flames = {
		["Aether"]  = Color3.new(236/255, 139/255, 70/255),
		["Sky"]     = Color3.new(236/255, 139/255, 70/255),
		
		["Agni"]    = Color3.new(0.9,0,0),
		["Storm"]   = Color3.new(0.9,0,0),
		["Strom"]   = Color3.new(0.9,0,0),
		
		["Rain"]    = Color3.new(0, 170/255, 255/255),
		["Flux"]    = Color3.new(0, 170/255, 255/255),
		
		["Helios"]  = BrickColor.new("Bright yellow").Color,
		["Sun"]     = BrickColor.new("Bright yellow").Color,
		
		["Stratus"] = BrickColor.new("Royal purple").Color,
		["Cloud"]   = BrickColor.new("Royal purple").Color,
		
		["Haze"]    = Color3.new(130/255, 60/255, 190/255),
		["Mist"]    = Color3.new(130/255, 60/255, 190/255),
		
		["Lightning"] = Color3.new(85/255, 255/255, 127/255),
		["Narukami"]  = Color3.new(85/255, 255/255, 127/255),
	}
	if division then
		local f = flames[flame]
		return Color3.new(f.r/division,f.g/division,f.b/division)
	end
	return flames[flame]
end
fx.RemoveFlavor = function(toloop,mesh)
	for _,part in pairs(toloop:GetChildren()) do
		if part:IsA("SpecialMesh") and mesh then
			part.TextureId = ""
		elseif not part:IsA("CylinderMesh") then
			part:Destroy()
		end
	end
end

local function GhostPart(Part,color,transparency,consistency,mesh)
	local Ghost = Part:Clone()
	Ghost.Parent = workspace
	Ghost.BrickColor = BrickColor.new(color)
	Ghost.CanCollide = false
	Ghost.Anchored = true
	Ghost.Transparency = transparency or 0.5
	Ghost.Material = Enum.Material.Neon
	fx.RemoveFlavor(Ghost,mesh)
	game.Debris:AddItem(Ghost,consistency*10)
end
fx.Ghost = function(Part,Color,Transparency,Duration,Mesh)
	local Duration = Duration/30
	local Color = Color or Color3.new(1,1,1)
	GhostPart(Part,Color,Transparency,Duration,Mesh)
end

fx.GFY = function(character) -- gfyca-- ghostify character models.
	local ghosting = {}
	for i,v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(ghosting, v)
		elseif v:FindFirstChild("Handle") and v.Handle:IsA("BasePart") then
			table.insert(ghosting, v.Handle)
		end
	end
	return ghosting
end

fx.HitBox = function(part)
	local hitbox = part:Clone()
	hitbox.Parent = part.Parent
	hitbox.Transparency = 1
	hitbox.Anchored = false
	hitbox:ClearAllChildren()
	spawn(function()
		while part do
			hitbox.CFrame = part.CFrame
			wait()
		end
		hitbox:Destroy()
	end)
	return hitbox
end

fx.CellShade = function(part, duration, reach, transparency) -- (reach) is how far out the cell effect is
	local reach = reach and 1 + reach/10 or 1.2
	local cell = part:Clone()
	cell.BrickColor = BrickColor.Black()
	cell.Parent = part.Parent
	cell.Anchored = false
	cell.CanCollide = false
	if cell:FindFirstChild("Mesh") then
		local mesh = cell.Mesh
		mesh.TextureId = false
		mesh.Scale = mesh.Scale * reach
	else
		cell.Size = cell.Size * reach
	end
	if duration then game.Debris:AddItem(cell,duration) end
	local test = Instance.new("Weld",cell)
	test.Part0 = cell
	test.Part1 = part
	spawn(function()
		while part.Parent==cell.Parent do
			cell.Transparency = transparency or (part.Transparency + 0.2)
--			cell.CFrame = part.CFrame
			wait()
		end
		cell:Destroy()
	end)
	return cell
end

fx.Cell = function(adornee,color,thickness,transparency)
	local box = Instance.new("SelectionBox",adornee)
	box.Adornee = adornee
	box.Color3 = color or Color3.new(0,0,0)
	box.LineThickness = thickness or 0.1
	box.Transparency = transparency or 0
end

fx.Ghoster = function(follow,color,duration,consistency,transparency,mesh)
	for i=1,duration*30 do
		if i%math.floor(consistency*30) == 0 then
			if type(follow) == "table" then
				for _,part in pairs(follow) do
					GhostPart(part,color,transparency,consistency,mesh or false)
				end
			else
				GhostPart(follow,color,transparency,consistency,mesh or false)
			end
		end
		wait()
	end
end

fx.GroundBlast = function(parts,size,duration,rest) -- table, number, number, boolean, table{damage,cooldown,lifesteal,knockback}
	local duration = duration or 1
	local partspin = {}
	local ReturnPart = false
	if type(parts)=="userdata" then parts = {parts.Position} end
	for _,position in pairs(parts) do
		for i=1,2 do
			local Part = Instance.new("Part",workspace)
			Part.Material = Enum.Material.Neon -- the most importantest value!!!1
			Part.Anchored = true
			Part.CanCollide = false
			Part.Size = Vector3.new(3,3,3)*size
			Part.CFrame = CFrame.new(position)
			Part.Transparency = 1
			game.Debris:AddItem(Part,duration)
			table.insert(partspin,Part)
		end
	end
	if rest then
		local Part = Instance.new("Part",workspace)
		Part.Material = Enum.Material.Neon -- the most importantest value!!!1
		Part.Anchored = true
		Part.CanCollide = false
		Part.Size = Vector3.new(3,3,3)*size
		Part.CFrame = CFrame.new(parts[1])
		Part.Transparency = 1
		Part.Touched:connect(function(hit) damage(Part,hit,rest[1],rest[2],player,rest[3],rest[4]) end)
		game.Debris:AddItem(Part,duration)
	end
	for i=1,15 do -- messy ;-;
		for i=1,#partspin do
			partspin[i].Transparency = partspin[i].Transparency - (1/15)
			partspin[i].CFrame = partspin[i].CFrame * CFrame.Angles(math.rad(math.random(25)),math.rad(math.random(25)),math.rad(math.random(25)))
		end
		wait()
	end
	local length = (duration*30-15)
	for i=1,length do
		for i=1,#partspin do
			partspin[i].Transparency = partspin[i].Transparency + (1/length)
		end
		wait()
	end
end

fx.Emitter = function(p,part,...)
	local args = ...
	local particle = part:Clone()
	particle.Parent = p 
	if args then
		for i,v in pairs(args) do
			particle[i] = v
		end
	end
	return particle
end


fx.Particle = function(p,part,size,rate)
	local x = part:Clone()
	x.Parent = p 
	x.Size = size and NumberSequence.new(p.Size.x/3.5) or x.Size
	x.Rate = rate or 100
	return x
end

fx.Projectile = function(arguments,duration)
	local p = Instance.new("Part", workspace)
	p.Size = Vector3.new(1,1,1)
	p.CanCollide = false
	p.Anchored = false
	p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	p.Transparency = 0
	for i,v in pairs(arguments) do
		p[i] = v
	end
	if duration ~= true then
		game.Debris:AddItem(p,duration or 5)
	end
	return p
end

fx.Mesh = function(part,meshid,texture)
	local mesh     = Instance.new("SpecialMesh",part)
	mesh.MeshId    = "http://www.roblox.com/asset/?id=".. (meshid or 0)
	if texture then
		mesh.TextureId = "http://www.roblox.com/asset/?id=".. (texture or 0)
	end
	return mesh
end

fx.Crash = function(part,count,duration,offset,fade)
    local fade = fade or 1/(duration*30)
    local f = Instance.new("Folder",player.Character)
    local detaches = {}
    game.Debris:AddItem(f,duration*1.05)
	for i=1,count do
        local p = fx.Projectile({
			Parent = f,
			BrickColor = part.BrickColor, 
			Size = part.Size*0.3, 
			Anchored = true, 
			Transparency = 0.5 + (part.Transparency/2)
		})
        detaches[p] = {CFrame.Angles(math.rad(math.random(180)),math.rad(math.random(180)),math.rad(math.random(180))),Vector3.new(math.random(-part.Size.x,part.Size.x),offset and (part.Size.y/2)+(p.Size.y/2) or 0,math.random(-part.Size.z,part.Size.z))/2}
	end
    local coco = f:GetChildren()
	local hide = 1 - (0.5 + part.Transparency/2)
    for dragerwasherebby=1,duration*30 do
        for i=1,count do
            coco[i].CFrame = part.CFrame*detaches[coco[i]][1] - detaches[coco[i]][2]
            coco[i].Transparency = coco[i].Transparency + hide*fade
        end
        wait()
    end
end

fx.Velocity = function(part,direction,duration)
    local v = Instance.new("BodyVelocity",part)
	v.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    v.Velocity = direction
    if duration then game.Debris:AddItem(v,duration) end
    return v
end

fx.AngularVelocity = function(part,direction)
    local v = Instance.new("BodyAngularVelocity",part)
	v.MaxTorque = Vector3.new(9999,9999,9999)
    v.AngularVelocity = direction or Vector3.new(10,10,10)
    return v
end

fx.AutoTarget = function(range, overwrite)
	local player = game.Players.LocalPlayer
	local character = player.Character
	local torso = overwrite or character.Torso
	local m = {range,false}
	local p = game.Players:GetPlayers()
	local evil = workspace.Opponents:GetChildren()
	if workspace:FindFirstChild("CurrentMap") and #p<=2 then 
		local map = workspace.CurrentMap:GetChildren()[1]
		print("Aye",map.Name)
		if map:FindFirstChild("Dummies") then
			print("Get 'em on board, I'll call it in.")
			evil = map.Dummies:GetChildren() 
			for i,v in pairs(evil) do print(i,v) end
		end
	end
	for i=1,#p do
		if p[i] ~= player and p[i].Character:FindFirstChild("Torso") and (p[i].Character:FindFirstChild("ForceField") == nil) and p[i].Character.Humanoid.Health > 0 and (torso.Position - p[i].Character.Torso.Position).magnitude < m[1] and ((p[i].TeamColor ~= player.TeamColor) or (player.Neutral or p[i].Neutral)) then
			m = {(torso.Position - p[i].Character.Torso.Position).magnitude,p[i].Character}
		end
	end
	for i=1,#evil do
		if evil[i]:FindFirstChild("Torso") and (torso.Position - evil[i].Torso.Position).magnitude < m[1] and (evil[i].Humanoid.Health > 0 or evil[i].Humanoid.MaxHealth==0) then
			m = {(torso.Position - evil[i].Torso.Position).magnitude,evil[i]}
		end
	end
	if m[2] and m[2]:FindFirstChild("Torso") then
		return m[2]
	end
	return false
end

fx.Square = function(size,color,pos,fxcount)
	local fxcount = fxcount or 3
	local square = fx.Projectile({Size = Vector3.new(size,size,size), BrickColor = BrickColor.new(color), Material = Enum.Material.Neon, Transparency = 0.5, Anchored = true}, 5)
	square.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(math.random()*360),math.rad(math.random()*360),math.rad(math.random()*360))
	--if size < 5 then
		for i=1, fxcount do
			local square = fx.Projectile({Size = Vector3.new(size/10,size/10,size/10), BrickColor = BrickColor.new(color), Material = Enum.Material.Neon, Transparency = 0.8, Anchored = true}, 5)
			square.CFrame = CFrame.new(pos + Vector3.new(math.random(size*2)-size,math.random(size*2)-size,math.random(size*2)-size)) * CFrame.Angles(math.rad(math.random()*360),math.rad(math.random()*360),math.rad(math.random()*360))
		end
	--end
	return square
end

fx.SquareSlash = function(start,direction,color,count,basesize,delayt,fxcount,tight)
	local count = count or 5
	local delayt = delayt or 1/15
	local basesize = basesize or 3 	
	local direction = direction or Vector3.new(0,0,0)
	if not start then return false end
	local obj = pcall(function() return start.Position and true end)
	local color = color or Color3.new(1,1,1)
	--local tight = tight or basesize<3
	if tight then
		for i=1,count/2,0.5 do
			local size = basesize * i
			local square = fx.Square(size,color,(obj and start.Position or start) + direction*(size*1.5),fxcount or size*2)
			wait(delayt)
		end
	else
		for i=1,count do
			local size = basesize * i
			local square = fx.Square(size,color,(obj and start.Position or start) + direction*(i^math.sqrt(count)),fxcount or size*2)
			wait(delayt)
		end
	end
end


fx.GyroShot = function(base,color,duration,reach,mesh,attack,fade)
	local color = color or Color3.new(1,1,1)
	local duration = duration or 1
	local reach = reach or 1
	local mesh = mesh or 3270017
	local part = fx.Projectile({BrickColor = BrickColor.new(color), Transparency = 0.5, Anchored = true}, duration + 0.5)
	local mesh = fx.Mesh(part,mesh)
	if attack then
		part.Touched:connect(function(hit)
			damage(part,hit,attack.Damage or 10,attack.Cooldown or 2,player,attack.Healing,attack.Knockback)
		end)
	end
	part.CFrame = CFrame.new(base.Position) * CFrame.Angles(math.rad(math.random()*360),math.rad(math.random()*360),math.rad(math.random()*360))
	for i=1,duration * 30 do
		local cframe = part.CFrame
		part.Size = part.Size + Vector3.new(1,1,1)*reach
		part.Transparency = part.Transparency + (fade and fade/60 or 1/60)
		mesh.Scale = part.Size
		part.CFrame = cframe
		wait()
	end
end

local dt = wait()
fx.Shatter = function(pos, color, large) -- Vector3, bool
	spawn(function()
		local vels = {}
		local rvels = {}
		local parts = {}
		for i=1,large and 20 or 5 do
			local delta = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit
			local pellet = Instance.new("Part")
			pellet.BrickColor = BrickColor.new(color)
			pellet.Size = Vector3.new(math.random()*1.5,math.random()*1.5,math.random()*1.5)
			pellet.CFrame = CFrame.new(pos + delta * 2, pos - delta)
			pellet.RotVelocity = delta * 20
			pellet.Velocity = Vector3.new(0, 40, 0) + delta * math.random(10, 20) --delta * 10 + 
			pellet.CanCollide = false
			pellet.Anchored = true
			pellet.Transparency = 0.25
			pellet.TopSurface = "Smooth"
			pellet.BottomSurface = "Smooth"
			pellet.Material = "Neon"
			pellet.Parent = workspace
			table.insert(parts, pellet)
			table.insert(rvels, (Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))).unit * (math.random(1,10) * 0.9))
			table.insert(vels, Vector3.new(0, 10, 0) + delta * math.random(10, 20))
			--[[local rx, ry, rz = math.rad(pellet.Velocity.x), math.rad(pellet.Velocity.y), math.rad(pellet.Velocity.z)
			local drot = CFrame.Angles(rx, ry, rz) 
			local dv = CFrame.new(pellet.Velocity*0.001)--]]
			game:GetService("Debris"):AddItem(pellet, 1)
		end
		for i=-.25,1,dt do
			for j=1,#parts do
				local vel = vels[j]
				local rvel = rvels[j]
				local part = parts[j]
				local dy =  (i*i) - ( (i+dt)*(i+dt) )
				part.CFrame = CFrame.new(part.Position + (vel * dt) + Vector3.new(0, dy * 120, 0), part.Position + part.CFrame.lookVector + (rvel * dt) )
				--pellet.CFrame = pellet.CFrame * drot * dv
				--dv = dv - Vector3.new(0, 21, 0)
				part.Transparency = part.Transparency + .75*.03
			end
			wait()
		end
	end)
end

fx.Sound = function(id, loc, volume, pitch, fadeout, fadein)
    local song = "http://www.roblox.com/asset/?id="..id
    game:GetService("ContentProvider"):Preload(song)
    local sound = Instance.new("Sound",loc)
    sound.SoundId = song
    sound.Volume = volume or 1
	if fadein then
		sound.Volume = 0
		spawn(function()
			local duration = fadein*15 
			for i=1,duration do
				sound.Volume = sound.Volume + volume/duration
				wait()
			end
		end)
	end
	sound.Pitch = pitch or 1
    sound:Play()
    game.Debris:AddItem(sound,fadeout or sound.TimeLength)
	if fadeout then
		spawn(function()
			local duration = 15
			wait(fadeout - duration/30) 
			for i=1,duration do
				sound.Volume = sound.Volume - volume/duration
				wait()
			end
		end)
	end
	return sound
end

fx.Orb = function(part,color,...) -- (part,flame,{args})
	local oArgs = ... or {}
	local reach = oArgs.Reach or 1
	local duration = oArgs.Duration or 1
	local addon = oArgs.Special
    local p = Instance.new("Part",workspace)
    game.Debris:AddItem(p,duration)
	if oArgs.Prefix then
		oArgs.Prefix(p)
	end
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(1,1,1)
    p.Transparency = 0
    p.Anchored = true
    p.CanCollide = false
    p.BrickColor = BrickColor.new(color)
    p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
 	if oArgs.Damage then
		local hitbox = fx.HitBox(p)
		if type(oArgs.Damage) == "table" then
			hitbox.Touched:connect(function(hit)
				local h = game.Players:GetPlayerFromCharacter(hit.Parent)
				if not p:FindFirstChild(hit.Parent.Name) and h and not hit.Parent:FindFirstChild("Enemy") then
					local d = Instance.new("Folder",p)
					d.Name = hit.Parent.Name
					hit.Parent.Humanoid:TakeDamage(oArgs.Damage[1] * 1.5)
					oArgs.AttackBonus(hit)
					if oArgs.Knockback then
						local v = Instance.new("BodyVelocity",hit.Parent.Torso)
						v.maxForce = Vector3.new(math.huge,0,math.huge)
						v.velocity = CFrame.new(p.Position,hit.Parent.Torso.Position).lookVector*oArgs.Knockback
					end
					game.Debris:AddItem(d,oArgs.Cooldown or duration)
				end
	        end)
		else
			hitbox.Touched:connect(function(hit)
	        	if damage(p,hit,oArgs.Damage,oArgs.Cooldown or duration,player,oArgs.Healing,oArgs.Knockback) and oArgs.AttackBonus then
					oArgs.AttackBonus(hit)
				end
	        end)
		end
    end
	local rings
	local startpoint = math.random(360)
	local offset = math.random(90,180)
	local speed = math.random(4)
	if oArgs.Rings then
		rings = {}
		for i=1,oArgs.Rings do
			local ring = fx.Projectile({BrickColor = BrickColor.new(color), Anchored = true, CanCollide = false})
			ring.CFrame = part.CFrame
			fx.Mesh(ring,3270017)
			game.Debris:AddItem(ring,duration)
			table.insert(rings,ring)
		end
	end
	local mesh = oArgs.Mesh and fx.Mesh(p,oArgs.Mesh)
	local expansion = oArgs.Expansion or Vector3.new(1,1,1)
    local l = Instance.new("PointLight",p)
    l.Color = color
    l.Brightness = 2
    l.Range = 1
    for i=1,duration*30 do
        p.Size = p.Size + expansion*(reach)
        p.Transparency = p.Transparency + (1/(duration*30))
        l.Range = p.Size.x
        p.CFrame = part.CFrame
		if mesh then mesh.Scale = p.Size end
		if rings then
			for ii=1,#rings do
				local ring = rings[ii]
				local rotation = math.rad(startpoint + i*speed + ii*offset)
				if ring:FindFirstChild("Mesh") then
					ring.Mesh.Scale = p.Size * (1.1 + ii/5) * Vector3.new(1,1,0.5)
				end
				ring.Transparency = ring.Transparency + (1/(duration*30))
				ring.CFrame = part.CFrame * CFrame.Angles(rotation,rotation,rotation)
			end
		end
		if addon then addon(p) end
        wait()
    end
end
fx.CameraShake = function(humanoid,duration)
	for i=1,duration*30-10 do
		humanoid.CameraOffset = Vector3.new(math.random(-1,1)/4,math.random(-1,1)/4, 0)
		--workspace.CurrentCamera.FieldOfView = math.random(65,75)
		wait()
	end
	for i=1,duration*8+10 do
		humanoid.CameraOffset = Vector3.new(math.random(-1,1)/(4+i/2),math.random(-1,1)/(4+i/2), 0)
		--workspace.CurrentCamera.FieldOfView = math.random(65,75)
		wait()
	end
	humanoid.CameraOffset = Vector3.new(0,0, 0)
	--workspace.CurrentCamera.FieldOfView = 70
end

fx.Pillar = function(part,color,...) -- (part,flame,{args})
	local oArgs = ...
	local addon = oArgs.Special
	local polarity = oArgs.Polarity or 1
	local duration = oArgs.Duration or 1
	local reach = (oArgs.Reach or 1) * polarity
    local p = Instance.new("Part",workspace)
    game.Debris:AddItem(p,duration)
    if oArgs.Damage then
		if type(oArgs.Damage) == "table" then
			p.Touched:connect(function(hit)
				local h = game.Players:GetPlayerFromCharacter(hit.Parent)
				if not p:FindFirstChild(hit.Parent.Name) and h and not hit.Parent:FindFirstChild("Enemy") then
					local d = Instance.new("Folder",p)
					d.Name = hit.Parent.Name
					hit.Parent.Humanoid:TakeDamage(oArgs.Damage[1] * 1.5)
					oArgs.AttackBonus(hit)
					if oArgs.Knockback then
						local v = Instance.new("BodyVelocity",hit.Parent.Torso)
						v.maxForce = Vector3.new(math.huge,0,math.huge)
						v.velocity = CFrame.new(p.Position,hit.Parent.Torso.Position).lookVector*oArgs.Knockback
					end
					game.Debris:AddItem(d,oArgs.Cooldown or duration)
				end
	        end)
		else
			p.Touched:connect(function(hit)
	        	if damage(p,hit,oArgs.Damage,oArgs.Cooldown or duration,player,oArgs.Healing,oArgs.Knockback) and oArgs.AttackBonus then
					oArgs.AttackBonus(hit)
				end
	        end)
		end
    end
    p.Size = polarity<0 and Vector3.new(duration*30 + 4,duration*90,duration*30 + 4) or Vector3.new(5*reach,1,5*reach) 
    p.Transparency = 0.5 - reach/2
    p.Anchored = true
    p.CanCollide = false
    p.BrickColor = BrickColor.new(color)
    p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	if oArgs.Rounded then Instance.new("CylinderMesh",p) end
	if oArgs.Cell then fx.Cell(p) end
    local l = Instance.new("PointLight",p)
    l.Color = color
    l.Brightness = 2
    l.Range = 1
    for i=1,duration*30 do
        p.Size = p.Size + Vector3.new(1,3,1)*(reach)
        p.Transparency = p.Transparency + (1/(duration*30*polarity))
        l.Range = p.Size.x
        p.CFrame = part.CFrame
		if addon then addon(p) end
        wait()
    end
end


fx.Pulse = function(part,duration,reach,color,dmg,cooldown)
	local reach = reach or 3
	local cooldown = cooldown or duration * 1.25
    local p = Instance.new("Part",workspace)
    game.Debris:AddItem(p,duration)
    if dmg then
        p.Touched:connect(function(hit)
        	damage(p,hit,dmg,cooldown,player,-2)
        end)
    end
    p.Shape = "Ball"
    p.Size = Vector3.new(1,1,1)
    p.Transparency = 0
    p.Anchored = true
    p.CanCollide = false
    p.BrickColor = BrickColor.new(color)
    p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    local l = Instance.new("PointLight",p)
    l.Color = color
    l.Brightness = 2
    l.Range = 1
    for i=1,duration*30 do
        p.Size = p.Size + Vector3.new(1,1,1)*(reach)
        p.Transparency = p.Transparency + (1/(duration*30))
        l.Range = p.Size.x
        p.CFrame = part.CFrame
        wait()
    end
end

fx.PulseWave = function(part, color, ...)
	local oArgs = ... or {}
	local reach = oArgs.Reach or 1
	local duration = oArgs.Duration or 1
	local addon = oArgs.Special
    local p = Instance.new("Part",workspace)
    game.Debris:AddItem(p,duration)
    if oArgs.Damage then
		if type(oArgs.Damage) == "table" then
			p.Touched:connect(function(hit)
				local h = game.Players:GetPlayerFromCharacter(hit.Parent)
				if not p:FindFirstChild(hit.Parent.Name) and h and not hit.Parent:FindFirstChild("Enemy") then
					local d = Instance.new("Folder",p)
					d.Name = hit.Parent.Name
					hit.Parent.Humanoid:TakeDamage(oArgs.Damage[1] * 1.5)
					oArgs.AttackBonus(hit)
					if oArgs.Knockback then
						local v = Instance.new("BodyVelocity",hit.Parent.Torso)
						v.maxForce = Vector3.new(math.huge,0,math.huge)
						v.velocity = CFrame.new(p.Position,hit.Parent.Torso.Position).lookVector*oArgs.Knockback
					end
					game.Debris:AddItem(d,oArgs.Cooldown or duration)
				end
	        end)
		else
			p.Touched:connect(function(hit)
	        	if damage(p,hit,oArgs.Damage,oArgs.Cooldown or duration,player,oArgs.Healing,oArgs.Knockback) and oArgs.AttackBonus then
					oArgs.AttackBonus(hit)
				end
	        end)
		end
    end
	if oArgs.Prefix then
		oArgs.Prefix(p)
	end
	p.Size = Vector3.new(1,2,1)
    p.Transparency = 0
    p.Anchored = true
    p.CanCollide = false
    p.BrickColor =  BrickColor.new(color)
    p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    Instance.new("CylinderMesh",p).Scale = Vector3.new(1,0.05,1)
    local l = Instance.new("PointLight",p)
    l.Color = color
    l.Brightness = 2
    l.Range = 1
    for i=1,duration*30 do
        p.Size = p.Size + Vector3.new(1,0,1)*reach
        p.Transparency = p.Transparency + (1/(duration*30))
        l.Range = p.Size.x
        p.CFrame = part.CFrame - Vector3.new(0,.6,0)
        wait()
    end
    for i=1,30 do
        p.Transparency = p.Transparency + (1/30)
        p.CFrame = part.CFrame - Vector3.new(0,.6,0)
        wait()
    end
end

fx.Wave = function(part,duration,reach,color,dmg,cooldown)
    local p = Instance.new("Part",workspace)
    local cooldown = cooldown or 0
    local tooldown = cooldown<10 and cooldown or 0
    game.Debris:AddItem(p,duration+tooldown)
    if dmg then
        p.Touched:connect(function(hit)
        	damage(p,hit,dmg,cooldown,player,-3)
        end)
    end
    p.Size = Vector3.new(1,2,1)
    p.Transparency = 0
    p.Anchored = true
    p.CanCollide = false
    p.BrickColor =  BrickColor.new(color)
    p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
    Instance.new("CylinderMesh",p).Scale = Vector3.new(1,0.1,1)
    local l = Instance.new("PointLight",p)
    l.Color = color
    l.Brightness = 2
    l.Range = 1
    for i=1,duration*30 do
        p.Size = p.Size + Vector3.new(1,0,1)*reach
        p.Transparency = p.Transparency + (1/(duration*(tooldown>0 and 60 or 30)))
        l.Range = p.Size.x
        p.CFrame = part.CFrame - Vector3.new(0,.6,0)
        wait()
    end
    for i=1,tooldown*30 do
        p.Transparency = p.Transparency + (1/(tooldown*30))
        p.CFrame = part.CFrame - Vector3.new(0,.6,0)
        wait()
    end
end

return fx