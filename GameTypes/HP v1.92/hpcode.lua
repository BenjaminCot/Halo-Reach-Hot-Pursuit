
declare global.number[0] with network priority low
declare global.number[1] with network priority local
declare global.number[2] with network priority low
declare global.number[3] with network priority local
declare global.number[4] with network priority local
declare global.number[5] with network priority low
declare global.number[6] with network priority low
declare global.object[0] with network priority low
declare global.object[1] with network priority local
declare global.object[2] with network priority low
declare global.object[3] with network priority low
declare global.player[0] with network priority local
declare global.player[1] with network priority local
declare global.player[2] with network priority low
declare global.timer[0] = script_option[3]
declare global.timer[1] = 10
declare player.number[0] with network priority low
declare player.number[1] with network priority low
declare player.number[2] with network priority low = 1
declare player.number[3] with network priority low
declare player.number[4] with network priority low
declare player.team[0] with network priority low
declare player.team[1] with network priority low
declare player.timer[0] = 1
declare player.timer[1] = 5
declare player.timer[2] = 1
declare object.number[0] with network priority low
declare object.timer[0] = script_option[3]

do
   script_widget[0].set_text("Police Officer")
   script_widget[0].set_icon(noble)
   script_widget[1].set_text("Robber")
   script_widget[1].set_icon(wheel)
   script_widget[3].set_text("%n COPS and %n ROBBERS", global.number[5], global.number[6])
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
         current_player.set_objective_text("Run from the Cops!\tHot Pursuit edited by Karly & Ma7ter Chief")
      end
   end
   for each player do
      if current_player.team == team[1] then 
         current_player.set_objective_text("Catch the Robbers!\tHot Pursuit edited by Karly & Ma7ter Chief")
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
               send_incident(inf_last_man, current_player, all_players)
            end
         end
         global.number[0] = 1
      end
   end
end

for each player do
   if current_player.number[1] == 1 then 
      current_player.apply_traits(script_traits[1])
   end
end

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

for each player do
   if current_player.number[0] == 0 then 
      current_player.timer[2].set_rate(-100%)
      if current_player.timer[2].is_zero() then 
         current_player.script_stat[0] += 1
         current_player.timer[2].reset()
      end
   end
end

if global.number[0] == 1 then 
   for each player do
      current_player.number[4] = current_player.biped.get_distance_to(global.player[2].biped)
      current_player.number[4] *= 3
      current_player.number[4] /= 10
      current_player.number[4] &= 4095
   end
end

do
   script_widget[2].set_text("%n MPH", hud_player.number[2])
end

for each player do
   script_widget[2].set_visibility(current_player, false)
   global.object[2] = no_object
   global.object[2] = current_player.get_vehicle()
   inline: if global.object[2] != no_object then 
      script_widget[2].set_visibility(current_player, true)
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

on local: do
   for each player do
      current_player.number[2] = current_player.biped.get_speed()
      current_player.number[2] *= 17
      current_player.number[2] /= 25
      current_player.number[2] &= 4095
   end
end
