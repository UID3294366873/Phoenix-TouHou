class_name DialogueLoader
extends RefCounted


## 读取约定正确的 JSON，创建命令步骤，并预先建立 O(1) anchor 索引。
static func load_file(file_path: String) -> DialogueProgram:
	var json_text: String = FileAccess.get_file_as_string(file_path)
	var parsed_json: Variant = JSON.parse_string(json_text)
	var raw_steps: Array = parsed_json as Array
	var program: DialogueProgram = DialogueProgram.new()
	program.source_path = file_path

	for step_index in raw_steps.size():
		var raw_step: Array = raw_steps[step_index] as Array
		var step: DialogueStep = DialogueStep.new()

		for raw_command_value: Variant in raw_step:
			var raw_command: Dictionary = raw_command_value as Dictionary
			var raw_key: Variant = raw_command.keys()[0]
			var command_key: StringName = StringName(str(raw_key))
			var command: DialogueCommand = DialogueCommandFactory.create(raw_command)
			step.commands.append(command)

			if command_key == &"anchor":
				var anchor: StringName = StringName(str(raw_command[raw_key]))
				program.anchors[anchor] = step_index + 1

		program.steps.append(step)

	return program
