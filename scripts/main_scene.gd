extends Node2D

@onready var character_sprite = $CharacterAndUI/CharacterControl/CharacterSprite
@onready var dialog_ui = $CharacterAndUI/DialogUI
@onready var next_sentence_sound = $NextSentenceSound
@onready var dialog_pause_timer = $DialogPauseTimer
@onready var background = %Background

var transition_effect: String
var dialog_file: String = "res://resources/story/first_scene.json"
var dialog_index: int = 0
var can_click: bool = true

var dialog_lines : Array = []

func _ready() -> void:
	dialog_lines = load_dialog(dialog_file)
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	dialog_ui.choice_selected.connect(_on_choice_selected)
	dialog_pause_timer.timeout.connect(_on_dialog_pause_timeout)
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
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

func process_current_line(callback = null, arg = null):
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("ERROR(剧本索引超出限制范围): ",dialog_index)
		return
		
	var line = dialog_lines[dialog_index]
	print(line)
	if line.has("next_scene"):
		# 此命令将被用于切换场景
		# 该命令当前实现将切换背景与切换对话混淆，之后要把逻辑分开
		var next_scene = line["next_scene"]
		if not next_scene.is_empty():
			dialog_file = "res://resources/story/" + next_scene + ".json"
		else:
			dialog_file = ""
		
		transition_effect = line.get("transition", "fade")
		SceneManager.transition_out(transition_effect)
		
		return
		
	if line.has("location"):
		# 此命令用于切换背景，该命令应该单独占一行
		# 后续将更改为使用ground命令来展示/切换背景
		# location将用于切换角色立绘位置
		var background_file_path = "res://assets/images/" + line["location"] + ".png"
		if FileAccess.file_exists(background_file_path):
			background.texture = load(background_file_path)
		else:
			printerr("ERROR(文件不存在)", background_file_path)
		dialog_index += 1
		process_current_line()
		
		
	if line.has("music"):
		# 该命令可以用来切换音乐，预留
		pass
	
	if line.has("goto"): 
		# 跳转语句
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
	
	if line.has("anchor"): 
		# anchor命令用于与goto命令搭配使用，anchor的值将作为goto的参数
		# 使用goto命令后，将调转到其值对于的anchor命令所在的地方
		# anchor语句将被跳过
		dialog_index += 1
		process_current_line()
		return
	
	if line.has("show_character"):
		# 此命令用于切换立绘，无该参数时默认为speaker值所对应立绘
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, line.get("expression", ""), false)
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, line.get("expression", ""), true)

	if line.has("choices"):
		# 用于标记选项语句
		dialog_ui.display_choices(line["choices"])
		can_click = false
		return
	elif line.has("text"):
		# text命令的值是将被展示到对话框的内容
		# 后续要更改命令命名，并增添处理其内文本命令或参数的功能
		# 需要有一个专门的类来处理
		# 此处因为暂时还没设计具体的命令，故直接全部展示到对话框中
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(speaker_name, line["text"])
	else:
		dialog_index += 1
		process_current_line()
	
	#printerr("ERROR(无效语句): ", line)
	if callback:
		callback.call(arg)
	

func get_anchor_position(anchor: String):
	# 遍历整个脚本过于繁琐了，之后要预先将anchor位置计算出来并存入字典中，需要时直接取用，时间复杂度降为O(1)
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
	# 若找不到achor
	printerr("ERROR(未找到anchor): ", anchor)
	
func _on_text_animation_done():
	character_sprite.play_idle_animation()

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
	if anchor:
		dialog_index = get_anchor_position(anchor)
	can_click = true
	next_sentence_sound.play()
	dialog_pause_timer.start()
	

func _on_transition_out_completed():
	if dialog_file:
		dialog_lines = load_dialog(dialog_file) # 加载新对话内容
		dialog_index = 0 # 重置
		var first_line = dialog_lines[dialog_index]
		if first_line.has("location"):
			background.texture = load("res://assets/images/"+ first_line["location"] + ".png")
			dialog_index += 1
			
		SceneManager.transition_in(transition_effect)
			
			
	else:
		print("END OF GAME")
		get_tree().quit()
	
func _on_transition_in_completed():
	process_current_line() # 开始下一段对话
