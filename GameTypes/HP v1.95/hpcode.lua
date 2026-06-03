-- Variable declaration
--This could be cleaned up by using temporaries
declare global.number[0] with network priority low    -- Last man standing flag
declare global.number[2] with network priority low    -- used for 330x scaling
declare global.number[3] with network priority local  -- Temporary counter for various calculations
declare global.number[4] with network priority local  -- Player count tracker
declare global.number[5] with network priority low    -- Cop count
declare global.number[6] with network priority low    -- Robber count
declare global.number[7] = 0					      -- flag for vehicle invincibility
declare global.object[2] with network priority low    -- Temp vehicle reference
declare global.object[3] with network priority low    -- Temp vehicle reference for comparison
declare global.player[0] with network priority local  -- Temp player reference (victim)
declare global.player[1] with network priority local  -- Temp player reference (killer)
declare global.player[2] with network priority low    -- Last man standing player reference
declare global.timer[1] = 10                          -- Round end check delay timer'
declare global.timer[2] = 18					      -- time in seconds before robbers are given grenades
declare player.number[0] with network priority low    -- Infection status (0=survivor/robber, 1=infected/cop)
declare player.number[1] with network priority low    -- Last man standing flag for this player
declare player.number[3] with network priority low    -- Round announcement tracker
declare player.number[4] with network priority low    -- Distance to last man (in feet)
declare player.number[5]							  -- flag that indicates if grenades have been given
declare player.timer[2] = 1                           


--TODO FIX
--No nades ever, except for alpha cops | MAYBE FIXED, TRY IT
--Kill barriers and soft kill barriers deleted vehicles, often teleporting players back to spawn | NOT YET FIXED
--Anyone in a vehicle took no damage (did someone copy my script or something? lol) | NOT YET FIXED
--Non-driven vehicles still despawn in barriers (so no spades on Hotwheels) | NOT YET FIXED
--Scoring is completely fucked somehow (everyone scores 1 at the end of a round no matter what, no one scores for anything else) | NOT YET FIXED



-- ALIASES
alias client_ID = 0

alias resizing_primed = 1
alias resizing_finished = 2
alias has_resized = object.number[1]          -- local priority; tracks scale state per object
alias scale_anchor = object.object[0]         -- the prop this object is attached to for scaling

alias local_tick_counter = global.number[7]   -- local; increments each frame on local block
alias host_indicator = global.number[0]       -- local; 1 on host, 0 on clients

alias cumulative_total = global.number[2]     -- local; running total in exponential scale loop
alias recursion_count = global.number[9]      -- local; iteration counter for scale recursion
alias three_percent = global.number[10]       -- local; ~3% correction per scale iteration
alias point_four_percent = global.number[11]  -- local; ~0.44% fine correction per scale iteration

alias grenade_timer = global.timer[2] --timer for delay before robbers are given grenades

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
   inline: if current_player.team == team[0] then -- If player is on robber team
      global.number[6] += 1
      script_widget[0].set_visibility(current_player, false)
      script_widget[1].set_visibility(current_player, true)
   end
   inline: if current_player.team == team[1] then     -- If player is on cop team
      global.number[5] += 1
      script_widget[0].set_visibility(current_player, true) 
      script_widget[1].set_visibility(current_player, false)
   end
   script_widget[3].set_visibility(current_player, true) -- Show team population widget
end

