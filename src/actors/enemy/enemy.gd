class_name Enemy extends GridActor

signal hit_trail(cell: Vector2i)

@export var start_direction := Vector2i(1, 1)

var direction: Vector2i

func reset() -> void:
	super.reset()
	direction = start_direction

func deflect() -> void:
	_bounce(GridData.Cell.TRAIL)

func _step() -> void:
	_bounce(GridData.Cell.LAND)
	var next := cell + direction
	match map.get_cell_type(next):
		GridData.Cell.TRAIL: 
			hit_trail.emit(next)
		GridData.Cell.SEA:
			_move_to(next)
		GridData.Cell.LAND:
			pass

func _bounce(cell_type: GridData.Cell) -> void:
	var blocked_x := map.get_cell_type(cell + Vector2i(direction.x, 0)) == cell_type
	var blocked_y := map.get_cell_type(cell + Vector2i(0, direction.y)) == cell_type
	var blocked_diag := map.get_cell_type(cell + direction) == cell_type
	if blocked_x:
		direction.x = -direction.x
	if blocked_y:
		direction.y = -direction.y
	if blocked_diag and not (blocked_x or blocked_y):
		direction = -direction
