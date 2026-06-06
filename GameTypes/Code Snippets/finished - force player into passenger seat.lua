-- Spawn a new vehicle and force the player into the passenger seat.
for each player do
    -- Assign temps & aliases
	alias vehicle1 = allocate temporary object
	alias tempbiped = allocate temporary object
	alias tempplayerbiped = allocate temporary object
	-- Place vehicle and temporary biped
	vehicle1 = current_player.biped.place_at_me(mongoose, none, none, 0, 0, 0, none) -- place mongoose
	tempbiped = vehicle1.place_at_me(spartan, none, never_garbage_collect, 0, 0, 0, kat) -- place temp biped
	-- Player possesses biped and is forced into vehicle
	tempplayerbiped = current_player.biped
	current_player.set_biped(tempbiped)
	current_player.force_into_vehicle(vehicle1)
	-- Player possesses their original body and is forced into vehicle (passenger seat)
	current_player.set_biped(tempplayerbiped)
	current_player.force_into_vehicle(vehicle1)
	-- Delete the temporary biped
	tempbiped.delete()
end
