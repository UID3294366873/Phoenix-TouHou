class_name ShowCharacterCommand
extends DialogueCommand


## 指定非说话角色立绘，并标记其使用 idle 动画。
func execute(
	state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	state.portrait_character = StringName(str(value))
	state.portrait_is_talking = false
	return DialogueCommandResult.proceed()
