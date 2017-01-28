/*
	Defined in code/modules/mob/living/carbon/carbon.dm
*/

/mob/living/carbon/fully_heal(admin_revive = 0)
	for(var/X in getFractures())
		var/obj/item/bodypart/B = X
		B.heal_fracture()
	..()

/mob/living/carbon/proc/getFractures()
	. = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/B = X
		if(B.broken)
			. += B