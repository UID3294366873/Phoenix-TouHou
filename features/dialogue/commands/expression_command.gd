class_name ExpressionCommand
extends DialogueCommand


## 将后续文字使用的表情写入纯运行状态。
func execute(
	state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	state.expression = StringName(str(value))
	return DialogueCommandResult.proceed()
