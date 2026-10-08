class_name MusicCommand
extends DialogueCommand


## 把音乐标识交给 Presenter 的音频接口。
func execute(
	_state: DialogueState,
	presenter: StoryPresenter
) -> DialogueCommandResult:
	presenter.play_music(StringName(str(value)))
	return DialogueCommandResult.proceed()
