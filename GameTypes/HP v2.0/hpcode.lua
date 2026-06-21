--[[
Hot Pursuit v2.0
Authors: (and the work that they've done)
Demonatorpro: No scripting, but he created the original gametype.
Benjamin Cottrill/Ma7ter Chief: Scorpion & Wraith Nerf, Grenades delay, 
                                Extra Seats
Cadence7w7: Extra Seats
Dummy Dragon123: Falcon Nerf, Status HUD, Last man standing distance calculator
                 Team-balancing code
Karly: Extra Seats
Rabids MagicMan: Creator of the 330x Scaling that this gametype uses
NukeOhio: Speedometer

The code for this gametype makes a good faith effort to follow 
these style guides:
Roblox Lua Style Guide: 
https://roblox.github.io/lua-style-guide/
DavidJCobb's RVT Best Practices: 
https://sopitive.github.io/MegaloDocs/rvt/script/best-practices.html
The most notable depature from the recommended style is that I have used
snake_case instead of PascalCase, because it matches the style of RVT's
built-in functions.

Changes since v1.96
- Transport/Scout Warthogs now have 4 passenger seats instead of 1
- Warthogs with turrets now have a 2nd passenger seat, very much 
  alike to the new "Campaign Evolved" hog
- Forklifts can now carry a 2nd player as a passenger on the back, just 
  incase you left your forklift certification at home ;)
- Robbers now spawn with one grenade, and get another 3 after a ~7 second delay
- The developer text has been moved away from the splash 
  screen and to something thats less in your face
--]]


-- VARIABLE DECLARATIONS
-- This could be cleaned up by using temporaries
-- Last man standing flag
declare global.number[0] with network priority low
-- used for 330x scaling
declare global.number[2] with network priority low
-- Reusable, currently used for various calculations
declare global.number[3] with network priority local
-- Inf
declare global.number[4] with network priority local
-- Cop population count
declare global.number[5] with network priority low
-- Robber population count 
declare global.number[6] with network priority low
-- used for 330x scaling
declare global.number[7] = 0
-- sequential number counter for assigning IDs to vehicles and extra seats                       
declare global.number[8] = 1        
             
declare global.number[9]
-- reference for attached vehicles
declare global.object[1] with network priority low
-- Identify the players current vehicle (swap to temp?)
declare global.object[2] with network priority low
-- Identify other players in the same vehicle as global.object[2] 
declare global.object[3] with network priority low
-- Unused 
declare global.object[4] with network priority low
   
declare global.object[5] with network priority low
-- flag for whether or not a vehicle has anything attached to it
declare object.number[0] with network priority low

