"""
控制角色立绘的显示、切换以及说话/待机动效。
当前 SpriteFrames 里只有单帧立绘，因此动效通过代码控制 scale/position 实现。
"""
extends Node2D

@onready var animated_sprite = $CharacterAnimated2D

var base_scale: Vector2
var base_position: Vector2
var is_talking: bool = false
var anim_time: float = 0.0

# 说话时的微动参数
const TALK_SPEED: float = 12.0
const TALK_SCALE_AMOUNT: float = 0.015
const TALK_OFFSET_AMOUNT: float = 1.5
# 待机时的呼吸参数
const IDLE_SPEED: float = 1.5
const IDLE_SCALE_AMOUNT: float = 0.005
const IDLE_OFFSET_AMOUNT: float = 0.5

func _ready() -> void:
	base_scale = animated_sprite.scale
	base_position = animated_sprite.position

func _process(delta: float) -> void:
	anim_time += delta
	if is_talking:
		var t = anim_time * TALK_SPEED
		animated_sprite.scale = base_scale * (1.0 + sin(t) * TALK_SCALE_AMOUNT)
		animated_sprite.position = base_position + Vector2(0, sin(t * 2.0) * TALK_OFFSET_AMOUNT)
	else:
		var t = anim_time * IDLE_SPEED
		animated_sprite.scale = base_scale * (1.0 + sin(t) * IDLE_SCALE_AMOUNT)
		animated_sprite.position = base_position + Vector2(0, sin(t) * IDLE_OFFSET_AMOUNT)

func change_character(character_name: Character.Name, _is_talking: bool = true):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.play("normal")
		show()

func start_talking():
	is_talking = true
	anim_time = 0.0

func stop_talking():
	is_talking = false

func play_idle_animation():
	animated_sprite.play("idle")
