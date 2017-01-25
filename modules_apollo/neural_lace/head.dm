/*
	Defined in code/modules/surgery/bodyparts/head.dm
*/

/obj/item/bodypart/head/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
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
		else if(istype(I, /obj/item/organ/neural_lace))
			var/obj/item/organ/neural_lace/lace = I

			if(isnull(lace.stored_mind))
				lace.stored_mind = brainmob.mind

			lace.loc = T
		else
			I.loc = T