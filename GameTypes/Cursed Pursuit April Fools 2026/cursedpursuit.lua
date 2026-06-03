-- Cursed Pursuit
-- This can be cleaned up with use of temporaries
declare global.number[0] with network priority low -- lms flag, not reusable
declare global.number[1] with network priority low -- Counter for number of occupants in a vehicle
declare global.number[2] with network priority low -- FREE, NOT USED
declare global.number[3] with network priority local 
declare global.number[4] with network priority local
declare global.number[5] with network priority low 
declare global.number[6] with network priority low -- Not reusable
declare global.number[7] with network priority low -- Used for rand number rolls, reusable
declare global.number[8] with network priority low -- Flag for if someone has the target locator, i dont think its reusable but look into it
declare global.number[9] with network priority low -- storage for swapping one player with another, not reusable
declare global.number[10] with network priority low -- storage for swapping one player with another, not reusable (might not even be needed with this implementation?)
declare global.number[11] with network priority low -- random swap flag
declare global.object[0] with network priority low
declare global.object[1] with network priority local
declare global.object[2] with network priority low
declare global.object[3] with network priority low
declare global.object[4] with network priority low --player biped
declare global.object[5] with network priority low --random weapon
declare global.object[6] with network priority low
declare global.object[7] with network priority low
declare global.object[8] with network priority low
declare global.object[9] with network priority low -- second vehicle used for vehicle swapping, reusable
declare global.object[10] with network priority low -- first vehicle
declare global.player[0] with network priority local
declare global.player[1] with network priority local
declare global.player[2] with network priority low
declare global.timer[0] = script_option[3]
declare global.timer[1] = 10
declare global.timer[2] = 90
declare player.number[0] with network priority low
declare player.number[1] with network priority low
declare player.number[2] with network priority low = 1
declare player.number[3] with network priority low
declare player.number[4] with network priority low
declare player.number[5] with network priority low -- Per player flag for weapons swaps, not reuseable
declare player.number[6] with network priority low
declare player.team[0] with network priority low
declare player.team[1] with network priority low
declare player.timer[0] = 1
declare player.timer[1] = 5
declare player.timer[2] = 1
declare player.timer[3] = 90
declare object.number[0] with network priority low
declare object.timer[0] = script_option[3]

