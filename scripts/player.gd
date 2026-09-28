extends CharacterBody2D

var move_speed := 100


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	print(direction)
	$AnimationTree.set('parameters/MoveStateMachine/idle/blend_position', direction)
	velocity = direction * move_speed
	move_and_slide()
