//Negative values indicate that instances of these types should use the Value proc
//Mainly used so that stuff inside them can also add to their value, and other things like material,
//stuff like that.

//Must be in descending order. Child before parents, otherwise it doesn't work.
var/list/worths = list(
	/obj/structure/table/standard = 2760,
	/obj/structure/table/reinforced = 6899,
	/obj/structure/table/steel = 5490,
	/obj/structure/table/steel_reinforced = 9780,
	/obj/structure/table/glass = 13540,
	/obj/structure/table/marble = 20520,
	/obj/item/lacmus = 16,
	/obj/item/bunsen = 8210,
	/obj/item/scales = 6500,
	/obj/item/thermometer = 9340,
	/obj/item/bunsen = 13400,
	/obj/item/scales = 6500,
	/obj/item/thermometer = 1200,
	/obj/item/filter/cloth = 100,
	/obj/item/filter/sieve = 3120,
	/obj/item/filter/paper = 83,
	/obj/item/filter/membrane = 526,
	/obj/item/storage/fancy/vials = -820,
	/obj/item/reagent_containers/dropper = -250,
	/obj/item/reagent_containers/vessel/beaker = -80,
	/obj/item/reagent_containers/vessel/beaker/large = -160,
	/obj/item/reagent_containers/vessel/beaker/vial = -60,
	/obj/item/reagent_containers/vessel/bottle/chemical = -130,
	/obj/item/reagent_containers/vessel/bottle/chemical/big = -160,
	/obj/item/reagent_containers/vessel/bottle/chemical/small = -100,
)
