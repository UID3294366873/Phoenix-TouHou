class_name TextBlipSound
extends AudioStreamPlayer

const SOUNDS: Dictionary = {
	"male": preload("res://resources/blip_sounds/sfx-blipmale.wav"),
	"female": preload("res://resources/blip_sounds/sfx-blipfemale.wav"),
}


## 根据角色资料中的性别选择并播放对应的文字音效。
func play_sound(character_details: Dictionary) -> void:
	var character_gender: String = str(character_details["gender"])
	stream = SOUNDS[character_gender] as AudioStream
	play()
