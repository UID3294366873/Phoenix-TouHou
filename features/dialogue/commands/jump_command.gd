class_name JumpCommand
extends DialogueCommand


## 返回跨 JSON 文件请求；转场和加载由 StoryScene 编排。
func execute(
	_state: DialogueState,
	_presenter: StoryPresenter
) -> DialogueCommandResult:
	return DialogueCommandResult.jump_to_file(str(value))
