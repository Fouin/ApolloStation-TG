// Defined in code/game/machinery/computer/cloning.dm


// DNA scanner console
/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject)
	if (!istype(subject))
		scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	/* Laces take over for this need
	if (!subject.getorgan(/obj/item/organ/brain))
		scantemp = "<font class='bad'>No signs of intelligence detected.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	*/
	if (subject.suiciding == 1 || subject.hellbound)
		scantemp = "<font class='bad'>Subject's brain is not responding to scanning stimuli.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if ((subject.disabilities & NOCLONE) && (src.scanner.scan_level < 2))
		scantemp = "<font class='bad'>Subject no longer contains the fundamental materials required to create a living clone.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	/* Allow cloning of bodies even if the client isn't connected
	if ((!subject.ckey) || (!subject.client))
		scantemp = "<font class='bad'>Mental interface failure.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	*/
	if (find_record("ckey", subject.ckey, records))
		scantemp = "<font class='average'>Subject already in database.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/data/record/R = new()
	if(subject.dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		R.fields["mrace"] = subject.dna.species
	else
		var/datum/species/rando_race = pick(config.roundstart_races)
		R.fields["mrace"] = rando_race.type
	R.fields["ckey"] = subject.ckey
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)
	R.fields["UE"] = subject.dna.unique_enzymes
	R.fields["UI"] = subject.dna.uni_identity
	R.fields["SE"] = subject.dna.struc_enzymes
	R.fields["blood_type"] = subject.dna.blood_type
	R.fields["features"] = subject.dna.features
	R.fields["factions"] = subject.faction

	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp
	for(var/obj/item/weapon/implant/health/HI in subject.implants)
		imp = HI
		break
	if(!imp)
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implant(subject)
	R.fields["imp"] = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

// Cloning pod
/obj/machinery/clonepod/proc/growclone(ckey, clonename, ui, se, mindref, datum/species/mrace, list/features, factions)
	if(panel_open)
		return FALSE
	if(mess || attempting)
		return FALSE
	clonemind = locate(mindref)
	if(!istype(clonemind))	//not a mind
		return FALSE
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return FALSE
	if(clonemind.active)	//somebody is using that mind
		if( ckey(clonemind.key)!=ckey )
			return FALSE
	else
		// get_ghost() will fail if they're unable to reenter their body
		var/mob/dead/observer/G = clonemind.get_ghost()
		if(!G)
			return FALSE
	if(clonemind.damnation_type) //Can't clone the damned.
		addtimer(CALLBACK(src, .proc/horrifyingsound), 0)
		mess = 1
		icon_state = "pod_g"
		update_icon()
		return FALSE

	attempting = TRUE //One at a time!!
	locked = TRUE
	countdown.start()

	eject_wait = TRUE
	addtimer(CALLBACK(src, .proc/wait_complete), 30)

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	H.hardset_dna(ui, se, H.real_name, null, mrace, features)

	if(efficiency > 2)
		var/list/unclean_mutations = (not_good_mutations|bad_mutations)
		H.dna.remove_mutation_group(unclean_mutations)
	if(efficiency > 5 && prob(20))
		H.randmutvg()
	if(efficiency < 3 && prob(50))
		var/mob/M = H.randmutb()
		if(ismob(M))
			H = M

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(0,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	H.setCloneLoss(CLONE_INITIAL_DAMAGE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	H.setBrainLoss(CLONE_INITIAL_DAMAGE)
	H.Paralyse(4)

	if(grab_ghost_when == CLONER_FRESH_CLONE)
		clonemind.transfer_to(H)
		H.ckey = ckey
		H << "<span class='notice'><b>Consciousness slowly creeps over you \
			as your body regenerates.</b><br><i>So this is what cloning \
			feels like?</i></span>"
	else if(grab_ghost_when == CLONER_MATURE_CLONE)
		clonemind.current << "<span class='notice'>Your body is \
			beginning to regenerate in a cloning pod. You will \
			become conscious when it is complete.</span>"

	if(H)
		H.faction |= factions

		H.set_cloned_appearance()

		H.suiciding = FALSE
	attempting = FALSE
	return TRUE