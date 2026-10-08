class_name DialogueRunner
extends Node

## 信号方向：DialogueRunner -> StoryScene；请求上层执行跨 JSON 加载和转场。
signal file_jump_requested(file_path: String)
## 信号方向：DialogueRunner -> StoryScene；通知当前剧情已经执行完毕。
signal finished

var _program: DialogueProgram = null
var _state: DialogueState = DialogueState.new()
var _presenter: StoryPresenter = null
var _waiting_for_input: bool = false
var _is_running: bool = false


## 注入表现接口，使 Runner 不需要查找任何场景节点。
func configure(presenter: StoryPresenter) -> void:
	_presenter = presenter


## 重置运行状态并从新程序的第一条命令执行到阻塞点。
func start(program: DialogueProgram) -> void:
	_program = program
	_state.reset()
	_waiting_for_input = false
	_run_until_blocked()


## 响应普通推进输入，从等待点继续执行。
func resume_input() -> void:
	if not _waiting_for_input:
		return
	_waiting_for_input = false
	_run_until_blocked()


## 响应选项输入；有目标时跳转，无目标时顺序继续。
func choose(target_anchor: StringName) -> void:
	if not _waiting_for_input:
		return
	_waiting_for_input = false
	_presenter.hide_choices()
	if target_anchor != &"":
		_jump_to_anchor(target_anchor)
	_run_until_blocked()


## 核心解释循环：连续执行即时命令，直到等待、跳文件或结束。
func _run_until_blocked() -> void:
	if _is_running or _program == null or _presenter == null:
		return

	_is_running = true
	while not _waiting_for_input:
		if _state.step_index >= _program.steps.size():
			_is_running = false
			finished.emit()
			return

		var step: DialogueStep = _program.steps[_state.step_index]
		if _state.command_index >= step.commands.size():
			_state.step_index += 1
			_state.command_index = 0
			continue

		var command: DialogueCommand = step.commands[_state.command_index]
		_state.command_index += 1
		var result: DialogueCommandResult = command.execute(_state, _presenter)

		match result.flow:
			DialogueCommandResult.Flow.CONTINUE:
				continue
			DialogueCommandResult.Flow.WAIT_FOR_INPUT:
				_waiting_for_input = true
			DialogueCommandResult.Flow.JUMP_TO_ANCHOR:
				_jump_to_anchor(result.target_anchor)
			DialogueCommandResult.Flow.JUMP_TO_FILE:
				_waiting_for_input = true
				_is_running = false
				file_jump_requested.emit(result.file_path)
				return
			DialogueCommandResult.Flow.END:
				_waiting_for_input = true
				_is_running = false
				finished.emit()
				return

	_is_running = false


## 使用程序索引重设步骤游标，并从目标步骤的第一条命令开始。
func _jump_to_anchor(anchor: StringName) -> void:
	_state.step_index = _program.anchor_position(anchor)
	_state.command_index = 0
