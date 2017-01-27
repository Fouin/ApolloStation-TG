/*
	Defined in code/modules/mob/living/carbon/human/human_movement.dm
*/

/mob/living/carbon/human/movement_delay()
	. = ..()
	for(var/obj/item/bodypart/B in bodyparts)
		. += B.movement_delay()

/*
	Movement slowdown
	Defined in code/modules/surgery/bodyparts/bodyparts.dm
*/

/obj/item/bodypart/proc/movement_delay()
	return 0

// dupe code but thats what happens when it ain't /leg/r and /leg/l
// i cba to fix that
/obj/item/bodypart/l_leg/movement_delay()
	. = brute_dam / 50
	. += (broken ? 2 : 0)

/obj/item/bodypart/l_leg/on_mob_move()
	if(broken && prob(10))
		rattle_bones()
		owner.Weaken(5)

/obj/item/bodypart/r_leg/movement_delay()
	. = brute_dam / 50
	. += (broken ? 2 : 0)

/obj/item/bodypart/r_leg/on_mob_move()
	if(broken && prob(10))
		rattle_bones()
		owner.Weaken(5)