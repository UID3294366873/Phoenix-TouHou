class_name GotoCommand
extends DialogueCommand


## 返回 anchor 跳转请求，由 Runner 使用预建索引完成定位。
func execute(
	_state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	return DialogueCommandResult.jump_to_anchor(StringName(str(value)))
