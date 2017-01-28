/*
	Defined in code/modules/mob/living/carbon/carbon.dm
*/

/mob/living/carbon/fully_heal(admin_revive = 0)
	for(var/obj/item/bodypart/B in getFractures())
		B.heal_fracture()
	..()

/mob/living/carbon/proc/getFractures()
	. = list()
	for(var/obj/item/bodypart/B in bodyparts)
		if(B.broken)
			. += B