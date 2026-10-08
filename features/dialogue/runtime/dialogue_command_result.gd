class_name DialogueCommandResult
extends RefCounted

enum Flow {
	CONTINUE,
	WAIT_FOR_INPUT,
	JUMP_TO_ANCHOR,
	JUMP_TO_FILE,
	END,
}

var flow: Flow = Flow.CONTINUE
var target_anchor: StringName = &""
var file_path: String = ""


## 创建“继续执行”的结果。
static func proceed() -> DialogueCommandResult:
	return DialogueCommandResult.new()


## 创建“等待玩家输入”的结果。
static func wait_for_input() -> DialogueCommandResult:
	var result: DialogueCommandResult = DialogueCommandResult.new()
	result.flow = Flow.WAIT_FOR_INPUT
	return result


## 创建“跳到当前文件 anchor”的结果。
static func jump_to_anchor(anchor: StringName) -> DialogueCommandResult:
	var result: DialogueCommandResult = DialogueCommandResult.new()
	result.flow = Flow.JUMP_TO_ANCHOR
	result.target_anchor = anchor
	return result


## 创建“切换到另一个 JSON 文件”的结果。
static func jump_to_file(target_file_path: String) -> DialogueCommandResult:
	var result: DialogueCommandResult = DialogueCommandResult.new()
	result.flow = Flow.JUMP_TO_FILE
	result.file_path = target_file_path
	return result


## 创建“结束剧情”的结果。
static func finish() -> DialogueCommandResult:
	var result: DialogueCommandResult = DialogueCommandResult.new()
	result.flow = Flow.END
	return result
