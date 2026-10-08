class_name SpeakerCommand
extends DialogueCommand


## 更新当前说话人，并重置该角色的表情与说话状态。
func execute(
	state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	var speaker: StringName = StringName(str(value))
	state.current_speaker = speaker
	state.portrait_character = speaker
	state.expression = &""
	state.portrait_is_talking = true
	return DialogueCommandResult.proceed()
