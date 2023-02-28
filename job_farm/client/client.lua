ESX = nil
Citizen.CreateThread(function() while ESX == nil do TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end) Citizen.Wait(0) end end)

local poitblips = {
	{x = -798.06,  y = 4458.01,  z = 15.44}, -- Récolte
	{x = 2950.33, y = 2769.76, z = 35.96}, -- traitement
	{x = 2709.96,  y = 3455.11,  z = 56.30} -- Vente
}


CreateThread(function()
	for b in pairs(poitblips) do
		local blip = AddBlipForCoord(poitblips[b].x, poitblips[b].y, poitblips[b].z)
		SetBlipSprite(blip, 1)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 4)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Job Farm")
        EndTextCommandSetBlipName(blip)
	end
end)

----------------------------------------------------------------------------------------------------------------------
local PlayerData = {}
local GUI = {}
GUI.Time = 0
local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local OnJob = false

AddEventHandler('jobfarm:hasEnteredMarker', function(zone)

	if zone == 'Recolte' then
		CurrentAction = 'recolte_point'
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour ~g~lancer l'activité"
		CurrentActionData = {}
	elseif zone == 'Traitement' then
		CurrentAction = 'traitement_point'
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour ~g~lancer l'activité"
		CurrentActionData = {}
	elseif zone == 'Vente' then
		CurrentAction = 'vente_point'
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour ~g~lancer l'activité"
		CurrentActionData = {zone = zone}
	end

end)

AddEventHandler('jobfarm:hasExitedMarker', function(zone)

	if zone == 'Recolte' then
		TriggerServerEvent('jobfarm:StopRecolte')
	elseif zone == 'Traitement' then
        TriggerServerEvent('jobfarm:StopTraitement')
	elseif zone == 'Vente' then
		TriggerServerEvent('jobfarm:StopVente')
	end

	CurrentAction = nil
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
    local attente = 150
    while true do
        Wait(attente)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'unemployed' then --- Remplacez par votre job
			local coords = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker = false
			local currentZone = nil
			for k,v in pairs(Config.JobFarm) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 5.5) then
					attente = 1
					isInMarker = true
					currentZone = k
					break
				else
					attente = 0
				end
			end
			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone = currentZone
				TriggerEvent('jobfarm:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('jobfarm:hasExitedMarker', LastZone)
			end
		end
	end
end)

CreateThread(function()
    while true do
        local player_id = PlayerPedId()
        local player_coords = GetEntityCoords(player_id)
        local sleep = 5000
        if CurrentAction ~= nil then
			sleep = 0
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, false, -1)
            if IsControlJustReleased(0, 38) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'unemployed' then --- Remplacez par votre job

                if CurrentAction == 'recolte_point' and not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
                    TriggerServerEvent('jobfarm:StartRecolte')
                    Citizen.Wait(5000)
                elseif CurrentAction == 'traitement_point' and not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
					TriggerServerEvent('jobfarm:StartTraitement')
					Citizen.Wait(5000)
				elseif CurrentAction == 'vente_point' and not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
					TriggerServerEvent('jobfarm:StartVente', CurrentActionData.zone)
					Citizen.Wait(5000)
				end
                CurrentAction = nil               
            end
        end
      Wait(sleep)
    end
end)
