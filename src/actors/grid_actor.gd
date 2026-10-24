class_name GridActor extends Node2D

@export var map: Map
@export_range(1, 25) var steps_per_second := 10
@export var start_cell := Vector2i.ZERO

var cell: Vector2i
var step_timer: float
var from_pos: Vector2
var to_pos: Vector2

func _ready() -> void:
	reset()

func reset() -> void:
	step_timer = 0
	_move_to(start_cell)
	from_pos = to_pos
	position = to_pos

func _process(_delta: float) -> void:
	var tick := 1.0 / Engine.physics_ticks_per_second
	var elapsed := step_timer + Engine.get_physics_interpolation_fraction() * tick
	var alpha := clampf(elapsed / _step_time(), 0.0, 1.0)
	position = from_pos.lerp(to_pos, alpha)

func _physics_process(delta: float) -> void:
	step_timer += delta
	while step_timer >= _step_time():
		step_timer -= _step_time()
		from_pos = to_pos
		_step()

func _step() -> void:
	pass

func _move_to(new_cell: Vector2i) -> void:
	cell = new_cell
	to_pos = map.cell_to_world(cell)

func _step_time() -> float:
	return 1.0 / steps_per_second