declare object.number[1] with network priority low
-- Persistant ID to link an extra vehicle seat with its vehicle
declare object.number[2] with network priority low
-- Used for scaling extra seats (this value represents it's scale %)
declare object.number[3]                 
-- Temp player reference (victim) (make temp?)   
declare global.player[0] with network priority local
-- Temp player reference (killer) (make temp?)
declare global.player[1] with network priority local
-- Last man standing player reference
declare global.player[2] with network priority low
-- Round end check delay timer
declare global.timer[1] = 10           
-- time in seconds before robbers are given grenades      
declare global.timer[2] = 18
-- Infection status (0=survivor/robber, 1=infected/cop)
declare player.number[0] with network priority low
declare player.number[2] with network priority low
-- Last man standing flag for this player
declare player.number[1] with network priority low
-- Round announcement tracker
declare player.number[3] with network priority low
-- Distance to last man (in feet)
declare player.number[4] with network priority low
-- flag that indicates if grenades have been given
declare player.number[5]
-- indicates which extra seat the player is using
declare player.number[6] with network priority low
-- attached_id of the vehicle the player was most recently in
declare player.number[7] with network priority low
-- start screen text
declare player.timer[2] = 1
-- how often in seconds before the text widget initially lists the developers
declare player.timer[3] = 15
declare player.object[0] with network priority low

-- ALIASES
alias client_ID = 0

alias resizing_primed = 1
alias resizing_finished = 2
-- local priority; tracks scale state per object
alias has_resized = object.number[1]  
-- the prop this object is attached to for scaling      
alias scale_anchor = object.object[0]

-- local; increments each frame on local block
alias local_tick_counter = global.number[7] 
-- local; 1 on host, 0 on clients
alias host_indicator = global.number[0]     

-- local; running total in exponential scale loop
alias cumulative_total = global.number[2] 
-- local; iteration counter for scale recursion  
alias recursion_count = global.number[9]   
-- local; ~3% correction per scale iteration 
alias three_percent = global.number[10]    
-- local; ~0.44% fine correction per scale iteration
alias point_four_percent = global.number[11] 

-- timer for delay before robbers are given grenades
alias grenade_timer = global.timer[2]       

-- numerical counter for assigning IDs to vehicles and extra seats
alias id_counter = global.number[8]   
-- object specific storage for numerical IDs                
alias attached_id = object.number[2]       
-- indicates which extra seat the player is using           
alias occupied_extra_seat_id = player.number[6]    
-- stores the attachedID for the vehicle they were most recently using   
alias recent_vehicle_attached_id = player.number[7]
-- used for scaling the pickup/interactive objects used for extra seats
alias seat_scale = object.number[3]


-- HUD SETUP
-- Creates HUD widgets to show team icons and population
do
  script_widget[0].set_text("Police Officer")
  script_widget[0].set_icon(noble)
  script_widget[1].set_text("Robber")
  script_widget[1].set_icon(wheel)
  script_widget[3].set_text("%n COPS and %n ROBBERS", global.number[5], global.number[6])
  global.number[5] = 0
  global.number[6] = 0
end

-- Shows the player's current team icon and counts population of both teams
for each player do
  -- If player is on robber team
  inline: if current_player.team == team[0] then 
    global.number[6] += 1
    script_widget[0].set_visibility(current_player, false)
    script_widget[1].set_visibility(current_player, true)
  end
  -- If player is on cop team
  inline: if current_player.team == team[1] then 
    global.number[5] += 1
    script_widget[0].set_visibility(current_player, true)
    script_widget[1].set_visibility(current_player, false)
  end
  -- Show team population widget
  script_widget[3].set_visibility(current_player, true) 
end


-- INFECTION SETUP
-- If there`s less than 6 players, only one player will be selected, 
-- otherwise two players will be selected
do
  global.number[3] = 0
  global.number[4] = -1
  for each player do
    global.number[4] += 1
	-- Count number of infected
    if current_player.number[0] == 1 then 
      global.number[3] += 1
    end
  end
  inline: if global.number[4] >= 6 then
    global.number[3] -= 1
  end
  -- Select players to infect if under the limit
  for each player randomly do
    if global.number[3] < script_option[0] and global.number[3] < global.number[4] and current_player.number[1] != 1 and current_player.number[0] != 1 then
      current_player.number[0] = 1
      global.number[3] += 1
    end
  end
  -- Apply infection to selected players
  for each player do
    if current_player.number[0] == 1 and current_player.team != team[1] then
      send_incident(inf_new_zombie, current_player, no_player)
      current_player.team = team[1]
      current_player.apply_traits(script_traits[0])
      current_player.biped.kill(true)
    end
  end
end

-- Shows objective text at the start of the game
for each player do
  current_player.timer[1].set_rate(-100%)
  current_player.timer[3].set_rate(-100%)
  for each player do
    if current_player.team == team[0] then
      current_player.set_objective_text("Run from the Cops!")
    end
  end
  for each player do
    if current_player.team == team[1] then
      current_player.set_objective_text("Catch the Robbers!")
    end
  end
end


-- ROUND MESSAGES
-- Display round number message between rounds
for each player do
  if current_player.number[3] == 0 and current_player.timer[1].is_zero() then
    send_incident(infection_game_start, current_player, no_player)
    current_player.number[3] = game.current_round
    current_player.number[3] += 1
    game.show_message_to(current_player, none, "Round %n", current_player.number[3])
  end
  if current_player.timer[3].is_zero() then
    current_player.timer[3] = 300
	-- Possibly move this to local? It seems to send these messages in
	-- a random order when played on a dedicated server
    game.show_message_to(current_player, none, "Demonatorpro, Karly, Dummy Dragon123")
    game.show_message_to(current_player, none, "Ma7ter Chief, Cadence7w7")
    game.show_message_to(current_player, none, "This gametype was created by:")
  end
end


-- TEAM ASSIGNMENT
-- Assign players to correct teams based on infection status
for each player do
  current_player.team = team[0]
  if current_player.number[0] == 1 then
    current_player.team = team[1]
    current_player.apply_traits(script_traits[0])
  end
end


-- DEATH AND SCORING
-- Handle player deaths and scoring
for each player do
  if current_player.killer_type_is(guardians | suicide | kill | betrayal | quit) then
    current_player.number[1] = 0
    global.player[0] = current_player
    global.player[1] = no_player
    global.player[1] = current_player.try_get_killer()
    if current_player.killer_type_is(kill) and global.player[0].number[0] == 1 and global.player[0].number[0] != global.player[1].number[0] then
      global.player[1].score += script_option[7]
      send_incident(zombie_kill_kill, global.player[1], global.player[0])
    end
    if current_player.killer_type_is(kill) and script_option[2] == 1 and global.player[0].number[0] == 1 and global.player[0].number[0] != global.player[1].number[0] and global.player[1].number[2] == 1 then
      global.player[1].score += script_option[6]
    end
    if current_player.killer_type_is(kill) and not global.player[1] == no_player and global.player[0].number[0] == 0 then
      global.player[0].number[0] = 1
      send_incident(inf_new_infection, global.player[1], global.player[0])
      send_incident(infection_kill, global.player[1], global.player[0])
      global.player[1].score += script_option[10]
      global.player[1].script_stat[1] += 1
    end
    if current_player.killer_type_is(suicide) then
      global.player[1].score += script_option[8]
      if script_option[12] == 1 then
        global.player[0].number[0] = 1
      end
    end
    if current_player.killer_type_is(betrayal) and global.player[0].number[0] == global.player[1].number[0] then
      global.player[1].score += script_option[9]
    end
  end
end


-- LAST MAN STANDING
if script_option[1] == 1 then
  global.number[3] = 0
  if global.number[0] == 0 then
    for each player do
      if not current_player.number[0] == 1 then
        global.number[3] += 1
      end
    end
    -- Only one robber left: activate LMS
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
          send_incident(inf_last_man, current_player, all_players)
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


-- VICTORY CHECKS
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
		  -- give score to all players on the winning team
          --current_player.score += script_option[4]
          -- has a bug atm where if zombies win, the LMS also gets a point
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
	    -- give score to all players on the winning team
        --current_player.score += script_option[5] 
      end
    end
    game.end_round()
  end
end


-- STAT TRACKING
-- Increment the zombie population counter when a player becomes infected
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


-- SPEEDOMETER
do
  script_widget[2].set_text("%n MPH", hud_player.number[2])
end


-- VEHICLE HANDLING
-- Vehicle handling and speedometer display
for each player do
  -- Hide speedometer by default
  script_widget[2].set_visibility(current_player, false) 
  global.object[2] = no_object
  global.object[2] = current_player.get_vehicle()
  -- If in vehicle, show speedometer
  inline: if global.object[2] != no_object then
    script_widget[2].set_visibility(current_player, true)
    script_widget[0].set_visibility(current_player, false)
    script_widget[1].set_visibility(current_player, false)
  end
  -- Prevent robbers from using Falcon (explodes)
  inline: if global.object[2].is_of_type(falcon) and current_player.team == team[0] then
    current_player.biped.health *= 0 -- Kill player
    current_player.score += script_option[7]
    -- Kill all passengers
    for each player do
      global.object[3] = no_object -- delete this line? need to test
      global.object[3] = current_player.get_vehicle()
      if global.object[2] == global.object[3] then
        current_player.biped.health *= 0
      end
    end
	-- Destroy vehicle
    global.object[2].kill(true) 
  end
  -- Prevent robbers from using Scorpion or Wraith
  if current_player.team == team[0] and global.object[2].is_of_type(scorpion) or global.object[2].is_of_type(wraith) then
    -- Disable vehicle usage (re-enables on its own)
    current_player.apply_traits(script_traits[3]) 
    game.show_message_to(current_player, none, "Your team can't use this")
  end
end


-- GRENADE TIMER
-- Start the timer counting down
if not grenade_timer.is_zero() then
  grenade_timer.set_rate(-100%)
end

-- When timer expires, give grenades to eligible players
if grenade_timer.is_zero() then
  grenade_timer.set_rate(0%)
  for each player do
    if current_player.team == team[0] and current_player.number[5] == 0 then
      current_player.frag_grenades += 3
      current_player.number[5] = 1
    end
  end
end

-- FUNCTION: exponentialScale330x
-- Used for cosmic/exponential scaling of forge objects
function exponentialScale330x()
  if recursion_count > 0 then
    recursion_count -= 1
    three_percent = cumulative_total
    three_percent /= 33
    point_four_percent = cumulative_total
    point_four_percent /= 228
    cumulative_total += three_percent
    cumulative_total += point_four_percent
    exponentialScale330x()
  end
end

alias seat_item = allocate temporary object
alias extraseat = allocate temporary object
alias this_vehicle = allocate temporary object
alias player_weapon = allocate temporary object
alias player_weapon_id = allocate temporary number
alias player_current_vehicle = allocate temporary object


-- LOCAL BLOCK
-- Part 1: Scale anchors | Part 2: Apply scale | Part 3: Speedometer
on local: do

  local_tick_counter += 1

  -- PART 1: CREATE SCALE ANCHORS
  for each object with label "scale" do
    if current_object.team == team[4] or current_object.team == team[2] then
      current_object.set_invincibility(1)
      if current_object.scale_anchor == no_object then
        current_object.scale_anchor = current_object.place_between_me_and(current_object, flag_stand, 0)
        current_object.scale_anchor.set_scale(1)
        if current_object.team == team[2] then
          current_object.scale_anchor.delete()
          current_object.scale_anchor = current_object.place_between_me_and(current_object, heavy_barrier, 0)
          current_object.scale_anchor.set_scale(50)
        end
      end
    end
    if current_object.team == team[3] then
      alias sequence_object = global.object[8]
      sequence_object = current_object
      for each object with label "scale" do
        if sequence_object.shape_contains(current_object) or sequence_object == current_object then
          current_object.set_hidden(1)
          if host_indicator == client_ID then
            current_object.set_hidden(0)
            if current_object.scale_anchor == no_object then
              current_object.scale_anchor = current_object.place_between_me_and(current_object, sound_emitter_alarm_2, 0)
            end
          end
        end
      end
    end
  end

  -- PART 2: APPLY SCALE
  for each object with label "scale" do
    alias resized_object = current_object
    alias sequence_object = current_object
    if resized_object.has_resized == 0 and local_tick_counter > 10 and not resized_object.shape_contains(resized_object) or resized_object.team == team[3] then
      resized_object.has_resized = resizing_primed
    end
    if resized_object.has_resized == resizing_primed or local_tick_counter <= 10 then
      if resized_object.has_resized == resizing_primed then
        resized_object.has_resized = resizing_finished
      end
      if resized_object.team != team[3] then
        resized_object.set_shape(cylinder, 100, 100, 100)
      end
      cumulative_total = 100
      recursion_count = sequence_object.spawn_sequence
      if sequence_object.spawn_sequence < 0 then
        recursion_count *= 5
        cumulative_total += recursion_count
        if sequence_object.spawn_sequence <= -20 then
          recursion_count = sequence_object.spawn_sequence
          recursion_count += 201
          if sequence_object.spawn_sequence == -20 then
            cumulative_total = 1
            if resized_object.team != team[4] then
              resized_object.set_hidden(true)
            end
          end
        end
      end
      if sequence_object.spawn_sequence < -20 or sequence_object.spawn_sequence > 0 then
        cumulative_total = 100
        if sequence_object.team == team[0] then
          cumulative_total = 32732
        end
        exponentialScale330x()
      end
      resized_object.detach()
      resized_object.set_scale(cumulative_total)
      resized_object.copy_rotation_from(resized_object, false)
      resized_object.attach_to(resized_object.scale_anchor, 0, 0, 0, relative)
    end
  end

  -- PART 3: PLAYER SPEED CALCULATION
  -- 1 feet per second = 0.68mph
  for each player do
    current_player.number[2] = current_player.biped.get_speed()
    current_player.number[2] *= 17
    current_player.number[2] /= 25
    current_player.number[2] &= 4095
  end

  -- Extra Seat Scaling
  for each object do
    if current_object.seat_scale != 0 then
      current_object.set_scale(current_object.seat_scale)
    end
  end

end


-- EXTRA SEAT FUNCTIONS

-- FUNCTION: placeBackseatPickup
-- Places the backseat attachment for warthogs
function placeBackseatPickup()
  seat_item = this_vehicle.place_at_me(covenant_power_core, none, none, 0, 0, 0, none)
  seat_item.attach_to(this_vehicle, -10, 0, 5, relative)
  seat_item.seat_scale = 1
  seat_item.attached_id = this_vehicle.attached_id
end

-- FUNCTION: placeRightseatPickup
-- Places the rightseat attachment for warthogs
function placeRightseatPickup()
  seat_item = this_vehicle.place_at_me(bomb, none, none, 0, 0, 0, none)
  seat_item.attach_to(this_vehicle, -5, -4, 7, relative)
  seat_item.seat_scale = 1
  seat_item.attached_id = this_vehicle.attached_id
end

-- FUNCTION: placeLeftseatPickup
-- Places the leftseat attachment for warthogs
function placeLeftseatPickup()
  seat_item = this_vehicle.place_at_me(covenant_bomb, none, none, 0, 0, 0, none)
  seat_item.attach_to(this_vehicle, -5, 4, 7, relative)
  seat_item.seat_scale = 1
  seat_item.attached_id = this_vehicle.attached_id
end

-- FUNCTION: placeForkliftseatPickup
-- Places the backseat attachment for forklifts
function placeForkliftseatPickup()
  seat_item = this_vehicle.place_at_me(covenant_power_core, none, none, -1, 0, 0, none)
  seat_item.attach_to(this_vehicle, -8, 0, 5, relative)
  seat_item.seat_scale = 1
  seat_item.attached_id = this_vehicle.attached_id
end

-- FUNCTION: spawnExtraSeat
-- A bunch of workaround code that attaches the player to a vehicle as the
-- passenger, which is typically impossible.
function spawnExtraSeat()
  alias temp_npc_biped = allocate temporary object
  alias temp_player_biped = allocate temporary object
  for each object do
    -- Warthog branch
    if current_object.is_of_type(warthog) and current_object.attached_id == player_weapon.attached_id then
      temp_npc_biped = current_player.biped.place_at_me(spartan, none, never_garbage_collect, 0, 0, 0, kat)
      player_weapon_id = player_weapon.attached_id
      player_weapon.delete()
      extraseat.attached_id = current_object.attached_id
	  -- If the extra seat is a revenant, delete it's turret
      if extraseat.is_of_type(revenant) then
        for each object do
          alias d = allocate temporary number
          d = current_object.get_distance_to(extraseat)
          if d == 0 and current_object != extraseat and not current_object.is_of_type(spartan) and not current_object.is_of_type(elite) then
            current_object.delete()
          end
        end
      end
      temp_player_biped = current_player.biped
      current_player.set_biped(temp_npc_biped)
      current_player.force_into_vehicle(extraseat)
      current_player.set_biped(temp_player_biped)
      current_player.force_into_vehicle(extraseat)
      temp_npc_biped.delete()
      extraseat.copy_rotation_from(current_object, true)
    end
    -- Forklift branch
    if current_object.is_of_type(forklift) and current_object.attached_id == player_weapon.attached_id then
      temp_npc_biped = current_player.biped.place_at_me(spartan, none, never_garbage_collect, 0, 0, 0, kat)
      player_weapon_id = player_weapon.attached_id
      player_weapon.delete()
      extraseat.attached_id = current_object.attached_id
      temp_player_biped = current_player.biped
      current_player.set_biped(temp_npc_biped)
      current_player.force_into_vehicle(extraseat)
      current_player.set_biped(temp_player_biped)
      current_player.force_into_vehicle(extraseat)
      temp_npc_biped.delete()
      extraseat.copy_rotation_from(current_object, true)
    end
  end
end

-- FUNCTION: cleanupMongooseWarthogSeat
-- Handles exit cleanup for any seat that uses a mongoose as
-- the extra seat object on a warthog (seats 1 and 5).
function cleanupMongooseWarthogSeat()
  for each object do
    if current_object.is_of_type(warthog) and current_object.attached_id == current_player.recent_vehicle_attached_id then
      for each object do
        if current_object.is_of_type(mongoose) and current_object.attached_id == current_player.recent_vehicle_attached_id then
          current_object.delete()
        end
      end
      this_vehicle = current_object
      placeBackseatPickup()
      current_player.occupied_extra_seat_id = 0
      current_player.recent_vehicle_attached_id = 0
    end
  end
end

-- FUNCTION: cleanupRevenantSeat
-- Handles exit cleanup for either revenant side seat (seats 2 and 3) on a warthog.
-- Deletes the revenant when no other players remain in it.
-- Caller is responsible for calling the correct place*Pickup function after this.
function cleanupRevenantSeat()
  for each object do
    if current_object.is_of_type(warthog) and current_object.attached_id == current_player.recent_vehicle_attached_id then
      for each object do
        if current_object.is_of_type(revenant) and current_object.attached_id == current_player.recent_vehicle_attached_id then
          alias this_revenant = global.object[2]
          this_revenant = current_object
          alias occupants = allocate temporary number
          occupants = 0
          for each player do
            player_current_vehicle = current_player.get_vehicle()
            if player_current_vehicle == this_revenant then
              occupants += 1
            end
          end
          if occupants == 0 then
            current_object.delete()
          end
        end
      end
      this_vehicle = current_object
      current_player.occupied_extra_seat_id = 0
      current_player.recent_vehicle_attached_id = 0
    end
  end
end

-- FUNCTION: cleanupForkliftSeat
-- Handles exit cleanup for the forklift back seat (seat 4).
function cleanupForkliftSeat()
  for each object do
    if current_object.is_of_type(forklift) and current_object.attached_id == current_player.recent_vehicle_attached_id then
      for each object do
        if current_object.is_of_type(mongoose) and current_object.attached_id == current_player.recent_vehicle_attached_id then
          current_object.delete()
        end
      end
      this_vehicle = current_object
      placeForkliftseatPickup()
      current_player.occupied_extra_seat_id = 0
      current_player.recent_vehicle_attached_id = 0
    end
  end
end


-- EXTRA SEAT INITIALIZATION
-- Attaches seats to vehicles as they first spawn
for each object do
  alias distance = allocate temporary number
  alias dx = allocate temporary number
  -- Scout hog attachments
  if current_object.is_of_type(warthog) and current_object.attached_id == 0 then
    this_vehicle = current_object
	-- all warthogs start with an invalid ID
    current_object.attached_id = -1 
    distance = 9999
	-- If distance = 0 it is a warthog with a turret
	-- If distance > 0 then it is a scout warthog.
    for each object do
      if current_object.is_of_type(warthog_turret) or current_object.is_of_type(warthog_turret_gauss) or current_object.is_of_type(warthog_turret_rocket) then
        dx = current_object.get_distance_to(this_vehicle)
        if dx < distance then
          distance = dx
        end
      end
    end
    -- Warthogs with no turrets are scout hogs and get 3 extra seats
    if distance != 0 then
      this_vehicle.attached_id = id_counter
      id_counter += 1
      placeBackseatPickup()
      placeLeftseatPickup()
      placeRightseatPickup()
    end
    -- Warthogs with turrets get one seat 
	-- (attached_id is +1000 to differentiate from transport hogs)
    if distance == 0 then
      this_vehicle.attached_id = id_counter
      this_vehicle.attached_id += 1000
      id_counter += 1
      placeBackseatPickup()
    end
  end
  -- Forklift attachments
  if current_object.is_of_type(forklift) and current_object.attached_id == 0 then
    this_vehicle = current_object
    this_vehicle.attached_id = id_counter
    id_counter += 1
    placeForkliftseatPickup()
  end
end


-- EXTRA SEAT ENTRY DETECTION
-- Detects if player is trying to enter an extra seat, and puts them there.
-- If you're trying to add even more seats, the bulk of your rewrites will be here
for each player do
  player_weapon = current_player.get_weapon(primary)
  -- Back seat (power core pickup)
  if player_weapon.is_of_type(covenant_power_core) and player_weapon.attached_id > 0 then
    extraseat = current_player.biped.place_at_me(mongoose, none, none, 0, 0, 0, none)
    spawnExtraSeat()
    for each object do
      -- Transport warthog back seat
      if current_object.is_of_type(warthog) and current_object.attached_id == player_weapon_id and current_object.attached_id < 1000 then
        current_player.occupied_extra_seat_id = 1
        extraseat.attach_to(current_object, -6, 1, 4, relative)
        extraseat.seat_scale = 50
      end
      -- Turret warthog back seat
      if current_object.is_of_type(warthog) and current_object.attached_id == player_weapon_id and current_object.attached_id > 1000 then
        current_player.occupied_extra_seat_id = 5
        extraseat.attach_to(current_object, -7, 0, 3, relative)
        extraseat.seat_scale = 50
      end
      -- Forklift back seat
      if current_object.is_of_type(forklift) and current_object.attached_id == player_weapon_id then
        current_player.occupied_extra_seat_id = 4
        extraseat.attach_to(current_object, -3, 0, 5, relative)
        extraseat.seat_scale = 70
      end
    end
  end
  -- Right seat (bomb pickup)
  if player_weapon.is_of_type(bomb) and player_weapon.attached_id > 0 then
    extraseat = current_player.biped.place_at_me(revenant, none, none, 0, 0, 0, none)
    spawnExtraSeat()
    current_player.occupied_extra_seat_id = 2
    for each object do
      if current_object.is_of_type(warthog) and current_object.attached_id == player_weapon_id then
        extraseat.attach_to(current_object, -6, 0, 4, relative)
        extraseat.seat_scale = 1
      end
    end
  end
  -- Left seat (covenant bomb pickup)
  if player_weapon.is_of_type(covenant_bomb) and player_weapon.attached_id > 0 then
    extraseat = current_player.biped.place_at_me(revenant, none, none, 0, 0, 0, none)
    spawnExtraSeat()
    current_player.occupied_extra_seat_id = 3
    for each object do
      if current_object.is_of_type(warthog) and current_object.attached_id == player_weapon_id then
        extraseat.face_toward(current_object, -91, 42, 0)
        extraseat.attach_to(current_object, -6, 0, 5, relative)
        extraseat.seat_scale = 1
      end
    end
  end
end


-- VEHICLE ID TRACKING
-- Store the vehicle ID that a player is/was most recently using
for each player do
  player_current_vehicle = current_player.get_vehicle()
  if player_current_vehicle != no_object and player_current_vehicle.attached_id > 0 then
    current_player.recent_vehicle_attached_id = player_current_vehicle.attached_id
  end
end


-- EXTRA SEAT EXIT DETECTION
-- Detect when an extra seat has no occupying player and clean it up
for each player do
  player_current_vehicle = current_player.get_vehicle()
  if current_player.occupied_extra_seat_id > 0 and player_current_vehicle == no_object then
    -- Scout Warthog, Back Seat
    if current_player.occupied_extra_seat_id == 1 then
      cleanupMongooseWarthogSeat()
    end
    -- Scout Warthog, Right Seat
    if current_player.occupied_extra_seat_id == 2 then
      cleanupRevenantSeat()
      placeRightseatPickup()
    end
    -- Scout Warthog, Left Seat
    if current_player.occupied_extra_seat_id == 3 then
      cleanupRevenantSeat()
      placeLeftseatPickup()
    end
    -- Forklift, Back Seat
    if current_player.occupied_extra_seat_id == 4 then
      cleanupForkliftSeat()
    end
    -- Turret Warthog, Back Seat
    if current_player.occupied_extra_seat_id == 5 then
      cleanupMongooseWarthogSeat()
    end
  end
end


-- current_player.occupied_extra_seat_id values:
-- 1: Scout Warthog, Back Seat
-- 2: Scout Warthog, Right Seat
-- 3: Scout Warthog, Left Seat
-- 4: Forklift, Back Seat
-- 5: Turret Warthog, Back Seat


