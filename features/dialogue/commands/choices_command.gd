class_name ChoicesCommand
extends DialogueCommand


## 显示选项并暂停 Runner，等待玩家作出选择。
func execute(
	_state: DialogueState,
	presenter: StoryPresenter
) -> DialogueCommandResult:
	presenter.show_choices(value as Array)
	return DialogueCommandResult.wait_for_input()
