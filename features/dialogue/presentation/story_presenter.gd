class_name StoryPresenter
extends Node

## 信号方向：StoryPresenter -> StoryScene；转发 DialogueUI 的普通推进请求。
signal advance_requested
## 信号方向：StoryPresenter -> StoryScene；转发 DialogueUI 选中的 anchor。
signal choice_selected(target_anchor: StringName)
## 信号方向：StoryPresenter -> 音频系统或测试；请求播放指定音乐。
signal music_requested(music_id: StringName)

@onready var _background: TextureRect = %BackgroundView
@onready var _character_view: CharacterView = %CharacterView
@onready var _dialog_ui: DialogueUIView = %DialogueUI
@onready var _next_sentence_sound: AudioStreamPlayer = %NextSentenceSound
@onready var _transition_layer: TransitionLayer = %TransitionLayer


## 连接 UI 向上的输入信号，以及文字结束到角色 idle 动画的联动。
func _ready() -> void:
	_dialog_ui.advance_requested.connect(_on_advance_requested)
	_dialog_ui.choice_selected.connect(_on_choice_selected)
	_dialog_ui.text_animation_done.connect(_character_view.play_idle_animation)


## 根据背景标识加载贴图并更新背景视图。
func set_background(background_id: StringName) -> void:
	var background_path: String = "res://assets/images/%s.png" % background_id
	_background.texture = load(background_path) as Texture2D


## 根据剧情状态更新角色立绘、动画、说话人名称和文字内容。
func show_line(
	speaker_id: StringName,
	portrait_id: StringName,
	expression: StringName,
	portrait_is_talking: bool,
	text: String
) -> void:
	var speaker: CharacterCatalog.Name = CharacterCatalog.get_enum_from_string(
		str(speaker_id)
	)
	var displayed_id: StringName = portrait_id if portrait_id != &"" else speaker_id
	var displayed_character: CharacterCatalog.Name = \
		CharacterCatalog.get_enum_from_string(str(displayed_id))
	_character_view.change_character(
		displayed_character,
		str(expression),
		portrait_is_talking
	)
	_dialog_ui.change_line(speaker, text)


## 将选项数据交给 DialogueUI 创建按钮。
func show_choices(choices: Array) -> void:
	_dialog_ui.display_choices(choices)


## 隐藏当前选项列表。
func hide_choices() -> void:
	_dialog_ui.hide_choices()


## 返回文字逐字动画是否仍在播放。
func is_text_animating() -> bool:
	return _dialog_ui.animate_text


## 立即显示本句全部文字。
func skip_text_animation() -> void:
	_dialog_ui.skip_text_animation()


## 播放普通推进提示音。
func play_advance_sound() -> void:
	_next_sentence_sound.play()


## 向外部音频实现发送音乐播放请求。
func play_music(music_id: StringName) -> void:
	music_requested.emit(music_id)


## 等待转场遮罩完全覆盖画面。
func transition_out(effect_id: StringName) -> void:
	await _transition_layer.play_out(effect_id)


## 等待转场遮罩完全离开画面。
func transition_in(effect_id: StringName) -> void:
	await _transition_layer.play_in(effect_id)


## 把 DialogueUI 的推进事件向上转发给 StoryScene。
func _on_advance_requested() -> void:
	advance_requested.emit()


## 把 DialogueUI 的选项结果向上转发给 StoryScene。
func _on_choice_selected(target_anchor: StringName) -> void:
	choice_selected.emit(target_anchor)
