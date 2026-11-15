extends Node

const INTRO := """Haven was the last forest that still remembered how to grow.

Then the machines came to harvest what it remembered.

You are what the forest kept when everything else was taken.
A guardian with no weapon of its own.

You cannot strike first.
You can only send back what is sent at you."""

const ENDING := """The last machine folds, and the mist closes over the scar.

Haven will not remember you. It never remembers its guardians.

It only remembers how to grow back."""

const BEATS := {
	1: "The outer grove. Their scouts are already inside the treeline.",
	2: "Deeper in. The mist thins where the machines have burned it.",
	3: "A Warden holds the heart of the grove. Your blade turns on its plating.\nOnly its own fire will open it.",
	4: "The grove is breathing again. Push on, toward the harvest line.",
	5: "Ash underfoot. Whatever waits ahead has been here longest.",
	6: "The Harvest Core. Everything it has taken, it throws.\nGive all of it back.",
}


func beat_for(level_number: int) -> String:
	return BEATS.get(level_number, "")
