local RS = game:GetService("ReplicatedStorage");
local SS = game:GetService("ServerStorage");
local MS = game:GetService("MarketplaceService");
local PS = game:GetService("Players");

local characterLoadedEvent = RS:FindFirstChild("characterLoadedEvent");

-- OTHER COMPONENTS
local function isAnException (player)
	local user_ids = {
		193067402, -- zuchini
		256584577, -- kuno
		133179825, -- foxiboio
	}
	
	for i,v in ipairs(user_ids) do
		if player.UserId == v then
			return true
		end
	end
	
	return false
end

-- GAMEPASS COMPONENTS
local function hasGamepass (player, gamepass_id)
	if isAnException(player) then
		return true
	end
	
	local res, req = pcall(MS.UserOwnsGamePassAsync, MS, player.UserId, gamepass_id);
	return res;
end

-- USER TAG COMPONENTS
local function removeHumanoidDisplay (player)
	player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
end

local function findRankName (player, prop)
	local rankName;
	
	local rank_names = require(script.rank_names);
	if prop == "Name" then
		rankName = rank_names[player:GetRankInGroup(10643741)].Name;
	elseif prop == "Tag" then
		rankName = rank_names[player:GetRankInGroup(10643741)].Tag;
	end
	
	return rankName;
end

local function findUserName (player)
	local userName;
	
	userName = player.DisplayName.." (@"..player.Name..")";
	
	return userName;
end

local function setupUserTag (player)
	removeHumanoidDisplay(player)
	
	local UserTags = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"));
	UserTags.Name = "UserTags";
	UserTags.Position = Vector3.new(0, 4.5, 0);
	
	local Username = SS.user_tags:FindFirstChild("Username"):Clone(); 
	Username.Parent = UserTags;
	local UsernameTextLabel1 = Username:FindFirstChild("TextLabel1");
	local UsernameTextLabel2 = Username:FindFirstChild("TextLabel2");
	UsernameTextLabel1.Text = findUserName(player);
	UsernameTextLabel2.Text = findUserName(player);

	local Rank = SS.user_tags:FindFirstChild("Rank"):Clone(); 
	Rank.Parent = UserTags;
	local RankTextLabel1 = Rank:FindFirstChild("TextLabel1");
	local RankTextLabel2 = Rank:FindFirstChild("TextLabel2");
	if findRankName(player, "Tag") == nil then
		RankTextLabel1.Text = findRankName(player, "Name");
		RankTextLabel2.Text = findRankName(player, "Name");
	else
		RankTextLabel1.Text = findRankName(player, "Name").." ["..findRankName(player, "Tag").."]";
		RankTextLabel2.Text = findRankName(player, "Name").." ["..findRankName(player, "Tag").."]";
	end
	
	if player:IsInGroup(9777163) then
		local Membership = SS.user_tags:FindFirstChild("Membership"):Clone(); 
		Membership.Parent = UserTags;
	end
end

-- MORPH COMPONENTS
local function removeAccessories (player)
	for _,v in ipairs (player.Character:GetChildren()) do
		if v:IsA("Accessory") then
			v:Destroy();
		end
	end
end

local function morphSetup (player)
	if findRankName(player, "Tag") == nil then
		return
	end
	
	local morph;
	
	if SS.morphs:FindFirstChild(findRankName(player, "Tag")) then
		local dir = SS.morphs:FindFirstChild(findRankName(player, "Tag"));
		if dir:FindFirstChildWhichIsA("Folder") then
			morph = dir:FindFirstChild(findRankName(player, "Name"));
		else
			morph = dir;
		end
	end
	
	for i,v in ipairs(morph:GetChildren()) do
		if v:IsA("Shirt") or v:IsA("Pants") then
			for _,w in ipairs(player.Character:GetChildren()) do
				if w.className == v.className then
					w:Destroy();
				end
			end
			v:Clone().Parent = player.Character;
		end
	end
end

characterLoadedEvent.OnServerEvent:Connect(function (player)
	if hasGamepass(player, 33174055) then
		local humanoid_description = player.Character.Humanoid:FindFirstChild("HumanoidDescription"):Clone();
		humanoid_description.Head = 134082579;
		humanoid_description.Name = humanoid_description.ClassName;
		player.Character.Humanoid:ApplyDescription(humanoid_description);
	end
	
	if hasGamepass(player, 33189194) then
		local humanoid_description = player.Character.Humanoid:FindFirstChild("HumanoidDescription"):Clone();
		humanoid_description.RightLeg = 139607718;
		humanoid_description.Name = humanoid_description.ClassName;
		player.Character.Humanoid:ApplyDescription(humanoid_description);
	end
	
	if hasGamepass(player, 0) then
		local item = SS.items.gamepass:FindFirstChild("Golden Cupped Coffee"):Clone();
		item.Parent = player.Backpack;
	end
	
	setupUserTag(player)
	morphSetup(player);
end)
