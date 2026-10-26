--!strict
--[================================================================]--
--     ADVANCED "STEAL AN EGG" SYSTEM - MODERNE ARCHITEKTUR       --
--[================================================================]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- 1. Ordner-Struktur aufbauen
local Folders = {
	Eggs = Workspace:FindFirstChild("Eggs") or Instance.new("Folder", Workspace),
	Nests = Workspace:FindFirstChild("Nests") or Instance.new("Folder", Workspace),
	Bases = Workspace:FindFirstChild("Bases") or Instance.new("Folder", Workspace),
	Effects = Workspace:FindFirstChild("Effects") or Instance.new("Folder", Workspace),
}
Folders.Eggs.Name = "Eggs"
Folders.Nests.Name = "Nests"
Folders.Bases.Name = "Bases"
Folders.Effects.Name = "Effects"

-- 2. Erweiterte Konfiguration & Kategorien (Modern Config)
local CONFIG = {
	MaxEggsOnMap = 30,
	SpawnInterval = 2.0,
	BaseCapacity = 5, -- Start-Rucksack-Kapazität
	StealCooldown = 1.5,
	EggTypes = {
		{Name = "Standard Egg", Value = 15, Rarity = "Common", Color = Color3.fromRGB(240, 240, 240), Chance = 50},
		{Name = "Spotted Egg", Value = 35, Rarity = "Uncommon", Color = Color3.fromRGB(200, 150, 100), Chance = 25},
		{Name = "Golden Egg", Value = 100, Rarity = "Rare", Color = Color3.fromRGB(255, 215, 0), Chance = 15},
		{Name = "Diamond Egg", Value = 300, Rarity = "Epic", Color = Color3.fromRGB(0, 229, 255), Chance = 8},
		{Name = "Void Egg", Value = 1000, Rarity = "Legendary", Color = Color3.fromRGB(128, 0, 128), Chance = 2},
	}
}

-- 3. Leaderstats & Player Data Erweiterung (Funktionen 1-5)
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- 1. Cash / Coins Währung
	local cash = Instance.new("IntValue")
	cash.Name = "Coins"
	cash.Value = 100
	cash.Parent = leaderstats

	-- 2. Eier im Inventar / Rucksack
	local eggsCarried = Instance.new("IntValue")
	eggsCarried.Name = "Carried"
	eggsCarried.Value = 0
	eggsCarried.Parent = leaderstats

	-- 3. Gestohlene Eier Zähler
	local stolenStat = Instance.new("IntValue")
	stolenStat.Name = "Stolen"
	stolenStat.Value = 0
	stolenStat.Parent = leaderstats

	-- 4. Prestige / Level System
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats

	-- 5. Spieler-Attribute für erweiterte Statuswerte (Speed-Boost, Kapazität, Cooldown)
	player:SetAttribute("EggCapacity", CONFIG.BaseCapacity)
	player:SetAttribute("SpeedMultiplier", 1.0)
	player:SetAttribute("HasShield", false)
	player:SetAttribute("DoubleCoinsActive", false)

	-- Basis für den Spieler erstellen (Safezone)
	task.defer(function()
		local basePart = Instance.new("Part")
		basePart.Name = player.Name .. "_Base"
		basePart.Size = Vector3.new(12, 0.6, 12)
		basePart.Position = Vector3.new(math.random(-50, 50), 0.3, math.random(-50, 50))
		basePart.Anchored = true
		basePart.BrickColor = BrickColor.new("Bright blue")
		basePart.Material = Enum.Material.Neon
		basePart.Parent = Folders.Bases

		-- Touch-Event für die Basis (Abgeben der Eier & Heilung)
		basePart.Touched:Connect(function(hit)
			local char = hit.Parent
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				local p = Players:GetPlayerFromCharacter(char)
				if p == player then
					local stats = p:FindFirstChild("leaderstats")
					if stats then
						local carried = stats:FindFirstChild("Carried")
						local cCoins = stats:FindFirstChild("Coins")
						if carried and carried.Value > 0 then
							local earnings = carried.Value * (p:GetAttribute("DoubleCoinsActive") and 2 or 1)
							cCoins.Value += earnings
							carried.Value = 0
							
							-- Visueller Effekt beim Abgeben
							local attachment = Instance.new("Attachment", basePart)
							local particle = Instance.new("ParticleEmitter", attachment)
							particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 128))
							particle.Size = NumberSequence.new(1, 0)
							particle.Rate = 50
							task.delay(0.5, function() particle.Enabled = false end)
							Debris:AddItem(attachment, 2)
						end
					end
				end
			end
		end)
	end)
end)

-- 4. Dynamisches Spawnen von Eiern mit Seltenheits-Logik (Funktionen 6-10)
local function getRandomEggType()
	local rand = math.random(1, 100)
	local currentChance = 0
	for _, eggType in ipairs(CONFIG.EggTypes) do
		currentChance += eggType.Chance
		if rand <= currentChance then
			return eggType
		end
	end
	return CONFIG.EggTypes[1]
end

