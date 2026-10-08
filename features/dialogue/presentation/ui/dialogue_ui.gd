class_name DialogueUIView
extends Control

## 信号方向：DialogueUI -> StoryPresenter -> StoryScene；请求补全文字或推进剧情。
signal advance_requested
## 信号方向：DialogueUI -> StoryPresenter -> CharacterView；通知角色切回 idle。
signal text_animation_done
## 信号方向：DialogueUI -> StoryPresenter -> StoryScene；提交玩家选择的 anchor。
signal choice_selected(target_anchor: StringName)

const CHOICE_BUTTON_SCENE: PackedScene = preload("res://features/dialogue/presentation/ui/choice_button.tscn")
const ANIMATION_SPEED: int = 12
const NO_SOUND_CHARS: Array[String] = [
	"。", "！", "!", "？", "—", ".", "·", "-", "…", "：", ":", ",", "，", " "
]
const END_OF_SENTENCE: Array[String] = [".", "!", "?", "。", "！", "？"]

@onready var _dialog_line: RichTextLabel = $DialogBox/DialogLine
@onready var _speaker_name: Label = $SpeakerBox/SpeakerName
@onready var _text_blip_sound: TextBlipSound = $TextBlipSound
@onready var _sentence_pause_timer: Timer = $SentencePauseTimer
@onready var _choice_list: VBoxContainer = %ChoiceList

var animate_text: bool = false
var _current_visible_characters: int = 0
var _current_character_details: Dictionary = {}


## 初始化时隐藏编辑器中用于预览的选项列表。
func _ready() -> void:
	_choice_list.hide()


## 按帧推进文字可见比例，并在标点处暂停和播放打字音。
func _process(delta: float) -> void:
	if not animate_text or not _sentence_pause_timer.is_stopped():
		return
	if _dialog_line.text.is_empty():
		_finish_text_animation()
		return
	if _dialog_line.visible_ratio >= 1.0:
		_finish_text_animation()
		return

	_dialog_line.visible_ratio += (
		1.0 / float(_dialog_line.text.length())
	) * (float(ANIMATION_SPEED) * delta)
	if _dialog_line.visible_characters <= _current_visible_characters:
		return

	_current_visible_characters = _dialog_line.visible_characters
	var current_char: String = _dialog_line.text[_current_visible_characters - 1]
	if (
		_current_visible_characters < _dialog_line.text.length()
		and current_char in END_OF_SENTENCE
	):
		_sentence_pause_timer.start()
	if current_char not in NO_SOUND_CHARS:
		_text_blip_sound.play_sound(_current_character_details)


## 在 GUI 消费鼠标前捕获推进动作；选项显示时不允许普通推进穿透。
func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"next_line") or event.is_echo():
		return
	if _choice_list.visible:
		return
	get_viewport().set_input_as_handled()
	advance_requested.emit()


## 切换说话人和文本，并从第一个字符开始播放逐字动画。
func change_line(character_name: CharacterCatalog.Name, line: String) -> void:
	_current_character_details = CharacterCatalog.CHARACTER_DETAILS[character_name]
	_speaker_name.text = str(_current_character_details["name"])
	_current_visible_characters = 0
	_dialog_line.text = line
	_dialog_line.visible_characters = 0
	animate_text = true


## 根据剧情数据动态创建选项按钮并聚焦第一个按钮。
func display_choices(choices: Array) -> void:
	_clear_choices()
	for raw_choice: Variant in choices:
		var choice: Dictionary = raw_choice as Dictionary
		var choice_button: Button = CHOICE_BUTTON_SCENE.instantiate() as Button
		choice_button.text = str(choice["text"])
		var target_anchor: StringName = StringName(str(choice.get("goto", "")))
		choice_button.pressed.connect(
			_on_choice_button_pressed.bind(target_anchor)
		)
		_choice_list.add_child(choice_button)

	_choice_list.show()
	_focus_first_choice.call_deferred()


## 隐藏选项容器但不改变 Runner 状态。
func hide_choices() -> void:
	_choice_list.hide()


## 玩家首次推进时立即补全当前句子。
func skip_text_animation() -> void:
	if not animate_text:
		return
	_finish_text_animation()


## 完成逐字动画、停止标点计时器并发出完成信号。
func _finish_text_animation() -> void:
	_dialog_line.visible_characters = -1
	animate_text = false
	_sentence_pause_timer.stop()
	text_animation_done.emit()


## 在按钮完成布局后聚焦第一项，支持键盘和手柄选择。
func _focus_first_choice() -> void:
	if _choice_list.get_child_count() == 0:
		return
	var first_button: Button = _choice_list.get_child(0) as Button
	first_button.grab_focus()


## 移除上一组选项按钮，避免跨分支残留。
func _clear_choices() -> void:
	for child: Node in _choice_list.get_children():
		_choice_list.remove_child(child)
		child.queue_free()


## 隐藏选项并把按钮携带的 anchor 向上发送。
func _on_choice_button_pressed(target_anchor: StringName) -> void:
	_choice_list.hide()
	choice_selected.emit(target_anchor)
