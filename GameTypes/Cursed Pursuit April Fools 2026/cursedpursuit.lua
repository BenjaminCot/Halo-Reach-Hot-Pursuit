--[[
Cursed Pursuit October 2026 (week 1)
Authors: (and the work that they've done)
Demonatorpro: No scripting, but he created the original Hot Pursuit gametype.
Dummy Dragon123: Falcon Nerf, Status HUD, Last man standing distance calculator
                 Team-balancing code
NukeOhio: Speedometer
Benjamin Cottrill/Ma7ter Chief: Everything else
--]]

declare global.number[0] with network priority low -- lms flag, not reusable
declare global.number[1] with network priority low -- Used for 330x, REUSABLE
declare global.number[2] with network priority local -- Used for 330x (local tick counter), Not Reusable
declare global.number[3] with network priority local -- Used for re-rolling rare weapons, REUSABLE
declare global.number[4] with network priority local -- Used for 330x (host indicator), Not Reusable
declare global.number[5] with network priority low -- Population counter for Ghostbusters
declare global.number[6] with network priority low -- Population counter for Ghosts
declare global.number[7] with network priority low -- Used for rand number rolls, 330x and other calculations, REUSABLE
declare global.number[8] with network priority low -- Used for 330x, REUSABLE
declare global.number[9] with network priority low -- storage for swapping one player with another, not reusable
declare global.number[10] with network priority low -- vehicle occupants, bomb population, target locator flag, REUSABLE
declare global.number[11] with network priority low -- Used for 330x, REUSABLE
declare global.object[0] with network priority low -- bomb being detonated, REUSABLE
declare global.object[1] with network priority low -- Used for 330x, REUSABLE
declare global.object[2] with network priority low -- Used to detect player's current vehicle, REUSABLE
declare global.object[3] with network priority low -- Used for falcon nerf, target locator check, REUSABLE
declare global.object[4] with network priority low -- launch target (object to push upward), REUSABLE
declare global.object[5] with network priority low -- random weapon, REUSABLE
declare global.object[6] with network priority low -- Used for player teleporting
declare global.object[7] with network priority low -- Used for player teleporting
declare global.object[8] with network priority low -- new biped created by a teleport, REUSABLE
declare global.object[9] with network priority low -- second vehicle used for vehicle swapping, REUSABLE
declare global.object[10] with network priority low -- first vehicle
declare global.object[11] with network priority low -- biped of the bomb carrier (scratch)
declare global.object[12] with network priority low -- hot potato oddball
declare global.player[0] with network priority local -- REUSABLE
declare global.player[1] with network priority local -- REUSABLE
declare global.player[2] with network priority low
declare global.player[3] with network priority low -- saved player, used around nested "for each player" loops
declare global.player[4] with network priority low -- hot potato holder (last player to hold the oddball)
declare global.player[5] with network priority low -- hot potato carrier, REUSABLE
declare global.timer[0] -- Unused
declare global.timer[1] = 10
declare global.timer[2] = 90 -- global event timer
declare global.timer[3] = 30 -- hot potato oddball fuse
declare global.timer[4] = 3 -- hot potato pass cooldown (no tag-backs)
declare player.number[0] with network priority low
declare player.number[1] with network priority low
declare player.number[2] with network priority low -- Per player flag: scorpion/wraith message already shown
declare player.number[3] with network priority low -- Keeps track of number of Rounds each game
declare player.number[4] with network priority low -- Used to calculate players distance from last man standing
declare player.number[5] with network priority low -- Per player flag for weapons swaps, not reuseable
declare player.number[6] with network priority low -- Mode flag: 0 = none, 1 = bullrun, 2 = ghost
declare player.number[7] with network priority low -- Stores bomb timer number from the previous tick
declare player.team[0] with network priority low
declare player.team[1] with network priority low
declare player.timer[0] = 20 -- bomb timer
declare player.timer[1] = 5 -- Timer for splash screen text, round indicator
declare player.timer[2] = 1 -- Used to track survival time in seconds
declare player.timer[3] = 0 -- seconds spent in the current vehicle (counts up)
declare player.object[0] with network priority low -- player's current vehicle (weapon swap check)
declare player.object[1] with network priority low -- player's hot potato bomb
declare player.object[2] with network priority low -- vehicle swap: marks which players were in the swapped vehicle
declare player.object[3] with network priority low -- vehicle the player was in last tick (vehicle damage resistance)
declare object.number[0] with network priority low -- Unused
declare object.number[1] with network priority local -- Used for 330x, Not reusable
declare object.object[0] with network priority low -- Used for 330x as scale anchor, might be ok to reuse if the object isnt scaled
declare object.player[0] with network priority low -- vehicle's longest occupant tag (treated as the driver)

--========== ALIASES ==========--
-- 330x Aliases
alias host_ID = 1
alias client_ID = 0
--alias client_ID = host_ID   -- For singleplayer testing. Must be commented out for multiplayer.
alias resizing_primed = 1
alias resizing_finished = 2

-- Permanent object.nests for "scale" objects
alias has_resized = object.number[1]            -- must be local priority
alias scale_anchor = object.object[0]           -- ideally NOT local. if local, clients will spawn an unnecessary 2nd anchor for each green, purple, orange scale object, adding to object overloading on intense gametypes.

-- Permanent global numbers
alias local_tick_counter = global.number[2]     -- must be local priority
alias host_indicator = global.number[4]        -- must be local priority

-- Temporary numbers
alias cumulative_total = global.number[1]
alias recursion_count = global.number[7]
alias three_percent = global.number[8]
alias point_four_percent = global.number[11]

-- Temporary objects
alias temp_obj0 = global.object[1]

function exponential_scale_330x()
   if recursion_count > 0  then
      recursion_count -= 1
      three_percent = cumulative_total
      three_percent /= 33
      point_four_percent = cumulative_total
      point_four_percent /= 228
      cumulative_total += three_percent
      cumulative_total += point_four_percent
      exponential_scale_330x()
   end
end

-- Shared aliases
alias saved_player = global.player[3]    -- save current_player here before any nested "for each player" loop
alias launch_target = global.object[4]   -- object that launch() / trigger_4() pushes

-- Weapon Swap Aliases
alias weapon_swap_needed = player.number[5]
alias current_vehicle = player.object[0]
alias locator_owned = global.number[10]  -- 1 if a player already holds the target locator
alias rarity_roll = global.number[3]     -- scratch roll for rarer weapons

alias global_event_timer = global.timer[2]

-- Player Swap Aliases
alias swap_flag = global.number[9]
alias biped_a = global.object[6]
alias biped_b = global.object[7]
alias new_biped = global.object[8]

-- Vehicle Swap Aliases
alias first_vehicle = global.object[10]
alias second_vehicle = global.object[9]
alias vehicle_check = global.object[3]
alias longest_occupant = object.player[0]
alias swap_marker = player.object[2]

-- Vehicle Damage Resistance Aliases
alias vehicle_time = player.timer[3]
alias last_vehicle = player.object[3]

-- Hot Potato Oddball Aliases
alias potato_ball = global.object[12]
alias potato_holder = global.player[4] -- dies when the fuse runs out. no_player = no potato in play
alias potato_carrier = global.player[5] -- who is carrying the ball right now
alias potato_timer = global.timer[3]
alias potato_pass_cooldown = global.timer[4]
alias potato_pass_range = 15 -- tag distance in get_distance_to units (15 is roughly 4-5 feet, going by the last man distance code)

-- Gives potato_holder a new hot potato oddball
function give_potato()
  potato_ball = potato_holder.biped.place_at_me(skull, none, never_garbage_collect, 0, 0, 0, none)
  potato_holder.add_weapon(potato_ball)
  potato_ball.set_waypoint_icon(skull)
  potato_ball.set_waypoint_visibility(everyone)
  potato_ball.set_waypoint_priority(high)
end

-- Hot Potato Bomb Aliases
alias player_bomb = player.object[1] -- was player.object[0], which the weapon swap code overwrote every tick
alias bomb_timer = player.timer[0]
alias previous_tick_number = player.number[7]
alias bomb_temp = global.object[0]
alias carrier_biped = global.object[11]
alias population = global.number[10]

-- Mode aliases
alias mode_flag = player.number[6]
alias nerf_message_shown = player.number[2]

-- Gives current_player's biped the "Bomber" waypoint
function set_bomber_waypoint()
  current_player.biped.set_waypoint_icon(bomb)
  current_player.biped.set_waypoint_text("Bomber")
  current_player.biped.set_waypoint_visibility(everyone)
  current_player.biped.set_waypoint_priority(high)
end

-- Removes the "Bomber" waypoint from saved_player's biped.
-- If they're the last man, their skull waypoint is put back. Bullrunners get theirs back automatically next tick.
function clear_bomber_waypoint()
  saved_player.biped.set_waypoint_visibility(no_one)
  saved_player.biped.set_waypoint_text("")
  saved_player.biped.set_waypoint_icon(none)
  saved_player.biped.set_waypoint_priority(normal)
  if saved_player.number[1] == 1 then
    saved_player.biped.set_waypoint_icon(skull)
    saved_player.biped.set_waypoint_priority(high)
    saved_player.biped.set_waypoint_text("%n M", hud_player.number[4])
    saved_player.biped.set_waypoint_visibility(everyone)
  end
end

-- 1 in 4 chance per vehicle that it randomly swaps to another vehicle, with everyone inside moved into the new one.
-- The driver (the player who has been in the vehicle longest) is put in first so they keep the driver's seat.
-- Contains nested "for each player" loops, so it uses saved_player afterwards and must be the
-- last thing called for a player in its loop.
function trigger_6()
  first_vehicle = current_player.get_vehicle()
  if first_vehicle != no_object then
    saved_player = first_vehicle.longest_occupant
    if saved_player == no_player then
      saved_player = current_player
    end
    -- roll once per vehicle (on the driver's turn), so a full Warthog isn't three times as likely to swap
    if saved_player == current_player then
      global.number[7] = rand(4) -- 1 in 4. For 1 in N, use rand(N).
    end
    if saved_player == current_player and global.number[7] == 1 then
      -- mark everyone in the old vehicle with the driver's biped, then pull them out
      for each player do
        vehicle_check = current_player.get_vehicle()
        if vehicle_check == first_vehicle then
          current_player.swap_marker = saved_player.biped
          current_player.biped.detach()
        end
      end  -- current_player is no longer the driver after this; use saved_player
      first_vehicle.delete()
      global.number[7] = rand(10)
      if global.number[7] == 0 then
        first_vehicle = saved_player.biped.place_at_me(electric_cart, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 1 then
        first_vehicle = saved_player.biped.place_at_me(forklift, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 2 then
        first_vehicle = saved_player.biped.place_at_me(ghost, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 3 then
        first_vehicle = saved_player.biped.place_at_me(mongoose, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 4 then
        first_vehicle = saved_player.biped.place_at_me(oni_van, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 5 then
        first_vehicle = saved_player.biped.place_at_me(pickup_truck, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 6 then
        first_vehicle = saved_player.biped.place_at_me(revenant, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 7 then
        first_vehicle = saved_player.biped.place_at_me(semi_truck, none, none, 0, 0, 0, none)
      end
      if global.number[7] == 8 then
        global.number[7] = rand(4)
        if global.number[7] == 0 then
          first_vehicle = saved_player.biped.place_at_me(shade, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 1 then
          first_vehicle = saved_player.biped.place_at_me(shade_gun_anti_air, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 2 then
          first_vehicle = saved_player.biped.place_at_me(shade_gun_fuel_rod, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 3 then
          first_vehicle = saved_player.biped.place_at_me(shade_gun_plasma, none, none, 0, 0, 0, none)
        end
      end
      if global.number[7] == 9 then
        global.number[7] = rand(4)
        if global.number[7] == 0 then
          first_vehicle = saved_player.biped.place_at_me(warthog, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 1 then
          first_vehicle = saved_player.biped.place_at_me(warthog_turret, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 2 then
          first_vehicle = saved_player.biped.place_at_me(warthog_turret_gauss, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 3 then
          first_vehicle = saved_player.biped.place_at_me(warthog_turret_rocket, none, none, 0, 0, 0, none)
        end
      end
      first_vehicle.copy_rotation_from(saved_player.biped, true)
      -- driver goes in first so they get the driver's seat
      saved_player.force_into_vehicle(first_vehicle)
      first_vehicle.longest_occupant = saved_player
      -- then the passengers (anyone who doesn't fit is left standing next to it)
      for each player do
        if current_player.swap_marker == saved_player.biped then
          if current_player != saved_player then
            current_player.force_into_vehicle(first_vehicle)
          end
          -- a forced swap doesn't count as leaving the vehicle, so vehicle time (and damage resistance) carries over
          current_player.last_vehicle = first_vehicle
        end
        current_player.swap_marker = no_object
      end
    end
  end
end

-- Keeps track of who has been in each vehicle the longest, which trigger_6 treats as the driver.
-- Megalo can't tell which seat a player is in, but the first person into a vehicle is almost always the driver.
function track_drivers()
  second_vehicle = current_player.get_vehicle()
  if second_vehicle != no_object then
    saved_player = second_vehicle.longest_occupant
    vehicle_check = no_object
    if saved_player != no_player then
      vehicle_check = saved_player.get_vehicle()
    end
    -- the recorded driver has left (or there isn't one yet), so this player takes over
    if vehicle_check != second_vehicle then
      second_vehicle.longest_occupant = current_player
    end
  end
end

-- Gives the current player one random weapon (or nothing on a 0).
-- Only one target locator may be in play: locator_owned must be set by the caller before the first call.
-- If the locator is already owned, the roll is redone over every other result (no recursion, no nested loop).
function trigger_1()
	global.number[7] = rand(28) -- 0 to 27
	-- Rarer weapons: grenade launcher (6), rocket launcher (7), target locator (9), gravity hammer (11),
	-- plasma pistol (13), fuel rod gun (17), plasma repeater (19), focus rifle (21) get a 1 in 2 chance to be rerolled once.
	-- That makes each of them about 40% less likely than a normal weapon.
	-- For rarer still, change rand(2) to rand(3) and "== 0" to "!= 0" (2 in 3 reroll chance).
	if global.number[7] == 6 or global.number[7] == 7 or global.number[7] == 9 or global.number[7] == 11 or global.number[7] == 13 or global.number[7] == 17 or global.number[7] == 19 or global.number[7] == 21 then
		rarity_roll = rand(2)
		if rarity_roll == 0 then
			global.number[7] = rand(28)
		end
	end
	if global.number[7] == 9 and locator_owned == 1 then
		global.number[7] = rand(27) -- 0 to 26...
		if global.number[7] >= 9 then
			global.number[7] += 1 -- ...shifted to skip 9
		end
	end
	if global.number[7] == 0 then
		-- empty space here because the player has rolled no weapons :)
	end
	if global.number[7] == 1 then  --magnum
		global.object[5] = current_player.biped.place_at_me(magnum, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 2 then  --assault rifle
		global.object[5] = current_player.biped.place_at_me(assault_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 3 then  --dmr
		global.object[5] = current_player.biped.place_at_me(dmr, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 4 then  --shotgun
		global.object[5] = current_player.biped.place_at_me(shotgun, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 5 then  --sniper
		global.object[5] = current_player.biped.place_at_me(sniper_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 6 then  --grenade launcher
		global.object[5] = current_player.biped.place_at_me(grenade_launcher, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 7 then  --rocket launcher
		global.object[5] = current_player.biped.place_at_me(rocket_launcher, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 8 then  --spartan laser
		global.object[5] = current_player.biped.place_at_me(spartan_laser, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 9 then  --target locator (only reachable when nobody else has it)
		global.object[5] = current_player.biped.place_at_me(target_locator, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
		locator_owned = 1 -- nobody else can roll it this tick, including this player's second roll
	end
	if global.number[7] == 10 then  --energy sword
		global.object[5] = current_player.biped.place_at_me(energy_sword, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 11 then  --gravity hammer
		global.object[5] = current_player.biped.place_at_me(gravity_hammer, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 12 then  --spiker
		global.object[5] = current_player.biped.place_at_me(spiker, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 13 then  -- plasma pistol
		global.object[5] = current_player.biped.place_at_me(plasma_pistol, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 14 then  -- plasma rifle
		global.object[5] = current_player.biped.place_at_me(plasma_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 15 then  -- needle rifle
		global.object[5] = current_player.biped.place_at_me(needle_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 16 then  --needler
		global.object[5] = current_player.biped.place_at_me(needler, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 17 then  --fuel rod cannon
		global.object[5] = current_player.biped.place_at_me(fuel_rod_gun, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 18 then  -- concussion rifle
		global.object[5] = current_player.biped.place_at_me(concussion_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 19 then  --plasma repeater
		global.object[5] = current_player.biped.place_at_me(plasma_repeater, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 20 then  --plasma launcher
		global.object[5] = current_player.biped.place_at_me(plasma_launcher, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 21 then  --focus rifle
		global.object[5] = current_player.biped.place_at_me(beam_rifle, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 22 then  --unsc data core
		global.object[5] = current_player.biped.place_at_me(unsc_data_core, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 23 then  --covenant bomb
		global.object[5] = current_player.biped.place_at_me(covenant_bomb, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 24 then  --skull
		global.object[5] = current_player.biped.place_at_me(skull, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 25 then  -- flag pole
		global.object[5] = current_player.biped.place_at_me(flag, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 26 then  -- detached machine gun turret
		global.object[5] = current_player.biped.place_at_me(detached_machine_gun_turret, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
	if global.number[7] == 27 then  -- detached plasma cannon
		global.object[5] = current_player.biped.place_at_me(detached_plasma_cannon, none, none, 0, 0, 0, none)
		current_player.add_weapon(global.object[5])
	end
end


-- For each player, roll a 1 in 5 chance of them being teleported to another player.
-- The first player to roll becomes the anchor; the next player to roll is teleported to them.
function trigger_2()
  global.number[7] = rand(5)
  if global.number[7] == 1 and current_player.biped != no_object then
    -- forget an anchor whose biped no longer exists
    if swap_flag == 1 and biped_a == no_object then
      swap_flag = 0
    end
    -- select the second player and teleport them to the first player
    if swap_flag == 1 and biped_a != current_player.biped then
      biped_b = current_player.biped
      -- keep the player's species
      if biped_b.is_of_type(elite) then
        new_biped = biped_a.place_at_me(elite, none, never_garbage_collect, 0, 0, 0, none)
      end
      if not biped_b.is_of_type(elite) then
        new_biped = biped_a.place_at_me(spartan, none, never_garbage_collect, 0, 0, 0, kat)
      end
      current_player.set_biped(new_biped)
      -- carry an active bomb over to the new biped
      if current_player.player_bomb != no_object then
        current_player.player_bomb.detach()
        current_player.player_bomb.attach_to(new_biped, 0, 0, 0, relative)
        set_bomber_waypoint() -- the waypoint was on the old biped
      end
      biped_b.delete()
      swap_flag = 2 -- swap done; don't let this player immediately become the next anchor
      game.show_message_to(current_player, none, "Party time! You've been teleported to another player!")
    end
    -- select the first player (receiver node)
    if swap_flag == 0 then
      biped_a = current_player.biped
      swap_flag = 1
    end
    if swap_flag == 2 then
      swap_flag = 0
    end
  end
end


-- randomly scale the size of every player and most vehicles
-- Default: 65% to 135%. Warthogs: 75% to 135%. Falcons: 65% to 200%.
-- rand(N) gives 0 to N-1, so the range is (added number) to (added number + N - 1).
function trigger_3()
  if current_object.is_of_type(mongoose) or current_object.is_of_type(ghost) or current_object.is_of_type(pickup_truck) or current_object.is_of_type(revenant) or current_object.is_of_type(electric_cart) or current_object.is_of_type(forklift) or current_object.is_of_type(spartan) or current_object.is_of_type(elite) then
    global.number[7] = rand(71) -- 0 to 70
    global.number[7] += 65      -- 65% to 135%
    current_object.set_scale(global.number[7])
  end
  if current_object.is_of_type(warthog) then
    global.number[7] = rand(61) -- 0 to 60
    global.number[7] += 75      -- 75% to 135%
    current_object.set_scale(global.number[7])
  end
  if current_object.is_of_type(falcon) then
    global.number[7] = rand(136) -- 0 to 135
    global.number[7] += 65       -- 65% to 200%
    current_object.set_scale(global.number[7])
  end
end

-- 1 in 5 chance to fling the player (launch_target) up in the air
function trigger_4()
  global.number[7] = rand(5)
  if global.number[7] == 1 then
    launch_target.push_upward()
    launch_target.push_upward()
    launch_target.push_upward()
    launch_target.push_upward()
    launch_target.push_upward()
  end
end

-- 1 in 10 chance to put the player into "Bullrun" mode!
function trigger_5()
  global.number[7] = rand(10)
  if current_player.team == team[0] and global.number[7] == 1 then
    current_player.mode_flag = 1 --bullrun flag
    game.show_message_to(current_player, none, "Bullrun mode! Run for your life!")
    send_incident(bulltrue, current_player, all_players) -- this is supposed to play announcer "Bulltrue" line but it doesnt work
  end
end

-- 1 in 10 chance to put the player into "Ghost" mode!
function ghost_mode()
  global.number[7] = rand(10)
  -- the hot potato holder is skipped, since ghost mode strips weapons and would delete the oddball
  if current_player.team == team[0] and global.number[7] == 1 and current_player != potato_holder then
    current_player.mode_flag = 2 --ghost flag
    game.show_message_to(current_player, none, "You're a ghost! Hide from the Ghostbusters!")
    -- Remove players weapons and give them an energy sword
    current_player.biped.remove_weapon(secondary, true)
    current_player.biped.remove_weapon(primary, true)
    global.object[5] = current_player.biped.place_at_me(energy_sword, none, none, 0, 0, 0, none)
    current_player.add_weapon(global.object[5])
    -- skip this event's random weapon swap so the sword isn't taken away
    current_player.weapon_swap_needed = 0
  end
end

-- Ends the previous event's bullrun/ghost mode. Called at the start of every global event.
function clear_modes()
  if current_player.mode_flag == 1 then
    -- remove the bullrun waypoint (only for bullrunners, so the last man's skull is left alone)
    current_player.biped.set_waypoint_visibility(no_one)
    current_player.biped.set_waypoint_text("")
    current_player.biped.set_waypoint_icon(none)
    current_player.biped.set_waypoint_priority(normal)
  end
  current_player.mode_flag = 0
end

-- 1 in 10 chance to place an active bomb on the player (players who already have one are skipped)
function arm_bomb()
  if current_player.biped != no_object and current_player.player_bomb == no_object then
    global.number[7] = rand(10)
    if global.number[7] == 1 then
      -- spawn and attach bomb to player
      current_player.player_bomb = current_player.biped.place_at_me(bomb, none, none, 0, 0, 0, none)
      current_player.player_bomb.attach_to(current_player.biped, 0, 0, 0, relative)
      -- setup radius/shape of the bomb
      current_player.player_bomb.set_shape(cylinder, 20, 7, 7)
      current_player.player_bomb.set_shape_visibility(everyone)
      set_bomber_waypoint()
      -- inform player of what's going on
      game.show_message_to(current_player, none, "You've been given a live bomb!")
      game.show_message_to(current_player, none, "Stay near other players to survive the bomb!")
      send_incident(bomb_armed, all_players, all_players)
      -- arm the bomb
      current_player.bomb_timer.reset()
      current_player.previous_tick_number = current_player.bomb_timer
      current_player.bomb_timer.set_rate(-100%)
    end
  end
end

-- Handles the hot potato oddball.
-- Tag: the potato jumps to any other player who gets within potato_pass_range of the holder.
-- Picking up a dropped ball also makes you the holder. After a pass, there's a short cooldown
-- so it can't be tagged straight back. When the fuse runs out, the holder dies.
do
  -- no potato in play (or the holder left the game): clean up
  if potato_holder == no_player then
    potato_timer.set_rate(0%)
    potato_timer.reset()
    if potato_ball != no_object then
      potato_ball.delete()
    end
  end
  if potato_holder != no_player then
    -- the ball was destroyed (e.g. its holder was teleported): give the holder a new one
    if potato_ball == no_object and potato_holder.biped != no_object then
      give_potato()
    end
    if potato_ball != no_object then
      -- passing: whoever is carrying the ball now becomes the holder
      potato_carrier = no_player
      potato_carrier = potato_ball.try_get_carrier()
      if potato_carrier != no_player and potato_carrier != potato_holder then
        potato_holder = potato_carrier
        game.show_message_to(potato_holder, none, "You've got the hot potato! Pass it on!")
        game.play_sound_for(potato_holder, timer_beep, true)
        potato_pass_cooldown.reset()
        potato_pass_cooldown.set_rate(-100%)
      end
    end
    -- tag: the potato jumps to the first other player (alive, on foot) found close to the holder
    if potato_pass_cooldown.is_zero() and potato_holder.biped != no_object then
      potato_carrier = no_player
      for each player do
        vehicle_check = current_player.get_vehicle()
        if potato_carrier == no_player and current_player != potato_holder and current_player.biped != no_object and vehicle_check == no_object then
          global.number[7] = current_player.biped.get_distance_to(potato_holder.biped)
          if global.number[7] <= potato_pass_range then
            potato_carrier = current_player
          end
        end
      end
      if potato_carrier != no_player then
        if potato_ball != no_object then
          potato_ball.delete()
        end
        game.show_message_to(potato_holder, none, "Tag! You passed the hot potato!")
        potato_holder = potato_carrier
        give_potato()
        game.show_message_to(potato_holder, none, "Tag! You've got the hot potato! Pass it on!")
        game.play_sound_for(potato_holder, timer_beep, true)
        potato_pass_cooldown.reset()
        potato_pass_cooldown.set_rate(-100%)
      end
    end
    if potato_ball != no_object then
      potato_ball.set_waypoint_text("Hot Potato: %n", potato_timer)
    end
    -- times up: the holder dies
    if potato_timer.is_zero() then
      send_incident(bomb_detonated, all_players, all_players)
      if potato_ball != no_object then
        potato_ball.delete()
      end
      if potato_holder.biped != no_object then
        -- a ghost killed by the potato is killed & infected
        if potato_holder.number[0] == 0 then
          if potato_holder == global.player[2] then
            potato_holder.biped.set_waypoint_priority(normal)
            potato_holder.biped.set_waypoint_visibility(allies)
            potato_holder.biped.set_waypoint_text("")
            potato_holder.biped.set_waypoint_icon(none)
            global.number[0] = 0
          end
          potato_holder.number[0] = 1
          send_incident(inf_new_zombie, potato_holder, no_player)
        end
        potato_holder.biped.kill(false)
      end
      potato_holder = no_player
    end
  end
end

-- Handles an active bomb on a player
for each player do
  -- No bomb, or the carrier is dead: make sure the timer is stopped and any leftover bomb is removed
  if current_player.biped == no_object or current_player.player_bomb == no_object then
    current_player.bomb_timer.set_rate(0%)
    current_player.bomb_timer.reset()
    if current_player.player_bomb != no_object then
      current_player.player_bomb.delete()
      saved_player = current_player
      clear_bomber_waypoint()
    end
    current_player.player_bomb = no_object
  end
  -- check if timer is going down, play beeping sound as the timer progresses
  if current_player.player_bomb != no_object and current_player.bomb_timer < current_player.previous_tick_number then
    game.play_sound_for(current_player, timer_beep, true)
    game.show_message_to(current_player, none, "Bomb explodes in %n seconds", current_player.bomb_timer)
  end
  current_player.previous_tick_number = current_player.bomb_timer
  -- Bomb explodes: every other player in range dies. If nobody else is in range, the carrier dies (and gets infected) instead.
  if current_player.player_bomb != no_object and current_player.bomb_timer.is_zero() then
    current_player.bomb_timer.set_rate(0%)
    current_player.bomb_timer.reset()
    -- save everything we need before the nested player loop changes current_player
    saved_player = current_player
    bomb_temp = current_player.player_bomb
    carrier_biped = current_player.biped
    population = 0
    -- play bomb detonated sound
    send_incident(bomb_detonated, all_players, all_players)
    -- kill every other player inside the bomb's radius
    for each player do
      if current_player.biped != no_object and current_player.biped != carrier_biped and bomb_temp.shape_contains(current_player.biped) then
        population += 1
        current_player.biped.kill(false)
      end
    end
    -- remove the spent bomb (before any kill below, so it isn't left on the corpse)
    bomb_temp.delete()
    saved_player.player_bomb = no_object
    clear_bomber_waypoint()
    -- if no other players were nearby, the player with the bomb dies
    if population == 0 then
      -- a ghost who dies to their own bomb is infected (a script kill doesn't count as a "kill" for the normal infection rules)
      if saved_player.number[0] == 0 then
        -- if they were the last man, clear the last man waypoint and flag, same as the kill handler does
        if saved_player == global.player[2] then
          carrier_biped.set_waypoint_priority(normal)
          carrier_biped.set_waypoint_visibility(allies)
          carrier_biped.set_waypoint_text("")
          carrier_biped.set_waypoint_icon(none)
          global.number[0] = 0
        end
        saved_player.number[0] = 1
        send_incident(inf_new_zombie, saved_player, no_player)
      end
      carrier_biped.kill(false)
    end
  end
end



do
   script_widget[0].set_text("GHOSTBUSTER")
   script_widget[0].set_icon(noble)
   script_widget[1].set_text("GHOST")
   script_widget[1].set_icon(wheel)
   script_widget[3].set_text("%n GHOSTBUSTERS and %n GHOSTS", global.number[5], global.number[6])
   global.number[5] = 0
   global.number[6] = 0
end

-- Non-local triggers only run on the host, so only the host's (local-priority) copy is set to host_ID.
-- The 330x "on local" code below uses this to tell host and clients apart.
do
   host_indicator = host_ID
end

for each player do
   inline: if current_player.team == team[0] then 
      global.number[6] += 1
      script_widget[0].set_visibility(current_player, false)
      script_widget[1].set_visibility(current_player, true)
   end
   inline: if current_player.team == team[1] then 
      global.number[5] += 1
      script_widget[0].set_visibility(current_player, true)
      script_widget[1].set_visibility(current_player, false)
   end
   script_widget[3].set_visibility(current_player, true)
end

do
   global.number[3] = 0
   global.number[7] = -1
   for each player do
      global.number[7] += 1
      if current_player.number[0] == 1 then 
         global.number[3] += 1
      end
   end
   inline: if global.number[7] >= 6 then 
      global.number[3] -= 1
   end
   for each player randomly do
      if global.number[3] < script_option[0] and global.number[3] < global.number[7] and current_player.number[1] != 1 and current_player.number[0] != 1 then 
         current_player.number[0] = 1
         global.number[3] += 1
      end
   end
   for each player do
      if current_player.number[0] == 1 and current_player.team != team[1] then 
         send_incident(inf_new_zombie, current_player, no_player)
         current_player.team = team[1]
         current_player.apply_traits(script_traits[0])
         current_player.biped.kill(true)
      end
   end
end

-- Objective text (team[0] = ghosts, team[1] = ghostbusters)
for each player do
   current_player.timer[1].set_rate(-100%)
   if current_player.team == team[0] then 
      current_player.set_objective_text("Who you gon' call?")
   end
   if current_player.team == team[1] then 
      current_player.set_objective_text("Get those motherfucking ghosts.")
   end
end

for each player do
   if current_player.number[3] == 0 and current_player.timer[1].is_zero() then 
      send_incident(infection_game_start, current_player, no_player)
      current_player.number[3] = game.current_round
      current_player.number[3] += 1
      if game.current_round != 1 then
        game.show_message_to(current_player, none, "Round %n", current_player.number[3])
      end
      if game.current_round == 1 then
        game.show_message_to(current_player, none, "Round %n: Electric Boogaloo", current_player.number[3])
      end
   end
end

for each player do
   current_player.team = team[0]
   if current_player.number[0] == 1 then 
      current_player.team = team[1]
      current_player.apply_traits(script_traits[0])
   end
end

for each player do
   if current_player.killer_type_is(guardians | suicide | kill | betrayal | quit) then 
      current_player.number[1] = 0
      global.player[0] = current_player
      global.player[1] = no_player
      global.player[1] = current_player.try_get_killer()
      inline: if current_player.killer_type_is(kill) and global.player[0].number[0] == 1 and global.player[0].number[0] != global.player[1].number[0] then 
         global.player[1].score += script_option[7]
         send_incident(zombie_kill_kill, global.player[1], global.player[0])
      end
      inline: if current_player.killer_type_is(kill) and not global.player[1] == no_player and global.player[0].number[0] == 0 then 
         inline: if global.player[0] == global.player[2] then 
            global.player[0].biped.set_waypoint_priority(normal)
            global.player[0].biped.set_waypoint_visibility(allies)
            global.player[0].biped.set_waypoint_text("")
            global.player[0].biped.set_waypoint_icon(none)
            global.number[0] = 0
         end
         global.player[0].number[0] = 1
         send_incident(inf_new_infection, global.player[1], global.player[0])
         send_incident(infection_kill, global.player[1], global.player[0])
         global.player[1].script_stat[1] += 1
      end
      inline: if current_player.killer_type_is(suicide) then 
         global.player[1].score += script_option[8]
         if script_option[12] == 1 then 
            inline: if global.player[0] == global.player[2] then 
               global.player[0].biped.set_waypoint_priority(normal)
               global.player[0].biped.set_waypoint_visibility(allies)
               global.player[0].biped.set_waypoint_text("")
               global.player[0].biped.set_waypoint_icon(none)
               global.number[0] = 0
            end
            global.player[0].number[0] = 1
         end
      end
      if current_player.killer_type_is(betrayal) and global.player[0].number[0] == global.player[1].number[0] then 
         global.player[1].score += script_option[9]
      end
   end
end

if script_option[1] == 1 then 
   global.number[3] = 0
   if global.number[0] == 0 then 
      for each player do
         if not current_player.number[0] == 1 then 
            global.number[3] += 1
         end
      end
      if global.number[3] == 1 then 
         for each player do
            if not current_player.number[0] == 1 then 
               global.player[2] = current_player
               current_player.apply_traits(script_traits[1])
               current_player.biped.set_waypoint_icon(skull)
               current_player.biped.set_waypoint_priority(high)
               current_player.biped.set_waypoint_text("%n M", hud_player.number[4])
               current_player.number[1] = 1
               current_player.score += script_option[11]
               --send_incident(inf_last_man, current_player, all_players)
            end
         end
         global.number[0] = 1
      end
   end
end

-- Continuously apply last man traits
for each player do
   if current_player.number[1] == 1 then 
      current_player.apply_traits(script_traits[1])
   end
end

-- Check for cop victory (all robbers infected or dead)
do
   global.timer[1].set_rate(-100%)
   if global.timer[1].is_zero() then 
      global.number[3] = 0
      for each player do
         if current_player.number[0] == 0 then 
            global.number[3] += 1
         end
      end
      for each player do
         if global.number[3] == 1 and current_player.number[0] == 0 and current_player.killer_type_is(suicide) then 
            global.number[3] = 0
         end
      end
      if global.number[3] == 0 then 
         send_incident(infection_zombie_win, all_players, all_players)
         for each player do
            if current_player.number[1] != 1 and current_player.number[0] == 1 then 
               current_player.score += script_option[4]
            end
         end
         game.end_round()
      end
   end
end

-- Check for robber victory (time ran out with survivors)
if game.round_timer.is_zero() and game.round_time_limit > 0 then 
   global.number[3] = 0
   for each player do
      if current_player.number[0] == 0 then 
         global.number[3] += 1
      end
   end
   if not global.number[3] == 0 then 
      send_incident(infection_survivor_win, all_players, all_players)
      for each player do
         if current_player.number[0] == 0 then 
            current_player.score += script_option[5]
         end
      end
      game.end_round()
   end
end

-- Track survival time stat for robbers
for each player do
   if current_player.number[0] == 0 then 
      current_player.timer[2].set_rate(-100%)
      if current_player.timer[2].is_zero() then 
         current_player.script_stat[0] += 1
         current_player.timer[2].reset()
      end
   end
end

-- Calculate distance to last man for all players (in feet)
if global.number[0] == 1 then 
   for each player do
      current_player.number[4] = current_player.biped.get_distance_to(global.player[2].biped)
      current_player.number[4] *= 3
      current_player.number[4] /= 10
      current_player.number[4] &= 4095
   end
end


for each player do
   script_widget[2].set_visibility(current_player, true)
   global.object[2] = no_object
   global.object[2] = current_player.get_vehicle()
   inline: if global.object[2] != no_object then 
      script_widget[0].set_visibility(current_player, false)
      script_widget[1].set_visibility(current_player, false)
   end
   -- Scorpion & Wraith nerf for team[0]. Checked BEFORE the Falcon nerf, whose nested player loop changes current_player.
   if global.object[2] == no_object then
      current_player.nerf_message_shown = 0
   end
   if current_player.team == team[0] and global.object[2] != no_object then
      if global.object[2].is_of_type(scorpion) or global.object[2].is_of_type(wraith) then
         current_player.apply_traits(script_traits[3])
         if current_player.nerf_message_shown == 0 then
            game.show_message_to(current_player, none, "Your team can't use this")
            current_player.nerf_message_shown = 1
         end
      end
   end
   -- Falcon nerf (must stay last in this loop)
   inline: if global.object[2].is_of_type(falcon) and current_player.team == team[0] then 
      current_player.biped.health *= 0
      for each player do
         global.object[3] = no_object
         global.object[3] = current_player.get_vehicle()
         if global.object[2] == global.object[3] then 
            current_player.biped.health *= 0
         end
      end
      global.object[2].kill(true)
   end
end

do
   script_widget[2].set_text("something happens in %n", global_event_timer)
end

-- Remember each vehicle's driver (used by the vehicle swap)
for each player do
  track_drivers()
end

-- Vehicle damage resistance: the longer a player stays in one vehicle, the tougher they get.
-- Getting out (or dying) resets the time. Swaps forced by trigger_6 don't, because it updates last_vehicle.
-- Tiers use script traits set up in the gametype's trait settings:
--   script_traits[2] = 30+ seconds, script_traits[4] = 60+ seconds, script_traits[7] = 120+ seconds
for each player do
  vehicle_check = current_player.get_vehicle()
  if vehicle_check != current_player.last_vehicle then
    -- entered, left or changed vehicle on their own
    current_player.vehicle_time.reset()
    current_player.last_vehicle = vehicle_check
  end
  if vehicle_check == no_object then
    current_player.vehicle_time.set_rate(0%)
  end
  if vehicle_check != no_object then
    current_player.vehicle_time.set_rate(100%)
    if current_player.vehicle_time >= 30 and current_player.vehicle_time < 60 then
      current_player.apply_traits(script_traits[2])
    end
    if current_player.vehicle_time >= 60 and current_player.vehicle_time < 120 then
      current_player.apply_traits(script_traits[4])
    end
    if current_player.vehicle_time >= 120 then
      current_player.apply_traits(script_traits[7])
    end
  end
end

-- Global event timer triggers
do
  global_event_timer.set_rate(-100%)
  if global_event_timer.is_zero() then
    for each player do
      clear_modes() -- the previous event's bullrun/ghost mode ends here
      current_player.weapon_swap_needed = 1  -- flag the player as needing a weapon swap
      trigger_2() -- random chance to teleport one player to another
      launch_target = current_player.biped -- set after trigger_2 so a teleported player's new biped is used
      trigger_4() -- random chance to be flung
      trigger_5() -- random chance for robbers to enter "bullrun" mode
      ghost_mode() -- random chance for robbers to enter "ghost" mode (cancels this event's weapon swap)
      arm_bomb() -- random chance to get the hot potato bomb
    end
    -- trigger_6 has its own loop because it contains a nested player loop
    for each player do
      trigger_6() -- random chance to swap each vehicle (and everyone in it) with another
    end
    for each object do
      trigger_3() -- scale every player and most vehicles +- 35% randomly
    end
    -- Hot potato oddball: 1 in 4 chance to hand it to a random player (on foot and alive), if none is in play
    if potato_holder == no_player then
      global.number[7] = rand(7)
      if global.number[7] == 1 then
        for each player randomly do
          vehicle_check = current_player.get_vehicle()
          if potato_holder == no_player and current_player.biped != no_object and vehicle_check == no_object then
            potato_holder = current_player
            give_potato()
            potato_timer.reset()
            potato_timer.set_rate(-100%)
            potato_pass_cooldown.reset() -- short grace period before the first tag
            potato_pass_cooldown.set_rate(-100%)
            game.show_message_to(current_player, none, "Hot Potato! Tag someone before time runs out!")
            game.show_message_to(all_players, none, "Someone has the hot potato!")
            game.play_sound_for(all_players, timer_beep, true)
          end
        end
      end
    end
    global_event_timer.reset() -- reset the timer
  end
end
	
-- Weapon swap logic
do
  -- First, check whether someone who ISN'T about to swap already holds the target locator.
  -- This is done up front so trigger_1 never needs a nested player loop.
  locator_owned = 0
  for each player do
    current_player.current_vehicle = no_object
    current_player.current_vehicle = current_player.get_vehicle()
    if current_player.weapon_swap_needed == 0 or current_player.current_vehicle != no_object or current_player.biped == no_object then
      global.object[3] = current_player.get_weapon(primary)
      if global.object[3].is_of_type(target_locator) then
        locator_owned = 1
      end
      global.object[3] = current_player.get_weapon(secondary)
      if global.object[3].is_of_type(target_locator) then
        locator_owned = 1
      end
    end
  end
  -- If the player is in a vehicle (or dead), delay the weapons swap until they're out and alive (otherwise it doesnt work)
  for each player do
    -- the hot potato holder skips weapon swaps, since removing weapons would delete the oddball
    if current_player == potato_holder then
      current_player.weapon_swap_needed = 0
    end
    if current_player.weapon_swap_needed == 1 and current_player.current_vehicle == no_object and current_player.biped != no_object then
      -- Remove all weapons from the player
      current_player.biped.remove_weapon(secondary, true)
      current_player.biped.remove_weapon(primary, true)
      trigger_1() -- Give player their first weapon
      trigger_1() -- Give player their second weapon
      current_player.weapon_swap_needed = 0 -- reset weapon swap flag to false
    end
  end
end

-- Apply bullrun/ghost traits to players who have the flag (unless they are cops)
for each player do
  if current_player.team == team[0] then
    -- Bullrun Mode
    if current_player.mode_flag == 1 then
      current_player.apply_traits(script_traits[5])
      -- the "Bomber" waypoint takes priority while the player carries a bomb
      if current_player.player_bomb == no_object then
        current_player.biped.set_waypoint_icon(bullseye)
        current_player.biped.set_waypoint_visibility(everyone)
        current_player.biped.set_waypoint_priority(high)
        current_player.biped.set_waypoint_text("Bullrunner")
      end
    end
    -- Ghost Mode
    if current_player.mode_flag == 2 then
      current_player.apply_traits(script_traits[6])
    end
  end
  if current_player.team == team[1] and current_player.mode_flag != 0 then
    current_player.mode_flag = 0
    current_player.biped.set_waypoint_visibility(no_one)
    current_player.biped.set_waypoint_text("")
    current_player.biped.set_waypoint_icon(none)
    current_player.biped.set_waypoint_priority(normal)
  end
end

do
  global.number[7] = rand(32767)
  if global.number[7] == 50 then
    game.play_sound_for(all_players, timer_beep, true)
  end
end



on local: do
   -- Scale LOCAL tick counter. Hoping this will help scale work for late joiners. 
   local_tick_counter += 1
   ---- 330x Scale   January 2026 rewrite
   -- Part 1: create anchors
   -- Doesn't need to be on local if the anchor object is synced. Clients just need to know the nested anchor to be able to re-attach it. 
   -- having this on local might cause scaled objects to create 2 flag stands each (one spawned by host, one spawned by client), which is bad for performance reasons. Unconfirmed. I don't think this happens in practice.
   for each object with label "scale" do
      -- Purple team = No physics box. For 1% lights, sky seraphs.
      -- Green team = shadow caster
      if current_object.team == team[4] or current_object.team == team[2] then					-- or current_object.scale_anchor != no_object
         current_object.set_invincibility(1)
         -- second condition is to ensure only host creates a flag stand, tho I haven't confirmed if clients ever creat their own. They only would if there's some delay in host telling them the object's scale_anchor exists.
         if current_object.scale_anchor == no_object then         -- and global.object[4].is_of_type(hill_marker)
            current_object.scale_anchor = current_object.place_between_me_and(current_object, flag_stand, 0)
            current_object.scale_anchor.set_scale(1)			-- don't do this to the shadow casting warthog_turret; it pixelates the shadow.
            if current_object.team == team[2] then
               current_object.scale_anchor.delete()
               current_object.scale_anchor = current_object.place_between_me_and(current_object, heavy_barrier, 0)
               current_object.scale_anchor.set_scale(50)		-- if shadow is too pixelated, increase this value or remove it entirely.
               --if current_object.scale_anchor == no_object then			-- removed for space
                  --current_object.scale_anchor = current_object.place_between_me_and(current_object, warthog_turret, 0)	-- non-forge world maps
               --end
            end
         end
      end
      -- Orange team = No collision / hitbox (permeable to projectiles) and EITHER reduced ranged damage stress OR perfect rotation.
      -- Same effects for any other scale objects within its shape boundary (e.g. cosmic / red scale objects).
      if current_object.team == team[3] then
         alias sequence_object = temp_obj0
         sequence_object = current_object
         for each object with label "scale" do
            if sequence_object.shape_contains(current_object) or sequence_object == current_object then      -- 2nd condition: still include the object itself if it has no shape boundary.
               if current_object.scale_anchor == no_object then
                  -- NOT contained in orange shape: + reduced collision stress for reduced ranged damage bug. - Truncated rotation for clients.
                  --    client & host: attach to sound_emitter, so permeable to projectiles, reduced collision stress, but bad truncated rotation for clients
                  current_object.scale_anchor = current_object.place_between_me_and(current_object, sound_emitter_alarm_2, 0)
                  -- Contained in orange shape: + perfect rotation (e.g. for cosmic scale objects), - no ranged damage bug reduction.
                  --    host only: remove host anchor and hide instead. Client anchor remains
                  if host_indicator == host_ID and sequence_object.shape_contains(current_object) then
                     current_object.scale_anchor.delete()         -- warning: if scale_anchor ISN'T local priority, then host constantly blanking this here might cause clients to spam spawn anchors and crash IF this syncs.
                     current_object.set_hidden(1)
                  end
               end
            end
         end
      end   
   end
   -- Part 2: object resizing
   for each object with label "scale" do
      alias resized_object = current_object        -- if you want to set up scaling shape boundaries, set this to a different variable and adapt the below script to have something similar to the above orange team shape.
      alias sequence_object = current_object
      -- Late-spawning objects need to become scripted-data objects to resize
      -- Warning: late-spawning objects with a shape boundary containing themselves will fail to resize.
      if resized_object.has_resized == 0 and local_tick_counter > 10 and not resized_object.shape_contains(resized_object) then
         resized_object.has_resized = resizing_primed
      end
      -- Objects are present at round start or which have just been marked for scaling:
      if resized_object.has_resized == resizing_primed or local_tick_counter <= 10 then
         -- Boolean: scripted-data objects.
         if resized_object.has_resized == resizing_primed then
            resized_object.has_resized = resizing_finished
         end
         -- Boolean: free objects.        -- setting an object's shape doesn't make it a scripted-data object, so this is a free way to mark the object with a boolean to indicate that it has already scaled.
         if resized_object.team != team[3] then   -- condition needed to stop orange scale zones changing.
            resized_object.set_shape(cylinder, 100,100,100)
         end
         -- 330x exponential scale
         cumulative_total = 100
         recursion_count = sequence_object.spawn_sequence
         if sequence_object.spawn_sequence < 0 then 
            recursion_count *= 5
            cumulative_total += recursion_count
            -- Downsizing
            if sequence_object.spawn_sequence <= -20 then 
               recursion_count = sequence_object.spawn_sequence
               recursion_count += 201
               if sequence_object.spawn_sequence == -20 then
                  cumulative_total = 1
                  --if resized_object.is_of_type(grid) then
                  if resized_object.team != team[4] then       -- only purple team doesn't hide when 1% scale. Set lights to purple team to maintain their illumination.
                     resized_object.set_hidden(true)
                  end
               end
            end
         end
         -- Upsizing
         if sequence_object.spawn_sequence < -20 or sequence_object.spawn_sequence > 0 then 
            cumulative_total = 100
            -- COSMIC scale.
            if sequence_object.team == team[0] then
               cumulative_total = 32732
               recursion_count = 0   -- already at max; growing further overflows past 32767 and wraps negative
            end
            exponential_scale_330x()
         end
         -- Locally detach scaled objects from their anchor (flag stand, warthog turret, sound emitter) before scaling and copying rotation. Necessary for scale to update for clients. Reattaches straight after.
         -- Semi redundant condition. Only needed if something has "scale" label while get attached to something else, such as a carried weapon or armor ability, within first 10 ticks.
         --if resized_object.scale_anchor != no_object then      -- this includes purple (flag stand), green (shadow caster), and orange-shaped-contained (sound emitter on client)
         resized_object.detach()
         --end
         resized_object.set_scale(cumulative_total)
         resized_object.copy_rotation_from(resized_object, false)
         resized_object.attach_to(resized_object.scale_anchor, 0,0,0,relative)         -- might need to only do this where resized_object.scale_anchor != no_object, not sure. Need to check.
      end
   end
end
