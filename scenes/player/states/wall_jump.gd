extends PlayerState


func _enter() -> void:
	obj.change_animation("jump")
	timer = obj.wall_jump_lock
	obj.wall_regrab_left = obj.wall_regrab_delay
	obj.velocity = obj.wall_normal * obj.wall_jump_push
	obj.velocity.y = obj.wall_jump_up
	obj.jump_count = 1  
	obj.coyote_timer = 0.0
	obj.change_direction(BaseCharacter.direction_from_input(
		Vector2(obj.wall_normal.x, obj.wall_normal.z)))


func _update(delta: float) -> void:
	timer -= delta
	if obj.is_on_ceiling():
		obj.velocity.y = minf(obj.velocity.y, 0.0)
	if timer <= 0.0 or obj.is_on_floor():
		finish_air_action()
