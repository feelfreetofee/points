local points = {}

RegisterNetEvent('points:show')
AddEventHandler('points:show', function(id, point)
	if point.blip then
		point.blip.id = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)

		SetBlipSprite(point.blip.id, point.blip.type)

		SetBlipColour(point.blip.id, point.blip.colour)
		SetBlipScale(point.blip.id, point.blip.scale)
		SetBlipAsShortRange(point.blip.id, point.blip.short)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(point.blip.string)
		EndTextCommandSetBlipName(point.blip.id)
	end
	if point.ped then
		repeat RequestModel(point.ped.model) Wait(0)
		until HasModelLoaded(point.ped.model)
		point.ped.id = CreatePed(0, point.ped.model, point.coords.x, point.coords.y, point.coords.z, point.ped.heading)
		FreezeEntityPosition(point.ped.id, true)
		SetEntityInvincible(point.ped.id, true)
		SetBlockingOfNonTemporaryEvents(point.ped.id, true)
		SetPedDefaultComponentVariation(point.ped.id)
		SetModelAsNoLongerNeeded(point.ped.model)
	end
	points[id] = point
end)

RegisterNetEvent('points:hide')
AddEventHandler('points:hide', function(id)
	if points[id].blip then
		RemoveBlip(points[id].blip.id)
	end
	if points[id].ped then
		SetEntityAsNoLongerNeeded(points[id].ped.id)
	end
	points[id] = nil
end)

Citizen.CreateThread(function()
	local sleep
	local coords
	local inside
	while true do
		sleep = 1000
		coords = GetEntityCoords(PlayerPedId())
		for id, point in ipairs(points) do
			if point.marker or point.action then
				local distance = #(coords - point.coords)
				if distance < point.range then
					sleep = 0
					if point.marker then
						DrawMarker(point.marker.type, point.coords.x, point.coords.y, point.coords.z, 0, 0, 0, 0, 0, 0, point.marker.scale.x, point.marker.scale.y, point.marker.scale.z, point.marker.colour.r, point.marker.colour.g, point.marker.colour.b, point.marker.colour.a, point.marker.anim, point.marker.face, 2, 0, point.marker.dict, point.marker.txd)
					end
					if not inside and point.action and distance < point.action.range then
						inside = true
						Citizen.CreateThread(function()
							if point.action.join then
								TriggerServerEvent('points:trigger', id, 'join')
							end
							if point.action.notification then
								AddTextEntry('points', point.action.notification)
							end
							while point and #(coords - point.coords) < point.action.range do
								if point.action.notification then
									DisplayHelpTextThisFrame('points')
								end
								if point.action.key and IsControlJustReleased(0, point.action.key) then
									TriggerServerEvent('points:trigger', id, 'key')
								end
								Wait(0)
							end
							inside = false
							if point.action.leave then
								TriggerServerEvent('points:trigger', id, 'leave')
							end
						end)
					end
				end
			end
		end
		Wait(sleep)
	end
end)