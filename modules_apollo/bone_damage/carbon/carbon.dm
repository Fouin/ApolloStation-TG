/mob/living/carbon/proc/getFractures()
	. = list()
	for(var/obj/item/bodypart/B in bodyparts)
		if(B.broken)
			. += B