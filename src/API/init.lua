local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.Server)
else
	return require(script.Client)
end

--[=[
	@class RoRooms
]=]

--[=[
	@method Start
	@within RoRooms

	Starts RoRooms.
]=]

--[=[
	@method Configure
	@within RoRooms

	@param Config Config

	Reconciles RoRooms' config to your liking.

	[`Config` type available here](https://github.com/RoRooms/RoRooms/blob/main/src/API/Config.lua)
]=]

--[=[
	@method Prompt
	@within RoRooms
	@client

	@param Prompt Prompt

	Prompts the client, with support for callback buttons.

	[`Prompt` type available here](https://github.com/RoRooms/RoRooms/blob/main/src/Client/UI/States/Prompts.lua)
]=]
