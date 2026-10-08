class_name AnchorCommand
extends DialogueCommand


## 跳过仅用于索引定位的 anchor 标记。
func execute(
	_state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	return DialogueCommandResult.proceed()
