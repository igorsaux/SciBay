//Negative values indicate that instances of these types should use the Value proc
//Mainly used so that stuff inside them can also add to their value, and other things like material,
//stuff like that.

//Must be in descending order. Child before parents, otherwise it doesn't work.
var/list/worths = list(
	/obj/item/storage/fancy/vials = -820,
	/obj/item/lacmus = 4,
	/obj/item/bunsen = 13400,
	/obj/item/scales = 6500,
	/obj/item/thermometer = 9340,
	/obj/item/bunsen = 13400,
	/obj/item/scales = 6500,
	/obj/item/thermometer = 9340,
	/obj/item/filter/cloth = 100,
	/obj/item/filter/sieve = 3120,
	/obj/item/filter/paper = 23,
	/obj/item/filter/membrane = 526,
	/obj/item/reagent_containers/dropper = -250,
	/obj/item/reagent_containers/vessel/beaker = -80,
	/obj/item/reagent_containers/vessel/beaker/large = -160,
	/obj/item/reagent_containers/vessel/beaker/vial = -60,
	/obj/item/reagent_containers/vessel/bottle/chemical = -130,
	/obj/item/reagent_containers/vessel/bottle/chemical/big = -160,
	/obj/item/reagent_containers/vessel/bottle/chemical/small = -100,
)
