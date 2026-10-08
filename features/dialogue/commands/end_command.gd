class_name EndCommand
extends DialogueCommand


## 返回结束结果，终止当前剧情程序。
func execute(
	_state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	return DialogueCommandResult.finish()
