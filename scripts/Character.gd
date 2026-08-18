"""
Character 类，用于定义角色姓名，性别以及预加载角色的关键帧
"""
class_name Character
extends Node

enum Name {
	REIMU,
	MAYOI,
	PHOENIX
}

const CHARACTER_DETAILS: Dictionary = {
	Name.REIMU: {
		"name" : "灵梦",
		"gender": "female",
		"sprite_frames": preload("res://assets/spirites/ling_meng_frames.tres")
	},
	Name.MAYOI: {
		"name" : "真宵",
		"gender": "female",
		"sprite_frames": preload("res://assets/spirites/zhen_xiao_frames.tres")
	},
	Name.PHOENIX: {
		"name": "成步堂龙一",
		"gender": "male",
		"sprite_frames": null
	}
}

static func get_enum_from_string(string_value: String):
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		printerr("ERROR(不存在的名字): " + string_value)
