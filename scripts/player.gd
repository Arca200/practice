extends CharacterBody2D

@export var move_speed: float = 100.0

var _last_direction := Vector2.DOWN

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine: AnimationNodeStateMachinePlayback = (
	animation_tree.get(&"parameters/MoveStateMachine/playback")
	as AnimationNodeStateMachinePlayback
)


func _physics_process(_delta: float) -> void:
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

	velocity = input_direction * move_speed

	var target_state := &"move" if is_moving else &"idle"
	if move_state_machine.get_current_node() != target_state:
		move_state_machine.travel(target_state)

	move_and_slide()


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	pass
