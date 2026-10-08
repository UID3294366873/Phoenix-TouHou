class_name DialogueCommand
extends RefCounted

var value: Variant


## 保存当前命令在 JSON 中携带的值。
func configure(raw_value: Variant) -> void:
	value = raw_value


## 执行命令；子类覆盖此方法并返回明确的控制流结果。
func execute(
	_state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	return DialogueCommandResult.proceed()
