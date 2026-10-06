extends PlayerState


func _enter() -> void:
	obj.change_animation("jump")


func _update(_delta: float) -> void:
	var is_moving := control_moving()

	if control_wall():
		return

	if control_dash():
		return

	if control_jump():
		return

	if obj.is_on_floor():
		if is_moving:
			change_state(fsm.states.run)
		else:
			change_state(fsm.states.idle)
	elif obj.velocity.y < 0.0:
		change_state(fsm.states.fall)