var/global/const/base_law_type = /datum/ai_laws/asimov

/datum/ai_law
	var/law = ""
	var/index = 0
	var/state_law = 1

/datum/ai_law/zero
	state_law = 0

/datum/ai_law/New(law, state_law, index)
	src.law = law
	src.index = index
	src.state_law = state_law

/datum/ai_law/proc/get_index()
	return index

/datum/ai_law/ion/get_index()
	return ionnum()

/datum/ai_law/zero/get_index()
	return 0

/datum/ai_laws
	var/name = "Unknown Laws"
	var/datum/ai_law/zero/zeroth = null
	var/datum/ai_law/zero/zeroth_borg = null
	var/list/datum/ai_law/inherent = list()
	var/list/datum/ai_law/supplied = list()
	var/list/datum/ai_law/ion/ion = list()
	var/list/datum/ai_law/sorted = list()
	var/mob/living/silicon/owner



/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")


/datum/ai_laws/New()
	..()
	sort_laws()

/* General ai_law functions */
/datum/ai_laws/proc/all_laws()
	sort_laws()
	return sorted

/datum/ai_laws/proc/laws_to_state()
	sort_laws()
	var/list/statements = new()
	for(var/datum/ai_law/law in sorted)
		if(law.state_law)
			statements += law

	return statements

/datum/ai_laws/proc/sort_laws()
	if(sorted.len)
		return

	if(zeroth)
		sorted += zeroth

	for(var/ion_law in ion)
		sorted += ion_law

	var/index = 1
	for(var/datum/ai_law/inherent_law in inherent)
		inherent_law.index = index++
		if(supplied.len < inherent_law.index || !istype(supplied[inherent_law.index], /datum/ai_law))
			sorted += inherent_law

	for(var/datum/ai_law/AL in supplied)
		if(istype(AL))
			sorted += AL

/datum/ai_laws/proc/sync(var/mob/living/silicon/S, var/full_sync = 1)
	S.sync_zeroth(zeroth, zeroth_borg)

	if(full_sync || ion.len)
		S.clear_ion_laws()
		for (var/datum/ai_law/law in ion)
			S.laws.add_ion_law(law.law, law.state_law)

	if(full_sync || inherent.len)
		S.clear_inherent_laws()
		for (var/datum/ai_law/law in inherent)
			S.laws.add_inherent_law(law.law, law.state_law)

	if(full_sync || supplied.len)
		S.clear_supplied_laws()
		for (var/law_number in supplied)
			var/datum/ai_law/law = supplied[law_number]
			S.laws.add_supplied_law(law_number, law.law, law.state_law)


/mob/living/silicon/proc/sync_zeroth(var/datum/ai_law/zeroth, var/datum/ai_law/zeroth_borg)
	if (!is_special_character(src) || mind.original != src)
		if(zeroth_borg)
			set_zeroth_law(zeroth_borg.law)
		else if(zeroth)
			set_zeroth_law(zeroth_.law)

/mob/living/silicon/ai/sync_zeroth(var/datum/ai_law/zeroth, var/datum/ai_law/zeroth_borg)
	if(zeroth_law)
		set_zeroth_law(zeroth.law, zeroth_borg ? zeroth_borg.law : null)


datum/ai_laws/proc/set_zeroth_law(var/law, var/law_borg = null)
	if(!law)
		return

	src.zeroth = new(law)
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = new(law_borg)
	sorted.Cut()

/datum/ai_laws/proc/add_ion_law(var/law, var/state_law = 1)
	if(!law)
		return

	src.ion += new/datum/ai_law/ion(law, state_law)
	sorted.Cut()

/datum/ai_laws/proc/add_inherent_law(var/law, var/state_law = 1)
	if(!law)
		return

	for(var/datum/ai_law/AL in inherent)
		if(AL.law == law)
			return

	src.inherent += new/datum/ai_law(law, state_law)
	sorted.Cut()

/datum/ai_laws/proc/add_supplied_law(var/number, var/law, var/state_law = 1)
	if(!law)
		return

	while (src.supplied.len < number)
		src.supplied += ""

	src.supplied[number] = new/datum/ai_law(law, state_law, number)
	sorted.Cut()

/****************
*	Remove Laws	*
*****************/
/datum/ai_laws/proc/delete_law(var/datum/ai_law/law)
	if(law in all_laws())
		del(law)
	sorted.Cut()

/****************
*	Clear Laws	*
****************/
/datum/ai_laws/proc/clear_zeroth_laws()
	zeroth = null
	zeroth_borg = null

/datum/ai_laws/proc/clear_inherent_laws()
	src.inherent.Cut()
	sorted.Cut()

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied.Cut()
	sorted.Cut()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion.Cut()
	sorted.Cut()

/datum/ai_laws/proc/show_laws(var/who)
	sort_laws()
	for(var/datum/ai_law/law in sorted)
		who << "[law.get_index()]. [law.law]"
