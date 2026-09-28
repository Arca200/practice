extends CharacterBody2D

@export var move_speed: float = 100.0

# GDScript 的 enum 本质是字典：Tool.keys() 就能取回 "axe"/"hoe"/"water"
enum Tool {axe, hoe, water}


var current_tool: Tool = Tool.axe

var _last_direction := Vector2.DOWN

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine: AnimationNodeStateMachinePlayback = (
	animation_tree.get(&"parameters/MoveStateMachine/playback")
	as AnimationNodeStateMachinePlayback
)
@onready var tool_state_machine: AnimationNodeStateMachinePlayback = (
	animation_tree.get(&"parameters/ToolStateMachine/playback")
	as AnimationNodeStateMachinePlayback
)

func _physics_process(_delta: float) -> void:
	# 处理工具切换
	if Input.is_action_just_pressed("next_tool"):
		_switch_tool(1)

	if Input.is_action_just_pressed("prev_tool"):
		_switch_tool(-1)

	var input_direction := Input.get_vector(
		&"move_left", &"move_right", &"move_up", &"move_down"
	)
	var is_moving := input_direction != Vector2.ZERO

	if is_moving:
		_last_direction = input_direction.sign()

	animation_tree.set(
		&"parameters/MoveStateMachine/idle/blend_position", _last_direction
	)
	animation_tree.set(
		&"parameters/MoveStateMachine/move/blend_position", _last_direction
	)

	if Input.is_action_just_pressed("use_tool"):
		# 先让工具状态机回到对应工具状态，再请求 OneShot 播一次
		tool_state_machine.start(StringName(Tool.keys()[current_tool]))
		animation_tree.set(
			&"parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		)
	else:
		var target_state := &"move" if is_moving else &"idle"
		if move_state_machine.get_current_node() != target_state:
			move_state_machine.travel(target_state)
		
	velocity = input_direction * move_speed
	move_and_slide()


func _switch_tool(step: int) -> void:
	current_tool = posmod(current_tool + step, Tool.size()) as Tool
	print(Tool.keys()[current_tool])


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	pass
