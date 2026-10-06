extends Node2D

# 在两个场景之间创造过度动画： 目前暂定为淡入淡出，滑入滑出四个效果
	# 淡入淡出：通过先将CanvasLayer下ColorRect设为全黑，将透明度从0增加到100即位淡入，反之为淡出
	# 滑入画出：只需调整CanvasLayer下ColorRect的x坐标的值	
# 管理场景的停止与加载（生命周期）

signal transition_out_completed # 标记出场动画结束
signal transition_in_completed # 标记入场动画结束

var transition_layer: CanvasLayer
var transition_rect: ColorRect

var transition_time: float = 0.5

func _ready():
	transition_layer = CanvasLayer.new() # 初始化CanvasLayer
	transition_layer.layer = 999 # 使其在所有图层之上
	
	transition_rect = ColorRect.new() # 初始化ColorRect
	transition_rect.color = Color.BLACK # 为其设置颜色为黑色
	
	# 使其占据整个画面
	transition_rect.anchor_right = 1.0
	transition_rect.anchor_bottom = 1.0
	
	transition_rect.visible = false # 设置为不可见
	
	transition_layer.add_child(transition_rect) # 将rect设为layer的子结点
	get_tree().root.add_child.call_deferred(transition_layer) # 将layer添加到根节点
	
	
func transition_out(effect: String = "fade"):
	match effect:
		"fade":
			_fade_out()
		"slide":
			_slide_out()
		_:
			printerr("ERROR(转场效果不存在): ", effect)

func transition_in(effect: String = "fade"):
	match effect:
		"fade":
			_fade_in()
		"slide":
			_slide_in()
		_:
			printerr("ERROR(转场效果不存在): ", effect)

func _fade_out():
	# 初始化
	transition_rect.position = Vector2.ZERO
	transition_rect.modulate.a = 0
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, transition_time)
	tween.tween_callback(func():
		transition_out_completed.emit()
		)

func _fade_in():
	transition_rect.position = Vector2.ZERO
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, transition_time)
	tween.tween_callback(func():
		transition_rect.visible = false
		transition_in_completed.emit()
	)

func _slide_out(): # 从右向左
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var viewport_size = get_viewport_rect().size # 获取游戏窗口尺寸
	transition_rect.position.x = viewport_size.x
	transition_rect.position.y = 0
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, transition_time)
	tween.tween_callback(func():transition_out_completed.emit())
	
func _slide_in(): # 从左向右
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var viewport_size = get_viewport_rect().size
	transition_rect.position.x = 0
	transition_rect.position.y = 0
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", -viewport_size.x, transition_time)
	tween.tween_callback(func():
		transition_rect.visible = false
		transition_in_completed.emit()
		)
