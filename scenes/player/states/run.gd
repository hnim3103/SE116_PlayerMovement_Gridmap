extends PlayerState


func _enter() -> void:
	obj.change_animation("run")


func _exit() -> void:
	# Trả tốc độ animation về bình thường khi rời Run.
	obj.anim_player.speed_scale = 1.0


func _update(_delta: float) -> void:
	var is_moving := control_moving()

	if Input.is_action_pressed("sprint"):
		obj.anim_player.speed_scale = obj.sprint_multiplier
	else:
		obj.anim_player.speed_scale = 1.0

	if control_dash():
		return

	if control_jump():
		return

	if not obj.is_on_floor():
		change_state(fsm.states.fall)
	elif not is_moving:
		change_state(fsm.states.idle)