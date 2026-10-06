extends Control

signal text_animation_done
signal choice_selected
# 导入选项框UI场景
const ChoiceButtonScene = preload("res://scenes/player_choice.tscn")

@onready var dialog_line = $DialogBox/DialogLine
@onready var speaker_name = $SpeakerBox/SpeakerName
@onready var text_blip_sound = $TextBlipSound
@onready var sentence_pause_timer = $SentencePauseTimer
@onready var choice_list = %ChoiceList

const ANIMATION_SPEED : int = 12
const NO_SOUND_CHARS: Array = ["。", "！", "!", "？", "—", ".", "·", "-", "…", "：", ":", ",", "，", " "] # 停用词列表，包含中英双语
const END_OF_SENTENCE: Array = [".", "!", "?","。", "！", "？"] # 句末字符列表，包含中英

var animate_text: bool = false
var current_visible_characters: int = 0
var current_character_details: Dictionary

func _ready() -> void:
	choice_list.hide()
	sentence_pause_timer.timeout.connect(_on_sentence_pause_timeout)

func _process(delta: float) -> void:
	if animate_text and sentence_pause_timer.is_stopped(): # 若播放文字动画且句末暂停已结束
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			if dialog_line.visible_characters > current_visible_characters: 
				current_visible_characters = dialog_line.visible_characters
				var current_char  = dialog_line.text[current_visible_characters - 1]
				if current_visible_characters < dialog_line.text.length() and current_char in END_OF_SENTENCE: # 若尚未到达当前对话末尾 且 当前字符在句末字符列表
					sentence_pause_timer.start() # 调用句末暂停
				if current_char not in NO_SOUND_CHARS:	
					text_blip_sound.play_sound(current_character_details)
		else:
			if dialog_line.text[-1] not in NO_SOUND_CHARS:	
					text_blip_sound.play_sound(current_character_details)
					# 若对话最后一个字符不是停用词时，仍需播放打字音效
			animate_text = false
			text_animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	speaker_name.text = current_character_details["name"]
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true

func display_choices(choices: Array):
	# 为每个选项创建Button
	for child in choice_list.get_children():
		child.queue_free()
	for choice in choices:
		var choice_button = ChoiceButtonScene.instantiate()
		choice_button.text = choice["text"]
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice.get("goto", "")))
		choice_list.add_child(choice_button)

	choice_list.show()
	#_focus_first_choice.call_deferred()
	_focus_first_choice()
	
func _focus_first_choice() -> void:
	await get_tree().process_frame
	if choice_list.get_child_count() == 0:
		return

	var first_button: Button = choice_list.get_child(0)
	first_button.grab_focus()

func skip_text_animation():
	dialog_line.visible_ratio = 1


func _on_sentence_pause_timeout():
	# 什么也不做
	pass

func _on_choice_button_pressed(anchor: String):
	choice_selected.emit(anchor)
	choice_list.hide()
