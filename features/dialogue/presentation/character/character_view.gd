class_name CharacterView
extends Node2D

@onready var _animated_sprite: AnimatedSprite2D = $CharacterAnimated2D

var _current_expression: String = ""


## 切换角色帧资源、表情和 talking/idle 姿态；无资源时隐藏立绘。
func change_character(
	character_name: CharacterCatalog.Name,
	expression: String,
	is_talking: bool = true
) -> void:
	var character_details: Dictionary = \
		CharacterCatalog.CHARACTER_DETAILS[character_name]
	var sprite_frames: SpriteFrames = character_details["sprite_frames"] as SpriteFrames
	_current_expression = _base_expression(expression)

	if sprite_frames != null:
		_animated_sprite.show()
		_animated_sprite.sprite_frames = sprite_frames
		_play_stance("talking" if is_talking else "idle")
	else:
		_animated_sprite.hide()


## 播放当前角色和表情对应的 idle 动画。
func play_idle_animation() -> void:
	_play_stance("idle")


## 播放当前角色和表情对应的 talking 动画。
func play_talking_animation() -> void:
	_play_stance("talking")


## 组合表情与姿态名称，并在缺少组合动画时回退到基础姿态。
func _play_stance(stance: String) -> void:
	var animation_name: String = stance
	if not _current_expression.is_empty():
		animation_name = "%s-%s" % [_current_expression, stance]
	if _animated_sprite.sprite_frames.has_animation(animation_name):
		_animated_sprite.play(animation_name)
	else:
		_animated_sprite.play(stance)


## 将带 `-talking`/`-idle` 后缀的表达式归一化为基础表情名。
func _base_expression(expression: String) -> String:
	if expression in ["", "default", "idle", "talking"]:
		return ""
	if expression.ends_with("-talking"):
		return expression.substr(0, expression.length() - "-talking".length())
	if expression.ends_with("-idle"):
		return expression.substr(0, expression.length() - "-idle".length())
	return expression
