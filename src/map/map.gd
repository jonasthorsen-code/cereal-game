class_name Map extends Node2D

signal area_claimed(percent: float)
signal burn_reached_head()

@export_group("Grid")
@export_range(10, 200) var width: int = 80
@export_range(10, 200) var height: int = 60
@export_range(1, 8) var border: int = 2

@export var burn_steps_per_second := 40
@export var view: MapView

var claimed_count := 0
var trail := Trail.new()
var grid: GridData
var _burn_timer := 0.0

func _ready() -> void:
	grid = GridData.new(width, height)
	view.bind(grid)
	reset()

func reset() -> void:
	claimed_count = 0
	clear_trail()
	for x in width:
		for y in height:
			var is_border := x < border or y < border or x >= width - border or y >= height - border
			set_cell_type(Vector2i(x,y), GridData.Cell.LAND if is_border else GridData.Cell.SEA)

func _physics_process(delta: float) -> void:
	if not is_burning():
		return
	_burn_timer += delta
	while _burn_timer >= 1.0 / burn_steps_per_second and is_burning():
		_burn_timer -= 1.0 / burn_steps_per_second
		for cell in trail.tick_burn():
			set_cell_type(cell, GridData.Cell.SEA)
		if trail.head_reached():
			burn_reached_head.emit()
			return

func set_palette(p: Palette) -> void:
	view.set_palette(p)

func set_parry_highlight(on: bool) -> void:
	view.set_parry_highlight(on)

func get_pixel_size() -> Vector2:
	return view.get_pixel_size()

func is_inside(cell: Vector2i) -> bool:
	return grid.is_inside(cell)

func get_cell_type(cell: Vector2i) -> GridData.Cell:
	return grid.get_cell(cell)

func set_cell_type(cell: Vector2i, type: GridData.Cell) -> void:
	grid.set_cell(cell, type)

func cell_to_world(cell: Vector2i) -> Vector2:
	return view.cell_to_world(cell)

func add_trail(cell: Vector2i) -> void:
	set_cell_type(cell, GridData.Cell.TRAIL)
	trail.add(cell)

func close_trail(enemy_cells: Array[Vector2i]) -> void:
	for cell in trail.cells:
		set_cell_type(cell, GridData.Cell.LAND)
		claimed_count += 1
	trail.clear()
	claimed_count += grid.fill_unreachable(enemy_cells, GridData.Cell.SEA, GridData.Cell.LAND)
	area_claimed.emit(get_claimed_percent())

func clear_trail() -> void:
	for cell: Vector2i in trail.cells:
		set_cell_type(cell, GridData.Cell.SEA)
	trail.clear()

func get_claimed_percent() -> float:
	return 100 * float(claimed_count) / _get_claimable_cell_count()

func burn_trail(hit_cell: Vector2i) -> void:
	trail.start_burn(hit_cell)
	_burn_timer = 0

func is_burning() -> bool:
	return trail.is_burning()

func _get_claimable_cell_count() -> int:
	return (width - 2*border) * (height - 2*border)
