extends SceneTree

const STORY_SCENE: PackedScene = preload("res://app/story/story_scene.tscn")
const FIRST_STORY: String = "res://content/story/first_scene.json"
const SECOND_STORY: String = "res://content/story/second_scene.json"
const EMPTY_STORY: String = "res://content/story/test.json"

var _story_finished: bool = false
var _visited_files: Array[String] = []
var _music_ids: Array[StringName] = []
var _transition_directions: Array[StringName] = []


## SceneTree 启动后延迟执行测试，确保根视口已经可用。
func _initialize() -> void:
	_run_all_scenarios.call_deferred()


## 依次运行鼠标/转场回归以及所有 JSON 分支场景。
func _run_all_scenarios() -> void:
	await _run_mouse_advance_and_transition_scenario()
	await _run_scenario(
		"skip_branches",
		FIRST_STORY,
		[&"end", &"end"],
		[FIRST_STORY, SECOND_STORY],
		["END"],
		true
	)
	await _run_scenario(
		"first_choice_and_court_cases",
		FIRST_STORY,
		[&"", &"选项一", &"", &"court_cases"],
		[FIRST_STORY, SECOND_STORY],
		["好呀好呀！我最喜欢去公园了！", "被告实际上是无辜的，正如我所怀疑的。"],
		true
	)
	await _run_scenario(
		"second_choice_and_magic_tricks",
		FIRST_STORY,
		[&"", &"选项二", &"", &"magic_tricks"],
		[FIRST_STORY, SECOND_STORY],
		["我还有点事情，不来了", "我的下一个魔术，需要一位志愿者……"],
		true
	)
	await _run_scenario(
		"empty_story",
		EMPTY_STORY,
		[],
		[EMPTY_STORY],
		[],
		false
	)

	print("ALL_STORY_JSON_TESTS_PASS")
	quit(0)


## 使用真实鼠标事件确认“首次补全文字、再次推进、跨文件转场”的完整流程。
func _run_mouse_advance_and_transition_scenario() -> void:
	_visited_files.clear()
	_transition_directions.clear()

	var story_scene: StoryScene = STORY_SCENE.instantiate() as StoryScene
	story_scene.initial_story_file = FIRST_STORY
	story_scene.quit_on_finish = false
	story_scene.story_file_started.connect(_on_story_file_started)

	var runner: DialogueRunner = story_scene.get_node(
		"Runtime/DialogueRunner"
	) as DialogueRunner
	var presenter: StoryPresenter = story_scene.get_node(
		"Presentation/StoryPresenter"
	) as StoryPresenter
	var transition_layer: TransitionLayer = story_scene.get_node(
		"Presentation/TransitionLayer"
	) as TransitionLayer
	transition_layer.duration = 0.01
	transition_layer.transition_finished.connect(_on_transition_finished)

	root.add_child(story_scene)
	await process_frame
	runner.choose(&"end")
	assert(presenter.is_text_animating(), "mouse test: END line did not start typing")

	await _send_left_mouse_click()
	assert(
		not presenter.is_text_animating(),
		"mouse test: first click did not reveal the complete line"
	)

	await _send_left_mouse_click()
	var frame_budget: int = 240
	while (
		(SECOND_STORY not in _visited_files or transition_layer.is_transitioning())
		and frame_budget > 0
	):
		await process_frame
		frame_budget -= 1

	assert(frame_budget > 0, "mouse test: click did not advance to the next JSON")
	assert(
		_transition_directions == [&"out", &"in"],
		"mouse test: expected fade out then fade in"
	)

	story_scene.queue_free()
	await process_frame


## 向 Godot 输入管线发送一次完整的鼠标左键按下与释放。
func _send_left_mouse_click() -> void:
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(10.0, 10.0)
	Input.parse_input_event(press)
	await process_frame

	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = press.position
	Input.parse_input_event(release)
	await process_frame


