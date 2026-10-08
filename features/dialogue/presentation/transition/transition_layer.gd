class_name TransitionLayer
extends CanvasLayer

## 信号方向：TransitionLayer -> StoryScene、测试或其他观察者；通知转场开始。
signal transition_started(direction: StringName, effect_id: StringName)
## 信号方向：TransitionLayer -> StoryScene、测试或其他观察者；通知转场结束。
signal transition_finished(direction: StringName, effect_id: StringName)

@export_range(0.0, 5.0, 0.05) var duration: float = 0.5

@onready var _overlay: ColorRect = %FadeOverlay

var _active_tween: Tween = null
var _transitioning: bool = false


## 初始化最高显示层级、暂停时处理模式和默认鼠标穿透状态。
func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


## 返回遮罩是否正在执行转场。
func is_transitioning() -> bool:
	return _transitioning


## 播放遮住画面的出场效果，并保持遮罩可见等待内容切换。
func play_out(effect_id: StringName = &"fade") -> void:
	_begin_transition()
	transition_started.emit(&"out", effect_id)
	match effect_id:
		&"slide":
			await _slide_out()
		_:
			await _fade_out()
	transition_finished.emit(&"out", effect_id)


## 播放揭开画面的入场效果，结束后恢复鼠标穿透。
func play_in(effect_id: StringName = &"fade") -> void:
	_begin_transition()
	transition_started.emit(&"in", effect_id)
	match effect_id:
		&"slide":
			await _slide_in()
		_:
			await _fade_in()
	_overlay.hide()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transitioning = false
	transition_finished.emit(&"in", effect_id)


## 终止旧 Tween，显示遮罩并阻止转场期间误点 UI。
func _begin_transition() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_transitioning = true
	_overlay.show()
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP


## 将黑色遮罩从透明渐变到不透明。
func _fade_out() -> void:
	_overlay.position = Vector2.ZERO
	_overlay.modulate.a = 0.0
	_active_tween = create_tween()
	_active_tween.tween_property(_overlay, "modulate:a", 1.0, duration)
	await _active_tween.finished


## 将黑色遮罩从不透明渐变到透明。
func _fade_in() -> void:
	_overlay.position = Vector2.ZERO
	_overlay.modulate.a = 1.0
	_active_tween = create_tween()
	_active_tween.tween_property(_overlay, "modulate:a", 0.0, duration)
	await _active_tween.finished


## 将黑色遮罩从屏幕右侧滑入并覆盖画面。
func _slide_out() -> void:
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	_overlay.modulate.a = 1.0
	_overlay.position = Vector2(viewport_width, 0.0)
	_active_tween = create_tween()
	_active_tween.tween_property(_overlay, "position:x", 0.0, duration)
	await _active_tween.finished


## 将黑色遮罩向屏幕左侧滑出并揭开画面。
func _slide_in() -> void:
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	_overlay.modulate.a = 1.0
	_overlay.position = Vector2.ZERO
	_active_tween = create_tween()
	_active_tween.tween_property(_overlay, "position:x", -viewport_width, duration)
	await _active_tween.finished
