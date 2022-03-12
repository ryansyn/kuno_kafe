local RS = game:GetService("ReplicatedStorage");
local PS = game:GetService("Players");
local P = PS.LocalPlayer;

local characterLoadedEvent = RS:FindFirstChild("characterLoadedEvent");

P.CharacterAdded:Connect(function (player)
	characterLoadedEvent:FireServer(player);
end)
