# 这个脚本计划用于解析JSON文件，构建Commands字典，并逐条执行
extends Node

@export var Commands: Dictionary = {
	"speaker": set_speaker,
	"text": set_speak_text,
	"background": set_background,
	"choice": set_choices,
	"goto": goto_anchor
}

var INDEX: int = 0 # 在当前脚本文件里的索引
var TEST_JSON_FILE := "res://data/story/test1.json"
var lines: Array = []

func _ready() -> void:
	lines = load_json(TEST_JSON_FILE)
	for i in range(len(lines)):
		process_current_line()
		INDEX += 1

func _process(delta: float) -> void:
	pass

func load_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json_context = JSON.parse_string(content)
	return json_context

func process_current_line():
	var line = lines[INDEX]
	print(line)


func set_speaker():
	# 该函数用于设置说话人名字
	pass
func set_speak_text():
	# 该函数用于设置说话文本
	pass
func set_background():
	# 该函数用于设置背景图片
	pass
func set_choices():
	# 该函数用于处理多选选项
	pass
func goto_anchor():
	# 该函数用于执行单脚本内的跳转逻辑
	pass
