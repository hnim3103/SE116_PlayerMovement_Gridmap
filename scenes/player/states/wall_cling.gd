extends PlayerState


func _enter() -> void:
	obj.change_animation("fall")  # Dùng animation đang có.
	obj.fall_speed_limit = obj.wall_slide_speed
	obj.velocity.y = minf(obj.velocity.y, 0.0)


func _exit() -> void:
	obj.fall_speed_limit = INF


func _update(_delta: float) -> void:
	if obj.is_on_floor():
		finish_air_action()
		return
	var normal := cling_normal()
	if normal.is_zero_approx():
		obj.stop_horizontal()
		change_state(fsm.states.fall)
		return
	obj.wall_normal = normal
	if Input.is_action_just_pressed("jump"):
		change_state(fsm.states.walljump)
		return

	obj.velocity.x = -normal.x * 0.5
	obj.velocity.z = -normal.z * 0.5
