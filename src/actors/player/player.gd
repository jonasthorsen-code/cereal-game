class_name Player extends GridActor

signal died()
signal trail_completed()

const DIRECTIONS := {
	"move_up": Vector2i.UP,
	"move_right": Vector2i.RIGHT,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
}

var direction := Vector2i.ZERO
var queued := Vector2i.ZERO
var wait_for_release := false
var parry := Parry.new()

func reset() -> void:
	super.reset()
	direction = Vector2i.ZERO
	queued = Vector2i.ZERO
	wait_for_release = false

func try_parry() -> bool:
	return parry.consume(Time.get_ticks_msec())

func is_parry_open() -> bool:
	return parry.is_open(Time.get_ticks_msec())

func _unhandled_input(event: InputEvent) -> void:
	for action in DIRECTIONS:
		if event.is_action_pressed(action):
			var new: Vector2i = DIRECTIONS[action]
			if _is_drawing():
				if new != -direction:
					direction = new
			else:
				queued = new
				wait_for_release = false
	if event.is_action_pressed("parry") and _is_drawing():
		parry.press(Time.get_ticks_msec())

func _step() -> void:
	if not _is_drawing():
		if queued != Vector2i.ZERO:
			direction = queued
		elif wait_for_release:
			direction = Vector2i.ZERO
			if _held_direction() == Vector2i.ZERO:
				wait_for_release = false
		else:
			direction = _held_direction()
		queued = Vector2i.ZERO
		
	if direction == Vector2i.ZERO:
		return
	
	var next: Vector2i = cell + direction
	if not map.is_inside(next):
		direction = Vector2i.ZERO
		return
	
	match map.get_cell_type(next):
		GridData.Cell.TRAIL:
			died.emit()
		GridData.Cell.SEA:
			if not _is_drawing():
				parry.new_trip()
			map.add_trail(next)
			_move_to(next)
		GridData.Cell.LAND:
			var was_drawing := (map.get_cell_type(cell) == GridData.Cell.TRAIL)
			_move_to(next)
			if was_drawing:
				direction = Vector2i.ZERO
				wait_for_release = true
				trail_completed.emit()

func _is_drawing() -> bool:
	return map.get_cell_type(cell) == GridData.Cell.TRAIL

func _held_direction() -> Vector2i:
	for action in DIRECTIONS:
		if Input.is_action_pressed(action):
			return DIRECTIONS[action]
	return Vector2i.ZERO
