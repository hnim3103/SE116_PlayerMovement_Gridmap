extends PlayerState


func _enter() -> void:
	obj.change_animation("idle")


func _update(_delta: float) -> void:
	var is_moving := control_moving()

	if control_dash():
		return

	if control_jump():
		return

	if not obj.is_on_floor():
		change_state(fsm.states.fall)
	elif is_moving:
		change_state(fsm.states.run)