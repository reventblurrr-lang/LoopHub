-- [[ SAE EGG SNIPER - ULTRA PRO EDITION ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Altes GUI aufräumen
local existing = CoreGui:FindFirstChild("SAE_UltraSniper") or player.PlayerGui:FindFirstChild("SAE_UltraSniper")
if existing then existing:Destroy() end

-- Haupt-ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SAE_UltraSniper"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Hauptfenster
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 460, 0, 420)
mainFrame.Position = UDim2.new(0.08, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Kopfzeile
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local fixCover = Instance.new("Frame")
fixCover.Size = UDim2.new(1, 0, 0, 10)
fixCover.Position = UDim2.new(0, 0, 1, -10)
fixCover.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
fixCover.BorderSizePixel = 0
fixCover.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.Text = "⚡ SAE EGG SNIPER"
titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Container für die Inhalts-Liste (wird beim Minimieren ausgeblendet)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -40)
contentContainer.Position = UDim2.new(0, 0, 0, 40)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Schließen-Button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 26)
closeBtn.Position = UDim2.new(1, -35, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Minimieren-Button (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 26)
minimizeBtn.Position = UDim2.new(1, -70, 0, 7)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	contentContainer.Visible = not isMinimized
	if isMinimized then
		mainFrame.Size = UDim2.new(0, 460, 0, 40)
		minimizeBtn.Text = "+"
	else
		mainFrame.Size = UDim2.new(0, 460, 0, 420)
		minimizeBtn.Text = "-"
	end
end)

-- Scrolling Frame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -16, 1, -12)
scrollingFrame.Position = UDim2.new(0, 8, 0, 6)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 5
scrollingFrame.Parent = contentContainer

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.Parent = scrollingFrame

-- Seltenheits-Prioritäten
local RARITY_PRIORITY = {
	["Eternal"] = 4,
	["Divine"] = 3,
	["Secret"] = 2,
	["Normal"] = 1
}

local function findStealRemote()
	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") then
			local name = obj.Name:lower()
			if name:find("steal") or name:find("hatch") or name:find("egg") or name:find("collect") then
				return obj
			end
		end
	end
	return nil
end

local function getActiveEggs()
	local eggsData = {}
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			local rarity = obj:GetAttribute("Rarity") or obj:GetAttribute("Tier")
			local value = obj:GetAttribute("Value") or obj:GetAttribute("Price") or obj:GetAttribute("Cash")
			local petName = obj:GetAttribute("PetName") or obj:GetAttribute("Contains") or obj:GetAttribute("HatchName") or "Unbekannt"
			
			if type(rarity) == "string" and RARITY_PRIORITY[rarity] then
				local pos = Vector3.new(0,0,0)
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
					Value = type(value) == "number" and value or 0,
					PetName = tostring(petName),
					Priority = RARITY_PRIORITY[rarity],
					InstanceId = obj:GetAttribute("ServerInstanceId") or game.JobId,
					Position = pos
				})
			end
		end
	end)
	
	table.sort(eggsData, function(a, b)
		if a.Priority ~= b.Priority then
			return a.Priority > b.Priority
		end
		return a.Value > b.Value
	end)
	
	return eggsData
end

local function updateUI()
	if isMinimized then return end
	
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	local eggs = getActiveEggs()
	local count = 0
	
	for _, eggData in ipairs(eggs) do
		if eggData.Rarity == "Secret" or eggData.Rarity == "Divine" or eggData.Rarity == "Eternal" then
			count += 1
			
			-- Eier Karten-Design
			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.new(1, 0, 0, 55)
			itemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = scrollingFrame
			
			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 8)
			itemCorner.Parent = itemFrame
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.42, 0, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.Text = string.format("[%s] %s\nPet: %s | Val: %d", eggData.Rarity, eggData.Name, eggData.PetName, eggData.Value)
			label.TextColor3 = Color3.fromRGB(240, 240, 240)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 11
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = itemFrame
			
			-- Server Join Button (Mit Server-Wechsel Fix)
			local joinBtn = Instance.new("TextButton")
			joinBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
			joinBtn.Position = UDim2.new(0.44, 0, 0.15, 0)
			joinBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
			joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			joinBtn.Text = "Join Server"
			joinBtn.Font = Enum.Font.GothamBold
			joinBtn.TextSize = 11
			joinBtn.Parent = itemFrame
			
			local joinCorner = Instance.new("UICorner")
			joinCorner.CornerRadius = UDim.new(0, 6)
			joinCorner.Parent = joinBtn
			
			joinBtn.MouseButton1Click:Connect(function()
				pcall(function()
					-- Wenn keine Instanz-ID da ist, suche nach anderen Servern über Roblox API oder Teleport
					if eggData.InstanceId and eggData.InstanceId ~= game.JobId then
						TeleportService:TeleportToPlaceInstance(game.PlaceId, eggData.InstanceId, player)
					else
						-- Fallback: Normaler Server Hop
						local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
						for _, s in ipairs(servers.data) do
							if s.id ~= game.JobId and s.playing < s.maxPlayers then
								TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
								break
							end
						end
					end
				end)
			end)
			
			-- Instant Steal Button
			local stealBtn = Instance.new("TextButton")
			stealBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
			stealBtn.Position = UDim2.new(0.71, 0, 0.15, 0)
			stealBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
			stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			stealBtn.Text = "Instant Steal"
			stealBtn.Font = Enum.Font.GothamBold
			stealBtn.TextSize = 11
			stealBtn.Parent = itemFrame
			
			local stealCorner = Instance.new("UICorner")
			stealCorner.CornerRadius = UDim.new(0, 6)
			stealCorner.Parent = stealBtn
			
			stealBtn.MouseButton1Click:Connect(function()
				local char = player.Character
				if char and char:FindFirstChild("HumanoidRootPart") and eggData.Model and eggData.Model.Parent then
					local hrp = char.HumanoidRootPart
					if eggData.Model:IsA("Model") then
						hrp.CFrame = eggData.Model:GetPivot()
					elseif eggData.Model:IsA("BasePart") then
						hrp.CFrame = eggData.Model.CFrame
					end
					
					local remote = findStealRemote()
					if remote then
						pcall(function() remote:FireServer(eggData.Model) end)
					end
				end
			end)
		end
	end
	
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 63)
end

task.spawn(function()
	while true do
		pcall(updateUI)
		task.wait(2)
	end
end)

print("SAE Ultra Sniper erfolgreich geladen!")
