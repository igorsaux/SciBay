/var/global/list/autolathe_recipes
/var/global/list/autolathe_categories

var/const/EXTRA_COST_FACTOR = 1.25
// Items are more expensive to produce than they are to recycle.

/proc/populate_lathe_recipes()

	//Create global autolathe recipe list if it hasn't been made already.
	autolathe_recipes = list()
	autolathe_categories = list()
	for(var/R in typesof(/datum/autolathe/recipe)-/datum/autolathe/recipe)
		var/datum/autolathe/recipe/recipe = new R
		autolathe_recipes += recipe
		autolathe_categories |= recipe.category

		var/obj/item/I = new recipe.path
		if(I.matter && !recipe.resources) //This can be overidden in the datums.
			recipe.resources = list()
			for(var/material in I.matter)
				recipe.resources[material] = I.matter[material] * EXTRA_COST_FACTOR
		qdel(I)

/datum/autolathe/recipe
	var/name = "object"
	var/path
	var/list/resources
	var/hidden
	var/category
	var/power_use = 0
	var/is_stack

/datum/autolathe/recipe/bucket
	name = "bucket"
	path = /obj/item/reagent_containers/vessel/bucket
	category = "General"

/datum/autolathe/recipe/tube
	name = "light tube"
	path = /obj/item/light/tube
	category = "General"

/datum/autolathe/recipe/largetube
	name = "large light tube"
	path = /obj/item/light/tube/large
	category = "General"

/datum/autolathe/recipe/hetube
	name = "high efficiency light tube"
	path = /obj/item/light/tube/he
	category = "General"

/datum/autolathe/recipe/qtube
	name = "quartz light tube"
	path = /obj/item/light/tube/quartz
	category = "General"

/datum/autolathe/recipe/bulb
	name = "light bulb"
	path = /obj/item/light/bulb
	category = "General"

/datum/autolathe/recipe/hebulb
	name = "high efficiency light bulb"
	path = /obj/item/light/bulb/he
	category = "General"

/datum/autolathe/recipe/qbulb
	name = "quartz light bulb"
	path = /obj/item/light/bulb/quartz
	category = "General"

/datum/autolathe/recipe/oldbulb
	name = "old light bulb"
	path = /obj/item/light/bulb/old
	category = "General"

/datum/autolathe/recipe/drinkingglass
	name = "drinking glass"
	path = /obj/item/reagent_containers/vessel/glass/square
	category = "General"
	New()
		..()
		var/obj/O = path
		name = initial(O.name) // generic recipes yay

/datum/autolathe/recipe/drinkingglass/rocks
	path = /obj/item/reagent_containers/vessel/glass/rocks

/datum/autolathe/recipe/drinkingglass/shake
	path = /obj/item/reagent_containers/vessel/glass/shake

/datum/autolathe/recipe/drinkingglass/cocktail
	path = /obj/item/reagent_containers/vessel/glass/cocktail

/datum/autolathe/recipe/drinkingglass/shot
	path = /obj/item/reagent_containers/vessel/glass/shot

/datum/autolathe/recipe/drinkingglass/pint
	path = /obj/item/reagent_containers/vessel/glass/pint

/datum/autolathe/recipe/drinkingglass/mug
	path = /obj/item/reagent_containers/vessel/glass/mug

/datum/autolathe/recipe/drinkingglass/wine
	path = /obj/item/reagent_containers/vessel/glass/wine

/datum/autolathe/recipe/drinkingglass/carafe
	path = /obj/item/reagent_containers/vessel/glass/carafe

/datum/autolathe/recipe/flashlight
	name = "flashlight"
	path = /obj/item/device/flashlight
	category = "General"

/datum/autolathe/recipe/floor_light
	name = "floor light"
	path = /obj/machinery/floor_light
	category = "General"

/datum/autolathe/recipe/extinguisher
	name = "extinguisher"
	path = /obj/item/extinguisher
	category = "General"

