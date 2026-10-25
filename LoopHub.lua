--!strict
-- [[ SAE (STEAL AN EGG) - ULTIMATE EGG SNIPER & INSTANT STEAL ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Altes GUI löschen, falls es schon offen ist
local existingGui = player.PlayerGui:FindFirstChild("SAEEggSniper") or (gethui and gethui():FindFirstChild("SAEEggSniper"))
if existingGui then
	existingGui:Destroy()
end

-- Neues GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SAEEggSniper"
screenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
	syn.protect_gui(screenGui)
	screenGui.Parent = CoreGui
elseif gethui then
	screenGui.Parent = gethui()
else
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Hauptfenster (Verschiebbar)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 440, 0, 460)
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Titel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "🥚 SAE: EGG SNIPER [ETERNAL / DIVINE / SECRET]"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = mainFrame

-- Scrolling Frame für die Liste
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -55)
scrollingFrame.Position = UDim2.new(0, 5, 0, 50)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Parent = mainFrame

-- Seltenheits-Prioritäten (Eternal ganz oben, Secret, Divine)
local RARITY_PRIORITY: {[string]: number} = {
	["Eternal"] = 4,
	["Divine"] = 3,
	["Secret"] = 2,
	["Normal"] = 1
}

type EggData = {
	Name: string,
	Model: Instance,
	Rarity: string,
	Value: number,
	PetName: string,
	Priority: number,
	InstanceId: string,
	Position: Vector3
}

local function getActiveEggs(): {EggData}
	local eggsData: {EggData} = {}
	
	-- Sucht im Workspace nach Eiern (auch in Ordnern wie "Eggs", "SpawnedEggs" oder Map-Teilen)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		-- Filtert nach Objekten, die nach Eiern aussehen oder entsprechende Attribute haben
		local rarity = obj:GetAttribute("Rarity") or obj:GetAttribute("Tier")
		local value = obj:GetAttribute("Value") or obj:GetAttribute("Price") or obj:GetAttribute("Cash")
		local petName = obj:GetAttribute("PetName") or obj:GetAttribute("Contains") or obj:GetAttribute("HatchName") or "Unbekanntes Pet"
		
		if typeof(rarity) == "string" and RARITY_PRIORITY[rarity] then
			local pos = Vector3.zero
			if obj:IsA("Model") then
				local ok, p = pcall(function() return obj:GetPivot().Position end)
				if ok then pos = p end
			elseif obj:IsA("BasePart") then
				pos = obj.Position
			end
			
			table.insert(eggsData, {
				Name = obj.Name,
				Model = obj,
				Rarity = rarity,
				Value = typeof(value) == "number" and value or 0,
				PetName = tostring(petName),
				Priority = RARITY_PRIORITY[rarity],
				InstanceId = obj:GetAttribute("ServerInstanceId") or game.JobId,
				Position = pos
			})
		end
	end
	
	-- Sortierung: 1. Nach Seltenheit (Eternal / Divine / Secret zuerst), 2. Nach höchstem Wert
	table.sort(eggsData, function(a, b)
		if a.Priority ~= b.Priority then
			return a.Priority > b.Priority
		end
		return a.Value > b.Value
	end)
	
	return eggsData
end

local function updateUI()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local eggs = getActiveEggs()
	local yOffset = 0
	
	for _, eggData in ipairs(eggs) do
		-- Zeigt nur die Top-Tier Eier an (Secret, Divine, Eternal)
		if eggData.Rarity == "Secret" or eggData.Rarity == "Divine" or eggData.Rarity == "Eternal" then
			
			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.new(1, -10, 0, 55)
			itemFrame.Position = UDim2.new(0, 5, 0, yOffset)
			itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = scrollingFrame
			
			-- Text-Anzeige (Infos zum Ei & Pet)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.42, 0, 1, 0)
			label.Position = UDim2.new(0, 5, 0, 0)
			label.Text = string.format("[%s] %s\nPet: %s | Val: %d", eggData.Rarity, eggData.Name, eggData.PetName, eggData.Value)
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamBold
			label.TextSize = 10
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = itemFrame
			
			-- Button 1: Server Join (Wechselt den Server)
			local joinBtn = Instance.new("TextButton")
			joinBtn.Size = UDim2.new(0.26, 0, 0.8, 0)
			joinBtn.Position = UDim2.new(0.44, 0, 0.1, 0)
			joinBtn.Text = "Join Server"
			joinBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
			joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			joinBtn.Font = Enum.Font.GothamBold
			joinBtn.TextSize = 11
			joinBtn.Parent = itemFrame
			
			joinBtn.MouseButton1Click:Connect(function()
				if eggData.InstanceId ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, eggData.InstanceId, player)
				else
					print("Du bist bereits auf diesem Server!")
				end
			end)
			
			-- Button 2: Instant Steal (Teleportiert direkt zum Ei, Mobs werden umgangen)
			local stealBtn = Instance.new("TextButton")
			stealBtn.Size = UDim2.new(0.26, 0, 0.8, 0)
			stealBtn.Position = UDim2.new(0.72, 0, 0.1, 0)
			stealBtn.Text = "Instant Steal"
			stealBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
			stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			stealBtn.Font = Enum.Font.GothamBold
			stealBtn.TextSize = 11
			stealBtn.Parent = itemFrame
			
			stealBtn.MouseButton1Click:Connect(function()
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") and eggData.Model and eggData.Model.Parent then
					local hrp = char.HumanoidRootPart :: Part
					if eggData.Model:IsA("Model") then
						hrp.CFrame = eggData.Model:GetPivot()
					elseif eggData.Model:IsA("BasePart") then
						hrp.CFrame = eggData.Model.CFrame
					end
					print("Instant Steal ausgeführt für SAE-Ei:", eggData.Name)
				end
			end)
			
			yOffset += 60
		end
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Aktualisiert die Liste alle 2 Sekunden automatisch
task.spawn(function()
	while true do
		pcall(updateUI)
		task.wait(2)
	end
end)

print("SAE Egg Sniper erfolgreich gestartet!")
