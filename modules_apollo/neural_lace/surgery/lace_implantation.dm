/datum/surgery/lace_implant
	name = "neural lace implantation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/drill, /datum/surgery_step/implant_lace, /datum/surgery_step/close)
	possible_locs = list("head")

/datum/surgery/lace_implant/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/neural_lace/lace = target.getorgan(/obj/item/organ/neural_lace)

	if(isnull(lace))
		return 1
	return 0

/datum/surgery_step/implant_lace
	name = "implant neural lace"
	implements = list(/obj/item/weapon/lace_claw = 100, /obj/item/weapon/wirecutters = 40)
	time = 24

/datum/surgery_step/implant_lace/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to attach the neural lace to [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to attach the neural lace to [target]'s [parse_zone(target_zone)]...</span>")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/weapon/lace_claw))
		var/obj/item/weapon/lace_claw/C = tool

		// mode = 1 is implant mode
		if(C.mode)
			return 1
		else
			user << "<span class='notice'>The lace claw is set to extract!</span>"

	return 0

/datum/surgery_step/implant_lace/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/neural_lace/lace = target.getorgan(/obj/item/organ/neural_lace)

	target.internal_organs += lace
	lace.loc = null

	lace.stored_dna = target.dna