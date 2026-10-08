class_name BackgroundCommand
extends DialogueCommand


## 请求 Presenter 切换背景，然后继续执行同一步的后续命令。
func execute(
	_state: DialogueState,
	presenter: StoryPresenter
) -> DialogueCommandResult:
	presenter.set_background(StringName(str(value)))
	return DialogueCommandResult.proceed()
