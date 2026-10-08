class_name CharacterCatalog
extends Node

enum Name {
	APOLLO,
	PHOENIX,
	TRUCY,
}

const CHARACTER_DETAILS: Dictionary = {
	Name.APOLLO: {
		"name": "Apollo",
		"gender": "male",
		"sprite_frames": null,
	},
	Name.PHOENIX: {
		"name": "Phoenix",
		"gender": "male",
		"sprite_frames": preload(
			"res://resources/spirite_frames/phonix__sprite_frames.tres"
		),
	},
	Name.TRUCY: {
		"name": "Trucy",
		"gender": "female",
		"sprite_frames": preload(
			"res://resources/spirite_frames/trucy_sprite_frames.tres"
		),
	},
}


## 将 JSON 中的角色名称转换为项目内使用的枚举值。
static func get_enum_from_string(string_value: String) -> Name:
	return Name[string_value.to_upper()]