-- TODO:
--Fix ALL players getting bullrun when it rolls (maybe fixed, try it)
--lower the bullrunner percentage (done)
--bullrunner mode persists after death (maybe fixed?)
--add vehicle swapping (works in single player, needs playtest

--========== ALIASES ==========--
-- Weapon Swap Aliases
alias weapon_swap_needed = player.number[5]
alias player_has_target_locator = global.number[8]
alias local_event_timer = player.timer[3]
alias global_event_timer = global.timer[2]

-- Player Swap Aliases
alias swap_flag = global.number[9]
alias swap_flag2 = global.number[10]
alias biped_a = global.object[6]
alias biped_b = global.object[7]
alias temp_biped = global.object[8]

-- Vehicle Swap Aliasas
alias first_vehicle = global.object[10]
alias second_vehicle = global.object[9]
alias occupants = global.number[2]


-- Bullrun aliases
alias bullrun_announce_flag = global.number[1]

-- 1 in 10 chances the players vehicle randomly swaps to another vehicle
function trigger_6()
  occupants = 0
  global.number[7] = rand(9)
  if global.number[7] == 1 then
    first_vehicle = current_player.get_vehicle()
    if first_vehicle != no_object then
      for each player do
        second_vehicle = current_player.get_vehicle()
        if first_vehicle == second_vehicle then
          occupants += 1
        end
      end  -- closes 'for each player do'
      if occupants == 1 then
        current_player.biped.detach()
        first_vehicle.delete()
        global.number[7] = rand(9)
        if global.number[7] == 0 then
          first_vehicle = current_player.biped.place_at_me(electric_cart, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 1 then
          first_vehicle = current_player.biped.place_at_me(forklift, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 2 then
          first_vehicle = current_player.biped.place_at_me(ghost, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 3 then
          first_vehicle = current_player.biped.place_at_me(mongoose, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 4 then
          first_vehicle = current_player.biped.place_at_me(oni_van, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 5 then
          first_vehicle = current_player.biped.place_at_me(pickup_truck, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 6 then
          first_vehicle = current_player.biped.place_at_me(revenant, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 7 then
          first_vehicle = current_player.biped.place_at_me(semi_truck, none, none, 0, 0, 0, none)
        end
        if global.number[7] == 8 then
          global.number[7] = rand(3)
          if global.number[7] == 0 then
            first_vehicle = current_player.biped.place_at_me(shade, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 1 then
            first_vehicle = current_player.biped.place_at_me(shade_gun_anti_air, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 2 then
            first_vehicle = current_player.biped.place_at_me(shade_gun_fuel_rod, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 3 then
            first_vehicle = current_player.biped.place_at_me(shade_gun_plasma, none, none, 0, 0, 0, none)
          end
        end
        if global.number[7] == 9 then
          global.number[7] = rand(3)
          if global.number[7] == 0 then
            first_vehicle = current_player.biped.place_at_me(warthog, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 1 then
            first_vehicle = current_player.biped.place_at_me(warthog_turret, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 2 then
            first_vehicle = current_player.biped.place_at_me(warthog_turret_gauss, none, none, 0, 0, 0, none)
          end
          if global.number[7] == 3 then
            first_vehicle = current_player.biped.place_at_me(warthog_turret_rocket, none, none, 0, 0, 0, none)
          end
        end
        first_vehicle.copy_rotation_from(current_player.biped, true)
        current_player.force_into_vehicle(first_vehicle)
      end  
    end 
  end  
end 

-- This function will give the player one random weapon, with an extra flag where only one player can have the target locator at a time
-- (There is nothing preventing multiple players from rolling the target locator, but if someone already has it, they will be forced to re-roll)
function trigger_1()
	global.number[7] = rand(27) 
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
	if global.number[7] == 6 then  --grenade laucnher
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
	if global.number[7] == 9 then  --target locator
		if global.number[8] == 1 then -- if someone already has it, reroll for a new weapon
			trigger_1()
		end
		if global.number[8] == 0 then -- if no player has the target locator
			global.object[5] = current_player.biped.place_at_me(target_locator, none, none, 0, 0, 0, none)
			current_player.add_weapon(global.object[5])
			global.number[8] = 1
		end
	end
	if global.number[7] == 10 then  --eenrgy sword
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


--For each player, roll a 1 in 5 chance of them being teleported to another player
function trigger_2()
  global.number[7] = rand(4) 
  if global.number[7] == 1 then
    if swap_flag == 1 then -- select the second player and teleport them to the first player
      biped_a = biped_a.place_at_me(spartan, none, never_garbage_collect, 0, 0, 0, kat)
      biped_b = current_player.biped
      current_player.set_biped(biped_a)
      biped_b.delete()
      swap_flag = 0
	  game.show_message_to(current_player, none, "You've been teleported to another player!")
    end
    if swap_flag == 0 then --select the first player (receiver node)
      biped_a = current_player.biped
      swap_flag = 1
    end
  end
end


-- randomly scale the size of every vehicle or player +- 35%
function trigger_3()
  if current_object.is_of_type(warthog) or current_object.is_of_type(mongoose) or current_object.is_of_type(ghost) or current_object.is_of_type(pickup_truck) or current_object.is_of_type(revenant) or current_object.is_of_type(electric_cart) or current_object.is_of_type(falcon) or current_object.is_of_type(forklift) or current_object.is_of_type(spartan) or current_object.is_of_type(elite)then
    global.number[7] = rand(70)
    global.number[7] += 65
    current_object.set_scale(global.number[7])
  end
end

-- 1 in 5 chance to fling the player up in the air with a random amount of force and on a random vector
function trigger_4()
  global.number[7] = rand(4)
  if global.number[7] == 1 then
    global.object[4].push_upward()
	global.object[4].push_upward()
	global.object[4].push_upward()
	global.object[4].push_upward()
	global.object[4].push_upward()
  end
end

-- 1 in 10 chance to put in the player into "Bullrun" mode!
function trigger_5()
  global.number[7] = rand(9)
  if current_player.team == team[0] and global.number[7] == 1 then
    current_player.number[6] = 1
	game.show_message_to(current_player, none, "Bullrun mode! Run for your life!")
    send_incident(bulltrue, current_player, all_players) 
  end
end

do
   script_widget[0].set_text("PIG")
   script_widget[0].set_icon(noble)
   script_widget[1].set_text("DONUT")
   script_widget[1].set_icon(wheel)
   script_widget[3].set_text("%n PIGS and %n DONUTS", global.number[5], global.number[6])
   global.number[5] = 0
   global.number[6] = 0
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
   global.number[4] = -1
   for each player do
      global.number[4] += 1
      if current_player.number[0] == 1 then 
         global.number[3] += 1
      end
   end
   inline: if global.number[4] >= 6 then 
      global.number[3] -= 1
   end
   for each player randomly do
      if global.number[3] < script_option[0] and global.number[3] < global.number[4] and current_player.number[1] != 1 and current_player.number[0] != 1 then 
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

for each player do
   current_player.timer[1].set_rate(-100%)
   for each player do
      if current_player.team == team[0] then 
         current_player.set_objective_text("They're after your donuts fucking run AAAaaaAAAAAaaaaaAAAAAAAAAaaaaaaaaaaaaaaaaaa!!!!")
      end
   end
   for each player do
      if current_player.team == team[1] then 
         current_player.set_objective_text("No Mercy. Catch the donuts. At all costs!")
      end
   end
end

for each player do
   if current_player.number[3] == 0 and current_player.timer[1].is_zero() then 
      send_incident(infection_game_start, current_player, no_player)
      current_player.number[3] = game.current_round
      current_player.number[3] += 1
      game.show_message_to(current_player, none, "Round %n", current_player.number[3])
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
   if current_player.team == team[0] and global.object[2].is_of_type(scorpion) or global.object[2].is_of_type(wraith) then 
      current_player.apply_traits(script_traits[3])
      game.show_message_to(current_player, none, "Your team can't use this")
   end
end

do
   if global.object[2] == no_object then 
     script_widget[2].set_text("something happens in %n", global_event_timer)
   end
end

-- Global event timer triggers
do
  global_event_timer.set_rate(-100%)
  if global_event_timer.is_zero() then
    for each player do
	  global.object[4] = current_player.biped
	  current_player.weapon_swap_needed = 1  -- flag the player as needing a weapon swap
	  trigger_2() -- random chance to teleport one player to another
	  trigger_4() -- random chance to be flung
	  trigger_5() -- random chance for robbers to enter "bullrun" mode
	  trigger_6() -- random chance to swap the players vehicle with another
	end
	for each object do
	  trigger_3() -- scale every player and most vehicles +- 15% randomly
	end
	global_event_timer.reset() -- reset the timer
  end
end
	
-- Weapon swap logic
for each player do  
  -- Check if the player is in a vehicle or not
  current_player.object[0] = no_object
  current_player.object[0] = current_player.get_vehicle()
  
  -- If the player is in a vehicle, delay the weapons swap until after they exit the vehicle (otherwise it doesnt work)
  if current_player.number[5] == 1 and current_player.object[0] == no_object then
    -- Remove all weapons from the player
    current_player.biped.remove_weapon(secondary, true)
    current_player.biped.remove_weapon(primary, true)
    global.object[4] = current_player.biped -- select player's biped (used by trigger_1)
	player_has_target_locator = 0 -- reset the target locator flag (only one player may have the target locator)
    trigger_1() -- Give player their first weapon
    trigger_1() -- Give player their second weapon
    current_player.weapon_swap_needed = 0 -- reset weapon swap flag to false
  end
end

-- Apply bullrun traits to players with the bullrunner flag (unless they are cops)
for each player do
  if current_player.number[6] == 1 and current_player.team == team[0] then
	current_player.apply_traits(script_traits[5])
	current_player.biped.set_waypoint_icon(bullseye)
	global.player[0].biped.set_waypoint_visibility(everyone)
    current_player.biped.set_waypoint_priority(high)
	current_player.biped.set_waypoint_text("Bullrunner")
  end
  if current_player.number[6] == 1 and current_player.team == team[1] then -- remove bullrunner effect if player becomes a cop
    current_player.number[6] = 0
	current_player.biped.set_waypoint_visibility(allies)
	current_player.biped.set_waypoint_text("")
    current_player.biped.set_waypoint_icon(none)
	current_player.biped.set_waypoint_priority(normal)
  end
end

