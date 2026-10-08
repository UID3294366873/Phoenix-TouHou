class_name StoryScene
extends Node

## 信号方向：StoryScene -> 测试、存档或其他上层系统；通知某个剧情文件已开始。
signal story_file_started(file_path: String)
## 信号方向：StoryScene -> 测试或应用外壳；通知整段剧情已经结束。
signal story_finished

@export_file("*.json") var initial_story_file: String = \
	"res://content/story/first_scene.json"
@export var quit_on_finish: bool = true
@export var file_jump_transition: StringName = &"fade"

@onready var _presenter: StoryPresenter = %StoryPresenter
@onready var _runner: DialogueRunner = %DialogueRunner

var _transitioning: bool = false


## 装配 Presenter、Runner 之间的信号，并启动入口剧情文件。
func _ready() -> void:
	_runner.configure(_presenter)
	_presenter.advance_requested.connect(_on_advance_requested)
	_presenter.choice_selected.connect(_on_choice_selected)
	_runner.file_jump_requested.connect(_on_file_jump_requested)
	_runner.finished.connect(_on_story_finished)
	_start_story(initial_story_file)


## 接收 Presenter 的推进请求：先补全文字，再在下一次输入时推进命令流。
func _on_advance_requested() -> void:
	if _transitioning:
		return
	if _presenter.is_text_animating():
		_presenter.skip_text_animation()
		return
	_presenter.play_advance_sound()
	_runner.resume_input()


## 接收 Presenter 的选项结果，并在非转场期间交给 Runner 跳转。
func _on_choice_selected(target_anchor: StringName) -> void:
	if _transitioning:
		return
	_runner.choose(target_anchor)


## 编排跨文件流程：遮住画面、加载目标 JSON、再揭开画面。
func _on_file_jump_requested(file_path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	await _presenter.transition_out(file_jump_transition)
	_start_story(file_path)
	await _presenter.transition_in(file_jump_transition)
	_transitioning = false


## 处理 Runner 的结束通知，并按配置决定是否退出游戏。
func _on_story_finished() -> void:
	print("END OF GAME")
	story_finished.emit()
	if quit_on_finish:
		get_tree().quit()


## 加载指定 JSON 为程序，并交给 Runner 从头开始执行。
func _start_story(file_path: String) -> void:
	var program: DialogueProgram = DialogueLoader.load_file(file_path)
	story_file_started.emit(file_path)
	_runner.start(program)
