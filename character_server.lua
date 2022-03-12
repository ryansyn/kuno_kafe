local RS = game:GetService("ReplicatedStorage");
local SS = game:GetService("ServerStorage");
local MS = game:GetService("MarketplaceService");
local PS = game:GetService("Players");

local characterLoadedEvent = RS:FindFirstChild("characterLoadedEvent");

-- OTHER COMPONENTS

-- Explanation: this function is called to test if the player's .userId is equivalent to that of an "exception" (being an owner of the game)
local function isAnException (player)
	-- Explanation: table containing owner userIds
	local user_ids = {
		193067402, -- zuchini
		256584577, -- kuno
		133179825, -- foxiboio
	}
	
	-- Explanation: simple iteration through the user_ids table checking equivalency
	for i,v in ipairs(user_ids) do
		if player.UserId == v then
			-- Explanation: returns true upon equivalency
			return true
		end
	end
	
	-- Explanation: returns default false
	return false
end

-- GAMEPASS COMPONENTS

-- Explanation: checks if a player has a gamepass through the use of MarketPlaceService
local function hasGamepass (player, gamepass_id)
	-- Explanation: uses the function we created earlier to see if the player is an "exception"
	if isAnException(player) then
		-- Explanation: player recieves the gamepass upon being an "exception"
		return true
	end
	
	-- Explanation: I use pcall because MarketPlaceService can often fail its callback if servers are slow or interrupted
	local res, req = pcall(MS.UserOwnsGamePassAsync, MS, player.UserId, gamepass_id);
	return res;
end

-- USER TAG COMPONENTS

-- Explanation: removes name above player model
local function removeHumanoidDisplay (player)
	-- Explanation: we access the player humanoid and set the DisplayDistanceType to none so Roblox built in player UI doesn't interfere with our custom
	player.Character:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
end

-- Explanation: finds and returns a string of the player's rank name
local function findRankName (player, prop)
	local rankName;
	
	-- Explanation: we find our string through a table in a module script under character_server with keys being rank id numbers and fetch its components
	local rank_names = require(script.rank_names);
	if prop == "Name" then
		rankName = rank_names[player:GetRankInGroup(10643741)].Name;
	elseif prop == "Tag" then
		rankName = rank_names[player:GetRankInGroup(10643741)].Tag;
	end
	
	return rankName;
end

-- Explanation: find and returns a string of a custom user name
local function findUserName (player)
	local userName;
	
	userName = player.DisplayName.." (@"..player.Name..")";
	
	return userName;
end

local function setupUserTag (player)
	removeHumanoidDisplay(player)
	
	-- Explanation: we make an attachment on the HumanoidRootPart for our user tag to position on
	local UserTags = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"));
	UserTags.Name = "UserTags";
	UserTags.Position = Vector3.new(0, 4.5, 0);
	
	-- Explanation: we clone a preset BillboardGui to display our player's username
	local Username = SS.user_tags:FindFirstChild("Username"):Clone(); 
	Username.Parent = UserTags;
	local UsernameTextLabel1 = Username:FindFirstChild("TextLabel1");
	local UsernameTextLabel2 = Username:FindFirstChild("TextLabel2");
	UsernameTextLabel1.Text = findUserName(player);
	UsernameTextLabel2.Text = findUserName(player);

	-- Explanation: we clone a preset BillboardGui to display our player's rank
	local Rank = SS.user_tags:FindFirstChild("Rank"):Clone(); 
	Rank.Parent = UserTags;
	local RankTextLabel1 = Rank:FindFirstChild("TextLabel1");
	local RankTextLabel2 = Rank:FindFirstChild("TextLabel2");
	
	-- Explanation: finds if our player has a tag or not
	if findRankName(player, "Tag") == nil then
		RankTextLabel1.Text = findRankName(player, "Name");
		RankTextLabel2.Text = findRankName(player, "Name");
	else
		RankTextLabel1.Text = findRankName(player, "Name").." ["..findRankName(player, "Tag").."]";
		RankTextLabel2.Text = findRankName(player, "Name").." ["..findRankName(player, "Tag").."]";
	end
	
	-- Explanation: we clone a special preset BillboardGui user tag for those in a particular group
	if player:IsInGroup(9777163) then
		local Membership = SS.user_tags:FindFirstChild("Membership"):Clone(); 
		Membership.Parent = UserTags;
	end
end

-- MORPH COMPONENTS

-- Explanation: clones assets of a morph and applies them to the player's character
local function morphSetup (player)
	-- Explanation: finds if the player has a morph in the categorized-by-tag ServerStorage morph directories
	if findRankName(player, "Tag") == nil then
		return
	end
	
	local morph;
	
	if SS.morphs:FindFirstChild(findRankName(player, "Tag")) then
		local dir = SS.morphs:FindFirstChild(findRankName(player, "Tag"));
		
		-- Explanation: finds out if a specific rank has a morph or if theres a morph for all ranks
		if dir:FindFirstChildWhichIsA("Folder") then
			morph = dir:FindFirstChild(findRankName(player, "Name"));
		else
			morph = dir;
		end
	end
	
	-- Explanation: once again, another iteration through morph components and applies them to character while destroying previous clothing
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
		-- Explanation: since you cannot manipulate a MeshPart's meshId REAL-TIME or just simply insert a Special Mesh into the body part, we manipulate
		-- the player's HUMANOID DESCRIPTION containing a storage of all worn avatar item asset ids
		local humanoid_description = player.Character.Humanoid:FindFirstChild("HumanoidDescription"):Clone();
		humanoid_description.Head = 134082579;
		humanoid_description.Name = humanoid_description.ClassName;
		player.Character.Humanoid:ApplyDescription(humanoid_description);
	end
	
	if hasGamepass(player, 33189194) then
		-- Explanation: same thing
		local humanoid_description = player.Character.Humanoid:FindFirstChild("HumanoidDescription"):Clone();
		humanoid_description.RightLeg = 139607718;
		humanoid_description.Name = humanoid_description.ClassName;
		player.Character.Humanoid:ApplyDescription(humanoid_description);
	end
	
	if hasGamepass(player, 0) then
		-- Explanation: we give the player an item out of ServerStorage
		local item = SS.items.gamepass:FindFirstChild("Golden Cupped Coffee"):Clone();
		item.Parent = player.Backpack;
	end
	
	setupUserTag(player)
	morphSetup(player);
end)
