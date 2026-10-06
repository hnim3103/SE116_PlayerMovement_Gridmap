class_name PlayerState
extends FSMState


func movement_input() -> Vector3:
	var input := Input.get_vector("left", "right", "up", "down")
	return Vector3(input.x, 0.0, input.y)

func cling_normal() -> Vector3:
	if obj.is_on_floor() or not obj.is_on_wall():
		return Vector3.ZERO
	if obj.velocity.y > 0.0 or obj.wall_regrab_left > 0.0:
		return Vector3.ZERO
	var normal := obj.get_wall_normal()
	# Chỉ bám mặt gần thẳng đứng, tránh nhận dốc cầu thang là tường.
	if absf(normal.y) > 0.2:
		return Vector3.ZERO
	normal = Vector3(normal.x, 0.0, normal.z).normalized()
	if movement_input().dot(normal) >= -0.2:
		return Vector3.ZERO
	return normal


func control_wall() -> bool:
	var normal := cling_normal()
	if normal.is_zero_approx():
		return false
	obj.wall_normal = normal
	# Bắt cả trường hợp nhấn Jump đúng lúc bắt đầu bám.
	if Input.is_action_just_pressed("jump"):
		change_state(fsm.states.walljump)
	else:
		change_state(fsm.states.wallcling)
	return true


func control_dash() -> bool:
	if not Input.is_action_just_pressed("dash"):
		return false
	if obj.dash_cooldown_left > 0.0:
		return false
	if not obj.is_on_floor() and obj.air_dash_used:
		return false
	var direction := movement_input()
	if direction.is_zero_approx():
		direction = Vector3.FORWARD.rotated(Vector3.UP, BaseCharacter.DIRECTION_YAW[obj.direction])
	obj.dash_direction = direction.normalized()
	change_state(fsm.states.dash)
	return true


func finish_air_action() -> void:
	if obj.is_on_floor():
		if movement_input().is_zero_approx():
			change_state(fsm.states.idle)
		else:
			change_state(fsm.states.run)
	elif obj.velocity.y > 0.0:
		change_state(fsm.states.jump)
	else:
		change_state(fsm.states.fall)

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	var is_moving: bool = input.length() > 0.1
	if is_moving:
		var speed := obj.movement_speed
		if Input.is_action_pressed("sprint"):
			speed *= obj.sprint_multiplier

		obj.change_direction(BaseCharacter.direction_from_input(input))
		obj.velocity.x = speed * input.x
		obj.velocity.z = speed * input.y

		return true
	else:
		obj.stop_horizontal()
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if not Input.is_action_just_pressed("jump"):
		return false

	if not obj.can_jump():
		return false

	obj.jump()
	change_state(fsm.states.jump)
	return true
	
