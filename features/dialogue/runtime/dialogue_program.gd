class_name DialogueProgram
extends RefCounted

var source_path: String = ""
var steps: Array[DialogueStep] = []
var anchors: Dictionary[StringName, int] = {}


## 通过预建字典以 O(1) 时间返回 anchor 对应的步骤下标。
func anchor_position(anchor: StringName) -> int:
	return anchors[anchor]
