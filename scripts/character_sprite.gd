extends Node2D

@onready var animated_sprite = $CharacterAnimated2D

func _ready() -> void:
	pass 

func change_character(character_name: Character.Name, expression: String, is_talking: bool = true):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	var stance = "talking" if is_talking else "idle"
	var animation_name = expression + "-" + stance if expression else stance
	
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		# 检查animation_name是否存在，若不存在，报错并且播放默认表情
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			animated_sprite.play(stance)

	else:
		play_idle_animation()

func play_idle_animation():
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("idle"):
		var idle_expression = last_animation.replace("talking", "idle")
		if animated_sprite.sprite_frames.has_animation(idle_expression):
			animated_sprite.play(idle_expression)
		else:
			animated_sprite.play("idle")
	
