-- this project has been sidelined for the moment to focus on other things
-- the skull code works, a player walks up to a forklift and picks up the skull, they are then riding the forklift.
-- the other code which is meant to be a neater method of doing the same thing (no skull pickup) doesnt work, goodluck! :)


-- pickup item/skull implementation

-- Add extra seats to vehicles
for each object do
  alias flagstand = allocate temporary object
  alias skullobj = allocate temporary object
  alias attached_flag = current_object.number[0]
  -- Forklift
  if current_object.is_of_type(forklift) and attached_flag == 0 then
  flagstand = current_object.place_at_me(flag_stand, none, none, 0, 0, 0, none)
	skullobj = flagstand.place_at_me(skull, none, none, -1, 0, 0, none)
	flagstand.attach_to(current_object, -8, 0, 5, relative)
	-- back-front, left-right, down-up
	skullobj.attach_to(flagstand, 0, 0, 0, relative)
	-- need to apply current_object.number = {the same number for both the skull and the vehicle)
	current_object.number[1] = id_counter
	skullobj.number[1] = id_counter
	id_counter += 1
    attached_flag = 1
  end
end

-- Detect when a player is trying to enter an extra seat
for each object do
  alias player_weapon = allocate temporary object
  alias parent_vehicle = allocate temporary object
  if current_object.is_of_type(skull) then
    for each player do
	  player_weapon = current_player.try_get_weapon(primary)
	  if player_weapon == current_object then
	    -- detect skulls item ID and attach seat to vehicle with the same ID
		alias skull_id = allocate temporary number
		skull_id = current_object.number[1]
		parent_vehicle = current_object
		for each object do
		  if not current_object.is_of_type(skull) then
		    if current_object.number[1] == skull_id then
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
              vehicle1.copy_rotation_from(current_object, true)
			  vehicle1.attach_to(current_object, -3, 0, 5, relative) -- -3, 0, 5 I THINK
			  vehicle1.set_scale(70)
			end
		  end
		  player_weapon.delete()
		end
	  end
	end
  end
end	

-- everything below this line is my attempt at a cleaner version
-- most of it doesnt work yet
	
for each player do
  -- Assign aliases
  alias current_player_vehicle = allocate temporary object
  alias child_vehicle = allocate temporary object
  alias flagstand = allocate temporary object
  -- Get player vehicle
  current_player_vehicle = current_player.get_vehicle()
  if current_player_vehicle.is_of_type(forklift) and current_player_vehicle.attached_id == 0 then -- if parent forklift, and has no attachments	
	-- place attachment objects
	flagstand = current_player_vehicle.place_at_me(flag_stand, none, none, 0, 0, 0, none) -- place flag stand at parent forklift
	child_vehicle = flagstand.place_at_me(forklift, none, none, 0, 0, 0, none) -- place child forklift at parent forklift
	
	-- attach those new objects
	flagstand.attach_to(current_player_vehicle, -8, 0, 5, relative) -- attach flagstand to parent forklift
	child_vehicle.attach_to(flagstand, 15, 0, -5, relative) -- attach child forklift to flagstand
	--                       back-front (8), left-right, down-up
	
	-- apply ID identifiers (so all attached objects can be identified that they are linked to each other)
	current_player_vehicle.attached_id = id_counter
	flagstand.attached_id = id_counter
	
	-- flags for child vehicle (these basically do nothing cuz you can never receive this number)
	child_vehicle.attached_id = id_counter
	child_vehicle.attached_id += 100 -- +100 is used to uniquely identify child vehicles from their parent
	
	--id_counter += 1 --increment ID counter for the next object
	 
  end
  
  alias second_player_vehicle = allocate temporary object
  alias occupants = allocate temporary number
  alias forklift_driver = current_player.number[6]
  if current_player_vehicle.is_of_type(forklift) and current_player_vehicle.attached_id == 1 then
    -- Check if more than one person is in the "same forklift"
	if current_player_vehicle != no_object then
	  occupants = 0
	  for each player do
	    second_player_vehicle = current_player.get_vehicle()
	    if current_player_vehicle == second_player_vehicle then
	      occupants += 1
	    end
	  end 
	end
	if occupants == 1 then
	  -- give the driver a persistant player number so they can identified as the driver
	  forklift_driver = 1  
	end
	if occupants > 1 then -- if a second player enters, put them in the passenger seat
	  for each player do
	  -- add a check here that the player is actually in the fkn forklift loll | edit: im hoping this works?
	  second_player_vehicle = current_player.get_vehicle()
	    alias forklift_driver = current_player.number[6]
		if forklift_driver != 1 and current_player_vehicle == second_player_vehicle then
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
		  -- Attach to parent forklift
		  vehicle1.copy_rotation_from(current_player_vehicle, true)
		  vehicle1.attach_to(current_player_vehicle, -3, 0, 5, relative) -- -3, 0, 5 I THINK
		  vehicle1.set_scale(70)
		  current_player_vehicle.attached_id = 2
		end
	  end
	end
  end
end







-- i think the "player is using child vehicle detection" isntworking cuz lots ofthe code is using temporaries, maybe try persistant variables for everything?
-- idk just rewrite that part i think


    --game.show_message_to(current_player, none, "Round %n", current_player.number[3])
    --flagstand = current_object.place_at_me(flag_stand, none, none, -8, 0, 5, none) -- place flagstand at parent vehicle
	--child_vehicle = flagstand.place_at_me(forklift, none, none, 0, 0, 0, none) -- place child vehicle at flagstand
	--flagstand.attach_to(current_object, -8, 0, 5, relative) -- attach flagstand to parent vehicle
	--child_vehicle.attach_to(flagstand, 0, 0, 0, relative) -- attach child vehicle to flagstand
	---- Add numerical ID identifiers to all objects involved
	--currentplayervehicle.number[1] = id_counter
	--child_vehicle.number[1] = id_counter
	--flagstand.number[1] = id_counter
	---- Increment ID counter for the next vehicle attachment
	--id_counter += 1
    --currentplayervehicle.number[0] = 1 -- add attached flag for parent vehicle
	--child_vehicle.number[0] = 2 -- add attached flag for child vehicle

