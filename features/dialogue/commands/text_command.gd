class_name TextCommand
extends DialogueCommand


## 将累积的角色状态与文字交给 Presenter，并等待下一次玩家输入。
func execute(
	state: DialogueState,
	presenter: StoryPresenter
) -> DialogueCommandResult:
	presenter.show_line(
		state.current_speaker,
		state.portrait_character,
		state.expression,
		state.portrait_is_talking,
		str(value)
	)
	return DialogueCommandResult.wait_for_input()
