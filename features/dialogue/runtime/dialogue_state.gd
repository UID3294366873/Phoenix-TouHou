class_name DialogueState
extends RefCounted

var step_index: int = 0
var command_index: int = 0
var current_speaker: StringName = &""
var portrait_character: StringName = &""
var expression: StringName = &""
var portrait_is_talking: bool = true


## 将命令游标和角色上下文恢复到一个新剧情文件的初始状态。
func reset() -> void:
	step_index = 0
	command_index = 0
	current_speaker = &""
	portrait_character = &""
	expression = &""
	portrait_is_talking = true
