/proc/isGroundedMob(mob/living/M)
  if(istype(M, /mob/living/carbon) || istype(M, /mob/living/silicon))
    for(var/B in FOOTSTEP_BLACKLISTED_MOBS) // Blacklist for things that should have footsteps but shouldn't
      if(istype(M, B))
        return 0
    return 1

  if(istype(M, /mob/living/carbon)) // Check if something that should have footsteps
    return 1
  else if(istype(M, /mob/living/silicon)) // Check if something that should have footsteps, but is not alive
    return 1

proc/isWalking(mob/living/M) // Gotta be sneaky
  if(M.m_intent == "walk")
    return 1
  return 0

/proc/getFootStepSound(T as turf, M as mob)
  if(!T) // Check if its a turf at all (sanity check)
    return
  if(!istype(T, /turf/open/floor)) // Check if its a turf that isn't space and admin tile
    return
  if(istype(M, /mob/living/silicon))
    return HEAVY_FOOTSTEP_SOUNDS[rand(1, HEAVY_FOOTSTEP_SOUNDS.len)] // If silicon, use heavy
  for(var/O in T) // Each item on tile
    for(var/OT in itemStepsList) // Each item list in itemStepsList
      for(var/OT2 in OT) // Each item in itemlist
        if(istype(O, OT2))
          return itemStepsList[OT2]
  for(var/i in stepsList) // Choose a random sound associated with the turf type
    if(istype(T, i))
      var/t[] = stepsList[i]
      var/step = rand(1, t.len)
      return stepsList[i][step]
  return DEFAULT_FOOTSTEP_SOUNDS[rand(1, DEFAULT_FOOTSTEP_SOUNDS.len)] // If no type is specified, use default

/proc/playFootstep(atom/movable/A) // Main proc
  if(!A || !istype(A))
    return
  var/playSteps = isGroundedMob(A)
  if(isWalking(A))  // Check if the player is in sneak mode (walk mode)
    return
  if(playSteps) // Play the sound
    var/curTurf = get_turf(A)
    if(curTurf)
      var/stepSound = getFootStepSound(curTurf, A)
      if(stepSound)
        playsound(curTurf, "sound/footsteps/" + stepSound, footstepVol, footstepVarReq, footstepRange, 0, 0, footstepFreq)

/client/Move(n, direct)
	if(world.time < move_delay)
		return 0
	move_delay = world.time+world.tick_lag //this is here because Move() can now be called mutiple times per tick
	if(!mob || !mob.loc)
		return 0
	if(mob.notransform)
		return 0	//This is sota the goto stop mobs from moving var
	if(mob.control_object)
		return Move_object(direct)
	if(!isliving(mob))
		return mob.Move(n,direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return 0
	if(moving)
		return 0
	if(mob.force_moving)
		return 0
	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)	//Move though walls
			Process_Incorpmove(direct)
			return 0

	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(n,direct,mob)

	if(Process_Grab()) //are we restrained by someone's grip?
		return

	if(mob.buckled)							//if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(!mob.canmove)
		return 0

	if(isobj(mob.loc) || ismob(mob.loc))	//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	//We are now going to move
	moving = 1
	move_delay = mob.movement_delay() + world.time
	playFootstep(mob)

	if(mob.confused)
		if(mob.confused > 40)
			step(mob, pick(cardinal))
		else if(prob(mob.confused * 1.5))
			step(mob, angle2dir(dir2angle(direct) + pick(90, -90)))
		else if(prob(mob.confused * 3))
			step(mob, angle2dir(dir2angle(direct) + pick(45, -45)))
		else
			step(mob, direct)
	else
		. = ..()

	moving = 0
	if(mob && .)
		mob.throwing = 0

	for(var/obj/O in mob)
		O.on_mob_move(direct, src)

	return .