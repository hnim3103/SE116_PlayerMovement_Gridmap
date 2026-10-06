extends PlayerState


func _enter() -> void:
	obj.change_animation("run")  # Dùng tạm animation hiện có.
	timer = obj.dash_duration
	obj.dash_cooldown_left = obj.dash_cooldown
	obj.air_dash_used = true
	obj.gravity_multiplier = 0.0
	obj.velocity = obj.dash_direction * obj.dash_speed
	obj.change_direction(BaseCharacter.direction_from_input(
		Vector2(obj.dash_direction.x, obj.dash_direction.z)))


func _exit() -> void:
	obj.gravity_multiplier = 1.0
	obj.stop_horizontal()


func _update(delta: float) -> void:
	timer -= delta
	if not obj.is_on_floor():
		obj.air_dash_used = true
	# Dùng tiếp xúc frame trước; không lướt xuyên tường.
	if obj.is_on_wall() and obj.get_wall_normal().dot(obj.dash_direction) < -0.2:
		finish_air_action()
		return
	if timer <= 0.0:
		finish_air_action()
		return
	obj.velocity = obj.dash_direction * obj.dash_speed
