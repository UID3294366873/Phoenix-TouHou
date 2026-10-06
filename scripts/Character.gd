class_name Character
extends Node

enum Name {
	APOLLO,
	PHOENIX,
	TRUCY
}

const CHARACTER_DETAILS: Dictionary = {
	Name.APOLLO: {
		"name" : "Apollo",
		"gender": "male",
		"sprite_frames": null
	},
	Name.PHOENIX: {
		"name" : "Phoenix",
		"gender": "male",
		"sprite_frames": preload("res://resources/spirite_frames/phonix__sprite_frames.tres")
	},
	Name.TRUCY: {
		"name" : "Trucy",
		"gender": "female",
		"sprite_frames": preload("res://resources/spirite_frames/trucy_sprite_frames.tres")
	}
	
}

static func get_enum_from_string(string_value: String):
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		push_error("Invalid Character name: " + string_value)
