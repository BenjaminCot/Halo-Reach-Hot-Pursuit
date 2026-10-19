--[[
Upgrade vehicles to have an operable scorpion cannon

This is a snippet from Cursed Hot Pursuit 2026 (Halloween version)
It rolls a 1 in 12 chance for every vehicle, to attach a scorpion cannon to it.
If the roll is successful, a donor scorpion is spawned and its main cannon is detached.
The donor scorpion is then deleted and the cannon gets attached to the vehicle.
Also has handling for vehicles that are destroyed.
--]]
declare global.number[10] with network priority low -- distance, reusable
declare global.object[13] with network priority low -- vehicle being upgraded
declare global.object[14] with network priority low -- donor vehicle, reusable
declare global.object[15] with network priority low -- part being attached, reusable
declare object.number[0] with network priority low  -- upgrade type
declare object.object[1] with network priority low  -- attached part (on vehicles)
declare object.object[2] with network priority low  -- owning vehicle (on parts)

-- aliases
alias upgrade_type = object.number[0]       -- on vehicles: 0 = none, 2 = scorpion cannon. On attached parts: 10
alias upgrade_attachment = object.object[1]
alias upgrade_owner = object.object[2]
alias upgrade_vehicle = global.object[13]
alias upgrade_donor = global.object[14]
alias upgrade_part = global.object[15]
alias upgrade_distance = global.number[10]

-- Finds the gun on upgrade_donor (the first other object at exactly the same spot),
-- detaches it and stores it in upgrade_part. The caller deletes the donor.
function take_donor_gun()
  upgrade_part = no_object
  for each object do
    upgrade_distance = current_object.get_distance_to(upgrade_donor)
    if upgrade_part == no_object and upgrade_distance == 0 and current_object != upgrade_donor and current_object != upgrade_vehicle and not current_object.is_of_type(scorpion_turret_anti_infantry) then
      upgrade_part = current_object
    end
  end
  if upgrade_part != no_object then
    upgrade_part.detach()
  end
end

-- 1 in 12 chance for current_object (if it's a vehicle) to get a scorpion cannon.
-- Each vehicle can only be upgraded once.
function try_vehicle_upgrade()
  if current_object.upgrade_type == 0 then
    if current_object.is_of_type(warthog) or current_object.is_of_type(mongoose) or current_object.is_of_type(ghost) or current_object.is_of_type(pickup_truck) or current_object.is_of_type(revenant) or current_object.is_of_type(electric_cart) or current_object.is_of_type(falcon) or current_object.is_of_type(forklift) or current_object.is_of_type(oni_van) or current_object.is_of_type(semi_truck) or current_object.is_of_type(banshee) then
      global.number[7] = rand(12) -- 1 in 12. For 1 in N, use rand(N).
      if global.number[7] == 1 then
        upgrade_vehicle = current_object
        upgrade_part = no_object
        -- spawn a donor scorpion above the vehicle, steal its cannon, then delete it
        upgrade_donor = upgrade_vehicle.place_at_me(scorpion, none, none, 0, 0, 14, none)
        take_donor_gun()
        -- ghosts and revenants sit lower, so mount 1 unit lower on them
        if upgrade_vehicle.is_of_type(ghost) or upgrade_vehicle.is_of_type(revenant) then
          upgrade_part.attach_to(upgrade_vehicle, 0, 0, 7, relative)
        end
        if not upgrade_vehicle.is_of_type(ghost) and not upgrade_vehicle.is_of_type(revenant) then
          upgrade_part.attach_to(upgrade_vehicle, 0, 0, 8, relative)
        end
        upgrade_donor.delete()
        upgrade_vehicle.upgrade_type = 2
        -- link the part and vehicle so the part can be cleaned up later
        if upgrade_part != no_object then
          upgrade_part.upgrade_type = 10
          upgrade_part.upgrade_owner = upgrade_vehicle
          upgrade_vehicle.upgrade_attachment = upgrade_part
        end
        -- no gun found on the donor: let this vehicle roll again next time
        if upgrade_part == no_object then
          upgrade_vehicle.upgrade_type = 0
        end
      end
    end
  end
end

-- wherever you want the roll to happen
for each object do
  try_vehicle_upgrade()
end

-- remove cannons whose vehicle was destroyed or deleted
for each object do
  if current_object.upgrade_type == 10 then
    upgrade_part = current_object
    if upgrade_part.upgrade_owner == no_object then
      if upgrade_part.upgrade_attachment != no_object then
        upgrade_part.upgrade_attachment.delete()
      end
      upgrade_part.delete()
    end
  end
end