local points = {}

exports('register', function(point)
	point.players = {}
	table.insert(points, point)
	return #points
end)

exports('unregister', function(id)
	if not points[id] then return end
	for player in ipairs(points[id].players) do
		TriggerClientEvent('points:hide', player, id)
	end
	points[id] = nil
end)

exports('show', function(id, player)
	if not points[id] or points[id].players[player] or not GetPlayerName(player) then return end
	points[id].players[player] = true
	TriggerClientEvent('points:show', player, id, points[id])
end)

exports('hide', function(id, player)
	if not points[id] or not points[id].players[player] then return end
	points[id].players[player] = nil
	TriggerClientEvent('points:hide', player, id)
end)

AddEventHandler('playerDropped', function()
	local player = source
	for _, point in ipairs(points) do
		if point.players[player] then
			point.players[player] = nil
		end
	end
end)

RegisterNetEvent('points:trigger')
AddEventHandler('points:trigger', function(id, action)
	local player = source
	if not points[id] or not points[id].players[player] then return end
	if not points[id].action or not points[id].action[action] or not points[id].action.event then return end
	if #(GetEntityCoords(GetPlayerPed(player)) - points[id].coords) > 10 then return end
	points[id].action.event(player, action)
end)