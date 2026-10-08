class_name DialogueCommandFactory
extends RefCounted

const COMMAND_SCRIPTS: Dictionary = {
	&"anchor": preload("res://features/dialogue/commands/anchor_command.gd"),
	&"background": preload("res://features/dialogue/commands/background_command.gd"),
	&"speaker": preload("res://features/dialogue/commands/speaker_command.gd"),
	&"expression": preload("res://features/dialogue/commands/expression_command.gd"),
	&"show_character": preload("res://features/dialogue/commands/show_character_command.gd"),
	&"text": preload("res://features/dialogue/commands/text_command.gd"),
	&"choices": preload("res://features/dialogue/commands/choices_command.gd"),
	&"goto": preload("res://features/dialogue/commands/goto_command.gd"),
	&"jump": preload("res://features/dialogue/commands/jump_command.gd"),
	&"music": preload("res://features/dialogue/commands/music_command.gd"),
	&"end": preload("res://features/dialogue/commands/end_command.gd"),
}


## 根据命令表创建一个命令实例，并写入该命令的原始值。
static func create(raw_command: Dictionary) -> DialogueCommand:
	var raw_key: Variant = raw_command.keys()[0]
	var command_key: StringName = StringName(str(raw_key))
	var command_script: Script = COMMAND_SCRIPTS[command_key]
	var command: DialogueCommand = command_script.new() as DialogueCommand
	command.configure(raw_command[raw_key])
	return command
