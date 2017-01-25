/*
	Defined in code/modules/surgery/bodyparts/head.dm
*/

/obj/item/bodypart/head/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)

	// this has to be done before brainmob is nulled by the brain being dropped
	var/obj/item/organ/neural_lace/lace = locate() in src
	if(isnull(lace.stored_mind))
		lace.stored_mind = brainmob.mind
	lace.loc = T

	for(var/obj/item/I in src)
		if(I == brain)
			if(user)
				user.visible_message("<span class='warning'>[user] saws [src] open and pulls out a brain!</span>", "<span class='notice'>You saw [src] open and pull out a brain.</span>")
			if(brainmob)
				brainmob.container = null
				brainmob.loc = brain
				brain.brainmob = brainmob
				brainmob = null
			brain.loc = T
			brain = null
			update_icon_dropped()
		else
			I.loc = T