-- Selects random players to be infected
--[[ If there`s less than 6 players, only one player will be selected, 
     otherwise two players will be selected]]--
do
   global.number[3] = 0
   global.number[4] = -1
   for each player do
      global.number[4] += 1
      if current_player.number[0] == 1 then           -- Count number of infected
         global.number[3] += 1
      end
   end
   inline: if global.number[4] >= 6 then
      global.number[3] -= 1
   end
   for each player randomly do
      -- Select players to infect if under the limit
      if global.number[3] < script_option[0] and global.number[3] < global.number[4] and current_player.number[1] != 1 and current_player.number[0] != 1 then 
         current_player.number[0] = 1
         global.number[3] += 1
      end
   end
   for each player do -- Apply infection to selected players
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
   for each player do
      if current_player.team == team[0] then
         current_player.set_objective_text("Run from the Cops!\r\nHot Pursuit edited by Dummy Dragon123,\r\nKarly & Ma7ter Chief")
      end
   end
   for each player do
      if current_player.team == team[1] then
         current_player.set_objective_text("Catch the Robbers!\r\nHot Pursuit edited by Dummy Dragon123,\r\nKarly & Ma7ter Chief")
      end
   end
end

-- Display round number message between rounds
for each player do
   if current_player.number[3] == 0 and current_player.timer[1].is_zero() then 
      send_incident(infection_game_start, current_player, no_player)
      current_player.number[3] = game.current_round   -- Track which round message was shown
      current_player.number[3] += 1
      game.show_message_to(current_player, none, "Round %n", current_player.number[3])
   end
end

-- Assign players to correct teams based on infection status
for each player do
   current_player.team = team[0]                      -- Default to robber team
   if current_player.number[0] == 1 then
      current_player.team = team[1]
      current_player.apply_traits(script_traits[0])
   end
end

-- Handle player deaths and scoring
for each player do
   if current_player.killer_type_is(guardians | suicide | kill | betrayal | quit) then 
      current_player.number[1] = 0                    -- Clear last man flag on death
      global.player[0] = current_player               -- Store victim
      global.player[1] = no_player
      global.player[1] = current_player.try_get_killer() -- Get killer
      
      -- Scoring for player kills
	  inline: if current_player.killer_type_is(kill) and global.player[0].number[0] == 0 and global.player[1].number[0] == 1 then 
		 global.player[1].score += script_option[7]
		 send_incident(zombie_kill_kill, global.player[1], global.player[0])
	  end
      
      -- Robber gets infected when killed by cop
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
      
      -- Suicide penalty
      inline: if current_player.killer_type_is(suicide) then 
         global.player[1].score += script_option[8]
         if script_option[12] == 1 then               -- If suicide infects option enabled
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
      
      -- Betrayal (team kill) penalty
      if current_player.killer_type_is(betrayal) and global.player[0].number[0] == global.player[1].number[0] then 
         global.player[1].score += script_option[9]   -- Betrayal score penalty
      end
   end
end

-- Last man standing mechanic
if script_option[1] == 1 then 
   global.number[3] = 0
   if global.number[0] == 0 then
      for each player do
         if not current_player.number[0] == 1 then 
            global.number[3] += 1
         end
      end
      if global.number[3] == 1 then                   -- Only one robber left / activate lms
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

-- Set up speedometer widget
do
   script_widget[2].set_text("%n MPH", hud_player.number[2])
end

-- Vehicle handling and speedometer display
for each player do
   script_widget[2].set_visibility(current_player, false) -- Hide speedometer by default
   global.object[2] = no_object
   global.object[2] = current_player.get_vehicle()   -- Check if in vehicle
   inline: if global.object[2] != no_object then      -- If in vehicle
      script_widget[2].set_visibility(current_player, true) -- Show speedometer
      script_widget[0].set_visibility(current_player, false) -- Hide team widgets
      script_widget[1].set_visibility(current_player, false)
   end
   
   -- Prevent robbers from using Falcon (explodes)
   inline: if global.object[2].is_of_type(falcon) and current_player.team == team[0] then 
      current_player.biped.health *= 0                -- Kill player
	  current_player.score += script_option[7]
      for each player do                              -- Kill all passengers
         global.object[3] = no_object
         global.object[3] = current_player.get_vehicle()
         if global.object[2] == global.object[3] then 
            current_player.biped.health *= 0
         end
      end
      global.object[2].kill(true)                     -- Destroy vehicle
   end
   
   -- Prevent robbers from using Scorpion or Wraith
   if current_player.team == team[0] and global.object[2].is_of_type(scorpion) or global.object[2].is_of_type(wraith) then 
      current_player.apply_traits(script_traits[3])   -- Disable vehicles usage (re-enables on its own)
      game.show_message_to(current_player, none, "Your team can't use this")
   end
   
end

-- Start the timer counting down
if not grenade_timer.is_zero() then
    grenade_timer.set_rate(-100%)
end

-- When timer expires, give grenades to eligible players
if grenade_timer.is_zero() then
    grenade_timer.set_rate(0%)
    for each player do
        if current_player.team == team[0] and current_player.number[5] == 0 then
            current_player.frag_grenades += 2
            current_player.number[5] = 1
        end
    end
end

-- Code to make later joiners become infected after the timer expires
-- This is for hot pursuit classic
-- also this doesnt even work yet lol
--for each player do
--	if current_player.team == team[0] and current_player.biped == no_object and current_player.grenade_timer.is_zero() then
--		current_player.team = team[1]
--		current_player.grenade_timer.set_rate(0%)
--	end
--end

-- ============================================================
-- FUNCTION: exponential_scale_330x
-- ============================================================
function exponential_scale_330x()
   if recursion_count > 0 then
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

-- ==================================================================
-- ON LOCAL BLOCK
-- Part 1: Scale anchors | Part 2: Apply scale | Part 3: Speedometer
-- ==================================================================
on local: do

   local_tick_counter += 1

   -- ---- PART 1: CREATE SCALE ANCHORS ----
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

   -- ---- PART 2: APPLY SCALE ----
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
            exponential_scale_330x()
         end
         resized_object.detach()
         resized_object.set_scale(cumulative_total)
         resized_object.copy_rotation_from(resized_object, false)
         resized_object.attach_to(resized_object.scale_anchor, 0, 0, 0, relative)
      end
   end
   

end