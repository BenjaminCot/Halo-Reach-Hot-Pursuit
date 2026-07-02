-- this script is used to spawn in weapons on the map, but with a longer
-- respawn time than what is typically possible (180 seconds)
-- it's not perfectly accurate to the second and that could be improved by
-- counting game ticks instead of using a timer, but this is fine for most
-- purposes, you could use this for vehicles as well if you wanted.

declare object.number[5] with network priority low
declare object.number[6] with network priority low
declare global.number[10] with network priority low

-- this should be fine unless other hill markers use the same number
alias script_spawned_flag = object.number[5]
-- this should be fine unless other weapons use the same number
alias script_spawned_weapon_id = object.number[6]
-- change this to something that isn't used by anything else
alias id_counter = global.number[10]

-- use these to change the respawn (in seconds) time of each weapon
-- remember that it takes +30 seconds for the weapon to despawn, before this timer starts
alias spartan_laser_respawn_time = 10
alias sniper_rifle_respawn_time = 10
alias rocket_launcher_respawn_time = 10

-- these should be fine unless other hill markers also use this number
declare object.timer[0] = spartan_laser_respawn_time
declare object.timer[1] = sniper_rifle_respawn_time
declare object.timer[2] = rocket_launcher_respawn_time

alias spartan_laser_timer = object.timer[0]
alias sniper_rifle_timer = object.timer[1]
alias rocket_launcher_timer = object.timer[2]

-- this should spawn all weapons on the map at the start of the game
on init: do
  -- initialise spawned weapon ID (tracks each weapon back to it's spawn point)
  id_counter = 1
  -- spawn all spartan lasers at the beginning of the game
  for each object with label "spawn_spartan_laser" do
    alias weapon = allocate temporary object
    -- spawn weapon on hill marker
    weapon = current_object.place_at_me(spartan_laser, none, none, 0, 0, 0, none)
    -- copy rotation of hill marker
    -- this part might need some testing if you want it to spawn "flat" on the ground
    -- you cant tell it what specific rotation to set to, you'd have to find 
    -- some other object in your map/gametype that reliably has the orientation that
    -- you want this weapon to have:
    --weapon.copy_rotation_from(current_object, true)
	
	-- apply trackable ID to spawn point and weapon
	current_object.script_spawned_weapon_id = id_counter
	weapon.script_spawned_weapon_id = id_counter
	-- increment the id counter for the next weapon
	id_counter += 1
  end
  for each object with label "spawn_sniper_rifle" do
    alias weapon = allocate temporary object
    -- spawn weapon on hill marker
    weapon = current_object.place_at_me(sniper_rifle, none, none, 0, 0, 0, none)
    -- copy rotation of hill marker
    -- this part might need some testing if you want it to spawn "flat" on the ground
    -- you cant tell it what specific rotation to set to, you'd have to find 
    -- some other object in your map/gametype that reliably has the orientation that
    -- you want this weapon to have:
    --weapon.copy_rotation_from(current_object, true)
	
	-- apply trackable ID to spawn point and weapon
	current_object.script_spawned_weapon_id = id_counter
	weapon.script_spawned_weapon_id = id_counter
	-- increment the id counter for the next weapon
	id_counter += 1
  end
  for each object with label "spawn_rocket_launcher" do
    alias weapon = allocate temporary object
    -- spawn weapon on hill marker
    weapon = current_object.place_at_me(rocket_launcher, none, none, 0, 0, 0, none)
    -- copy rotation of hill marker
    -- this part might need some testing if you want it to spawn "flat" on the ground
    -- you cant tell it what specific rotation to set to, you'd have to find 
    -- some other object in your map/gametype that reliably has the orientation that
    -- you want this weapon to have:
    --weapon.copy_rotation_from(current_object, true)
	
	-- apply trackable ID to spawn point and weapon
	current_object.script_spawned_weapon_id = id_counter
	weapon.script_spawned_weapon_id = id_counter
	-- increment the id counter for the next weapon
	id_counter += 1
  end
end

-- keep track for when each weapon despawns, start the timer again when they do
-- fyi: it takes about 30 seconds for the weapon to be despawned after it is dropped
for each object with label "spawn_spartan_laser" do
  alias spawn_point_id = allocate temporary number
  alias weapon_spawn_point = allocate temporary object
  weapon_spawn_point = current_object
  spawn_point_id = current_object.script_spawned_weapon_id
  weapon_spawn_point.spartan_laser_timer.set_rate(-100%)
  -- check if the spawned weapon is still spawned in
  for each object do
    if current_object.is_of_type(spartan_laser) and current_object.script_spawned_weapon_id == spawn_point_id then
	  -- reset the timer if the weapon was found
	  weapon_spawn_point.spartan_laser_timer.reset()
	end
  end
  if weapon_spawn_point.spartan_laser_timer.is_zero() then
    alias weapon = allocate temporary object
	weapon = weapon_spawn_point.place_at_me(spartan_laser, none, none, 0, 0, 0, none)
	-- re-use the spawn point's existing ID, it never changed
	weapon.script_spawned_weapon_id = spawn_point_id
  end
end

for each object with label "spawn_sniper_rifle" do
  alias spawn_point_id = allocate temporary number
  alias weapon_spawn_point = allocate temporary object
  weapon_spawn_point = current_object
  spawn_point_id = current_object.script_spawned_weapon_id
  weapon_spawn_point.sniper_rifle_timer.set_rate(-100%)
  -- check if the spawned weapon is still spawned in
  for each object do
    if current_object.is_of_type(sniper_rifle) and current_object.script_spawned_weapon_id == spawn_point_id then
	  -- reset the timer if the weapon was found
	  weapon_spawn_point.sniper_rifle_timer.reset()
	end
  end
  if weapon_spawn_point.sniper_rifle_timer.is_zero() then
    alias weapon = allocate temporary object
	weapon = weapon_spawn_point.place_at_me(sniper_rifle, none, none, 0, 0, 0, none)
	-- re-use the spawn point's existing ID, it never changed
	weapon.script_spawned_weapon_id = spawn_point_id
  end
end

for each object with label "spawn_rocket_launcher" do
  alias spawn_point_id = allocate temporary number
  alias weapon_spawn_point = allocate temporary object
  weapon_spawn_point = current_object
  spawn_point_id = current_object.script_spawned_weapon_id
  weapon_spawn_point.rocket_launcher_timer.set_rate(-100%)
  -- check if the spawned weapon is still spawned in
  for each object do
    if current_object.is_of_type(rocket_launcher) and current_object.script_spawned_weapon_id == spawn_point_id then
	  -- reset the timer if the weapon was found
	  weapon_spawn_point.rocket_launcher_timer.reset()
	end
  end
  if weapon_spawn_point.rocket_launcher_timer.is_zero() then
    alias weapon = allocate temporary object
	weapon = weapon_spawn_point.place_at_me(rocket_launcher, none, none, 0, 0, 0, none)
	-- re-use the spawn point's existing ID, it never changed
	weapon.script_spawned_weapon_id = spawn_point_id
  end
end