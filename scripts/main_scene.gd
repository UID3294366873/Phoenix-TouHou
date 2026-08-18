extends Node2D

@onready var character_sprite = $CharacterAndUI/CharacterControl/CharacterSprite
@onready var dialog_ui = $CharacterAndUI/DialogUI
@onready var next_sentence_sound = $NextSentenceSound
@onready var dialog_pause_timer = $DialogPauseTimer

var dialog_index: int = 0
var can_click: bool = true

var dialog_lines : Array = []

func _ready() -> void:
	dialog_lines = load_dialog("res://resources/story/story.json")
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	dialog_pause_timer.timeout.connect(_on_dialog_pause_timeout)
	dialog_index = 0
	process_current_line()

func _input(event):
	if event.is_action_pressed("next_line"):
		if not can_click: # 若当前不能触发该事件
			return
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) - 1:
				next_sentence_sound.play()
				dialog_pause_timer.start()
				can_click = false

func process_current_line():
	var line = dialog_lines[dialog_index]
	if line.has("goto"): # 跳转语句
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
	
	if line.has("anchor"): #跳过anchor语句
		dialog_index += 1
		process_current_line()
		return
	
	if line.has("choices"):
		dialog_ui.display_choices(line["choices"])
		can_click = false
		return
		
	if line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(character_name, line["text"])
		character_sprite.change_character(character_name)

func get_anchor_position(anchor: String):
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
	# 若找不到achor
	printerr("ERROR(未找到anchor): ", anchor)
	
func _on_text_animation_done():
	pass
	#character_sprite.play_idle_animation() 目前暂时没有该动画帧

func _on_dialog_pause_timeout():
	can_click = true
	dialog_index += 1
	process_current_line()

func load_dialog(file_path):
	if not FileAccess.file_exists(file_path):
		printerr("ERROR(文件不存在)：", file_path)
		return null
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("ERROR(打开文件失败): ", file_path)
		return null
		
	var content = file.get_as_text()
	file.close()
	
	var json_context = JSON.parse_string(content)
	if json_context == null:
		printerr("ERROR(文件解析失败): ", file_path)
		return null
		
	return json_context

func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	can_click = true
	next_sentence_sound.play()
	dialog_pause_timer.start()
	