/datum/autolathe/recipe/coffeepot
	name = "coffeepot"
	path = /obj/item/reagent_containers/vessel/coffeepot
	category = "General"

/datum/autolathe/recipe/suit_cooler
	name = "suit cooling unit"
	path = /obj/item/device/suit_cooling_unit
	category = "General"

/datum/autolathe/recipe/weldermask
	name = "welding mask"
	path = /obj/item/clothing/head/welding
	category = "General"

/datum/autolathe/recipe/metal
	name = "steel sheets"
	path = /obj/item/stack/material/steel
	category = "General"
	is_stack = 1
	resources = list(MATERIAL_STEEL = SHEET_MATERIAL_AMOUNT * EXTRA_COST_FACTOR)

/datum/autolathe/recipe/glass
	name = "glass sheets"
	path = /obj/item/stack/material/glass
	category = "General"
	is_stack = 1
	resources = list(MATERIAL_GLASS = SHEET_MATERIAL_AMOUNT * EXTRA_COST_FACTOR)

/datum/autolathe/recipe/rglass
	name = "reinforced glass sheets"
	path = /obj/item/stack/material/glass/reinforced
	category = "General"
	is_stack = 1
	resources = list(MATERIAL_GLASS = (SHEET_MATERIAL_AMOUNT/2) * EXTRA_COST_FACTOR, MATERIAL_STEEL = (SHEET_MATERIAL_AMOUNT/2) * EXTRA_COST_FACTOR)

/datum/autolathe/recipe/rods
	name = "metal rods"
	path = /obj/item/stack/rods
	category = "General"
	is_stack = 1

/datum/autolathe/recipe/knife
	name = "kitchen knife"
	path = /obj/item/material/knife
	category = "General"

/datum/autolathe/recipe/taperecorder
	name = "tape recorder"
	path = /obj/item/device/taperecorder/empty
	category = "General"

/datum/autolathe/recipe/tape
	name = "tape"
	path = /obj/item/device/tape
	category = "General"

/datum/autolathe/recipe/weldinggoggles
	name = "welding goggles"
	path = /obj/item/clothing/glasses/welding
	category = "General"

/datum/autolathe/recipe/blackpen
	name = "black ink pen"
	path = /obj/item/pen
	category = "General"

/datum/autolathe/recipe/bluepen
	name = "blue ink pen"
	path = /obj/item/pen/blue
	category = "General"

/datum/autolathe/recipe/redpen
	name = "red ink pen"
	path = /obj/item/pen/red
	category = "General"

/datum/autolathe/recipe/clipboard
	name = "clipboard"
	path = /obj/item/clipboard
	category = "General"

/datum/autolathe/recipe/destTagger
	name = "destination tagger"
	path = /obj/item/device/destTagger
	category = "General"

/datum/autolathe/recipe/labeler
	name = "hand labeler"
	path = /obj/item/hand_labeler
	category = "General"

/datum/autolathe/recipe/handcuffs
	name = "handcuffs"
	path = /obj/item/handcuffs
	hidden = 1
	category = "General"

/datum/autolathe/recipe/crowbar
	name = "crowbar"
	path = /obj/item/crowbar
	category = "Tools"

/datum/autolathe/recipe/prybar
	name = "pry bar"
	path = /obj/item/crowbar/prybar
	category = "Tools"

/datum/autolathe/recipe/multitool
	name = "multitool"
	path = /obj/item/device/multitool
	category = "Tools"

/datum/autolathe/recipe/t_scanner
	name = "T-ray scanner"
	path = /obj/item/device/t_scanner
	category = "Tools"

/datum/autolathe/recipe/weldertool
	name = "welding tool"
	path = /obj/item/weldingtool
	category = "Tools"

/datum/autolathe/recipe/screwdriver
	name = "screwdriver"
	path = /obj/item/screwdriver
	category = "Tools"

/datum/autolathe/recipe/wirecutters
	name = "wirecutters"
	path = /obj/item/wirecutters
	category = "Tools"