## 驱动一条指定选择路线，并检查文件、台词、背景、音乐与转场结果。
func _run_scenario(
	scenario_name: String,
	initial_story: String,
	choice_targets: Array[StringName],
	expected_files: Array[String],
	expected_lines: Array[String],
	expects_office_music: bool
) -> void:
	_story_finished = false
	_visited_files.clear()
	_music_ids.clear()
	_transition_directions.clear()

	var story_scene: StoryScene = STORY_SCENE.instantiate() as StoryScene
	story_scene.initial_story_file = initial_story
	story_scene.quit_on_finish = false
	story_scene.story_file_started.connect(_on_story_file_started)
	story_scene.story_finished.connect(_on_story_finished)

	var runner: DialogueRunner = story_scene.get_node(
		"Runtime/DialogueRunner"
	) as DialogueRunner
	var presenter: StoryPresenter = story_scene.get_node(
		"Presentation/StoryPresenter"
	) as StoryPresenter
	presenter.music_requested.connect(_on_music_requested)
	var choice_list: VBoxContainer = story_scene.get_node(
		"Presentation/CharacterUILayer/DialogueUI/ChoicesContainer/ChoiceList"
	) as VBoxContainer
	var dialog_line: RichTextLabel = story_scene.get_node(
		"Presentation/CharacterUILayer/DialogueUI/DialogBox/DialogLine"
	) as RichTextLabel
	var background: TextureRect = story_scene.get_node(
		"Presentation/BackgroundLayer/BackgroundView"
	) as TextureRect
	var transition_layer: TransitionLayer = story_scene.get_node(
		"Presentation/TransitionLayer"
	) as TransitionLayer
	transition_layer.duration = 0.01
	transition_layer.transition_finished.connect(_on_transition_finished)

	root.add_child(story_scene)
	var choice_index: int = 0
	var seen_lines: Array[String] = []
	var frame_budget: int = 1000

	while not _story_finished and frame_budget > 0:
		await process_frame
		frame_budget -= 1
		if transition_layer.is_transitioning():
			continue
		if not dialog_line.text.is_empty() and dialog_line.text not in seen_lines:
			seen_lines.append(dialog_line.text)
		if choice_list.visible:
			assert(
				choice_index < choice_targets.size(),
				"%s: encountered an unexpected choice" % scenario_name
			)
			runner.choose(choice_targets[choice_index])
			choice_index += 1
		elif presenter.is_text_animating():
			presenter.skip_text_animation()
			runner.resume_input()
		else:
			runner.resume_input()

	assert(frame_budget > 0, "%s: story did not finish" % scenario_name)
	assert(
		choice_index == choice_targets.size(),
		"%s: not all scripted choices were used" % scenario_name
	)
	assert(
		_visited_files == expected_files,
		"%s: unexpected file traversal: %s" % [scenario_name, _visited_files]
	)
	for expected_line: String in expected_lines:
		assert(
			expected_line in seen_lines,
			"%s: line was not displayed: %s" % [scenario_name, expected_line]
		)

	if expects_office_music:
		assert(
			&"office_theme" in _music_ids,
			"%s: music command was not emitted" % scenario_name
		)
		assert(
			background.texture.resource_path == "res://assets/images/office.png",
			"%s: second story background was not displayed" % scenario_name
		)
		assert(
			_transition_directions == [&"out", &"in"],
			"%s: file jump did not complete both transition directions" % scenario_name
		)

	story_scene.queue_free()
	await process_frame


## 记录 StoryScene -> 测试的文件开始信号。
func _on_story_file_started(file_path: String) -> void:
	_visited_files.append(file_path)


## 记录 StoryScene -> 测试的剧情结束信号。
func _on_story_finished() -> void:
	_story_finished = true


## 记录 StoryPresenter -> 测试的音乐播放请求。
func _on_music_requested(music_id: StringName) -> void:
	_music_ids.append(music_id)


## 记录 TransitionLayer -> 测试的转场结束方向。
func _on_transition_finished(
	direction: StringName,
	_effect_id: StringName
) -> void:
	_transition_directions.append(direction)