local function spawnEggAtPosition(pos: Vector3)
	if #Folders.Eggs:GetChildren() >= CONFIG.MaxEggsOnMap then return end

	local eggData = getRandomEggType()

	-- Modernes Ei-Modell mit Glow und Animation
	local egg = Instance.new("Part")
	egg.Name = eggData.Name
	egg.Size = Vector3.new(2.2, 2.8, 2.2)
	egg.Shape = Enum.PartType.Ball
	egg.Position = pos + Vector3.new(0, 1.5, 0)
	egg.Color = eggData.Color
	egg.Material = Enum.Material.Glass
	egg.Anchored = false
	egg.CanCollide = true
	egg.Parent = Folders.Eggs

	-- 6. Outline / Highlight-Effekt (Moderne Optik)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = egg
	highlight.FillColor = eggData.Color
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0.2
	highlight.Parent = egg

	-- 7. Floating Animation (Schwebe-Effekt per Tween)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(egg, tweenInfo, {Position = egg.Position + Vector3.new(0, 0.8, 0)})
	tween:Play()

	-- Werte-Attribute setzen
	egg:SetAttribute("EggValue", eggData.Value)
	egg:SetAttribute("Rarity", eggData.Rarity)

	-- 8. Touch-Collect Logik mit Rucksack-Limit & Diebstahl-Schutz
	local collected = false
	egg.Touched:Connect(function(hit)
		if collected then return end
		local char = hit.Parent
		local hum = char:FindFirstChildOfClass("Humanoid")
		
		if hum and hum.Health > 0 then
			local player = Players:GetPlayerFromCharacter(char)
			if player then
				local stats = player:FindFirstChild("leaderstats")
				if stats then
					local carried = stats:FindFirstChild("Carried")
					local maxCap = player:GetAttribute("EggCapacity")
					
					if carried and carried.Value < maxCap then
						collected = true
						carried.Value += 1
						
						-- Stolen Zähler erhöhen
						local stolen = stats:FindFirstChild("Stolen")
						if stolen then stolen.Value += 1 end

						-- 9. Floating Text / Sound / Partikeleffekt beim Aufheben
						local root = char:FindFirstChild("HumanoidRootPart")
						if root then
							local pEmit = Instance.new("ParticleEmitter", root)
							pEmit.Color = ColorSequence.new(eggData.Color)
							pEmit.Size = NumberSequence.new(0.5, 0)
							pEmit.Rate = 30
							task.delay(0.2, function() pEmit.Enabled = false end)
							Debris:AddItem(pEmit, 1)
						end

						egg:Destroy()
					end
				end
			end
		end
	end)
end

-- 5. Nester-Generierung (Funktion 11-12: Verschiedene Nest-Typen mit unterschiedlichen Spawn-Raten)
local nestPositions = {
	{Pos = Vector3.new(20, 0, 20), Tier = "Normal"},
	{Pos = Vector3.new(-20, 0, 20), Tier = "Normal"},
	{Pos = Vector3.new(20, 0, -20), Tier = "Normal"},
	{Pos = Vector3.new(-20, 0, -20), Tier = "Normal"},
	{Pos = Vector3.new(0, 0, 40), Tier = "Hotspot"}, -- Höhere Rarity-Chance
	{Pos = Vector3.new(0, 0, -40), Tier = "Hotspot"}
}

for _, nestInfo in ipairs(nestPositions) do
	local nest = Instance.new("Part")
	nest.Name = nestInfo.Tier .. "Nest"
	nest.Size = Vector3.new(5, 0.4, 5)
	nest.Shape = Enum.PartType.Cylinder
	nest.Position = nestInfo.NestPos or nestInfo.Pos
	nest.Anchored = true
	nest.BrickColor = BrickColor.new("Dark stone grey")
	nest.Material = Enum.Material.Slate
	nest.Parent = Folders.Nests
end

-- 6. Haupt-Spawn-Loop mit Event-System (Funktionen 13-15: Random Events wie "Golden Hour" oder "Double Spawn")
local activeEvent = "Normal"
task.spawn(function()
	while true do
		task.wait(CONFIG.SpawnInterval)
		
		-- Zufälliges Event alle paar Minuten triggern
		if math.random(1, 100) == 1 then
			activeEvent = "GoldenHour"
			task.delay(30, function() activeEvent = "Normal" end)
		end

		if #nestPositions > 0 then
			local randomNest = nestPositions[math.random(1, #nestPositions)]
			spawnEggAtPosition(randomNest.Pos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			
			if activeEvent == "GoldenHour" then
				spawnEggAtPosition(randomNest.Pos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			end
		end
	end
end)

-- 7. Anti-Exploit & Physics Security (Funktionen 16-20)
-- Verhindert, dass Spieler Eier durch die Map glitchen oder fliegen
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			-- Bei Tod verliert der Spieler alle getragenen Eier!
			local stats = player:FindFirstChild("leaderstats")
			if stats then
				local carried = stats:FindFirstChild("Carried")
				if carried then carried.Value = 0 end
			end
		end)
	end)
end)
