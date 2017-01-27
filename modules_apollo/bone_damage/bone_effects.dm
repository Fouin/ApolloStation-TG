/*
	Defined in code/modules/mob/living/carbon/human/human_movement.dm
*/

/*
	Movement slowdown
	Defined in code/modules/surgery/bodyparts/bodyparts.dm
*/

/mob/living/carbon/human/Move()
	. = ..()
	if(!.)
		return 0

	for(var/obj/item/bodypart/B in bodyparts)
		B.on_mob_move()

/obj/item/bodypart/proc/movement_delay()
	return 0

// dupe code but thats what happens when it ain't /leg/r and /leg/l
// i cba to fix that
/obj/item/bodypart/l_leg/movement_delay()
	. = brute_dam / 50
	. += (broken ? 4 : 0)

/obj/item/bodypart/l_leg/on_mob_move()
	if(broken && prob(5))
		rattle_bones()
		owner.Weaken(2)

/obj/item/bodypart/r_leg/movement_delay()
	. = brute_dam / 50
	. += (broken ? 4 : 0)

/obj/item/bodypart/r_leg/on_mob_move()
	if(broken && prob(5))
		rattle_bones()
		owner.Weaken(2)