/datum/autolathe/recipe/wrench
	name = "wrench"
	path = /obj/item/wrench
	category = "Tools"

/datum/autolathe/recipe/hatchet
	name = "hatchet"
	path = /obj/item/material/hatchet
	category = "Tools"

/datum/autolathe/recipe/minihoe
	name = "mini hoe"
	path = /obj/item/material/minihoe
	category = "Tools"

/datum/autolathe/recipe/handcharger
	name = "hand-crank charger"
	path = /obj/item/device/handcharger/empty
	category = "Tools"

/datum/autolathe/recipe/welder_industrial
	name = "industrial welding tool"
	path = /obj/item/weldingtool/largetank
	hidden = 1
	category = "Tools"

/datum/autolathe/recipe/airlockmodule
	name = "airlock electronics"
	path = /obj/item/airlock_electronics
	category = "Engineering"

/datum/autolathe/recipe/powermodule
	name = "power control module"
	path = /obj/item/module/power_control
	category = "Engineering"

/datum/autolathe/recipe/scalpel
	name = "scalpel"
	path = /obj/item/scalpel
	category = "Medical"

/datum/autolathe/recipe/circularsaw
	name = "circular saw"
	path = /obj/item/circular_saw
	category = "Medical"

/datum/autolathe/recipe/surgicaldrill
	name = "surgical drill"
	path = /obj/item/surgicaldrill
	category = "Medical"

/datum/autolathe/recipe/retractor
	name = "retractor"
	path = /obj/item/retractor
	category = "Medical"

/datum/autolathe/recipe/cautery
	name = "cautery"
	path = /obj/item/cautery
	category = "Medical"

/datum/autolathe/recipe/hemostat
	name = "hemostat"
	path = /obj/item/hemostat
	category = "Medical"

/datum/autolathe/recipe/beaker
	name = "glass beaker"
	path = /obj/item/reagent_containers/vessel/beaker
	category = "Medical"

/datum/autolathe/recipe/beaker_large
	name = "large glass beaker"
	path = /obj/item/reagent_containers/vessel/beaker/large
	category = "Medical"

/datum/autolathe/recipe/vial
	name = "glass vial"
	path = /obj/item/reagent_containers/vessel/beaker/vial
	category = "Medical"

/datum/autolathe/recipe/bottle_small
	name = "small glass bottle"
	path = /obj/item/reagent_containers/vessel/bottle/chemical/small
	category = "Medical"

/datum/autolathe/recipe/bottle
	name = "glass bottle"
	path = /obj/item/reagent_containers/vessel/bottle/chemical
	category = "Medical"

/datum/autolathe/recipe/bottle_big
	name = "big glass bottle"
	path = /obj/item/reagent_containers/vessel/bottle/chemical/big
	category = "Medical"

/datum/autolathe/recipe/syringe
	name = "syringe"
	path = /obj/item/reagent_containers/syringe
	category = "Medical"

/datum/autolathe/recipe/tacknife
	name = "tactical knife"
	path = /obj/item/material/hatchet/tacknife
	hidden = 1
	category = "Arms and Ammunition"

/datum/autolathe/recipe/machete
	name = "machete"
	path = /obj/item/material/hatchet/machete
	hidden = 1
	category = "Arms and Ammunition"
	resources = list(MATERIAL_STEEL = 74000)

/datum/autolathe/recipe/consolescreen
	name = "console screen"
	path = /obj/item/stock_parts/console_screen
	category = "Devices and Components"

/datum/autolathe/recipe/cable_coil
	name = "cable coil"
	path = /obj/item/stack/cable_coil/single
	category = "Devices and Components"
	is_stack = 1

/datum/autolathe/recipe/beartrap
	name = "mechanical trap"
	path = /obj/item/beartrap
	hidden = 1
	category = "Devices and Components"

/datum/autolathe/recipe/cell_device
	name = "device cell"
	path = /obj/item/cell/device/standard
	category = "Devices and Components"
