extends GutTest

var grid: GridData

var index_cases: Array = ParameterFactory.named_parameters(
	['cell', 'expected'],
	[
		[Vector2i(0, 0), 0],
		[Vector2i(4, 0), 4],
		[Vector2i(0, 1), 5],
		[Vector2i(0, 5), 25],
		[Vector2i(4, 5), 29],
	])

func before_each() -> void:
	grid = GridData.new(5, 6)

func test_outside_counts_as_land() -> void:
	assert_eq(grid.get_cell(Vector2i(-1, 0)), GridData.Cell.LAND)

func test_index_of(params = use_parameters(index_cases)) -> void:
	assert_eq(grid.index_of(params.cell), params.expected)

func test_index_math() -> void:
	var chosen_position := Vector2i(3, 5)
	grid.set_cell(chosen_position, GridData.Cell.LAND)
	var count := 0
	var found_position: Vector2i
	for x in grid.width:
		for y in grid.height:
			if grid.get_cell(Vector2i(x, y)) == GridData.Cell.LAND:
				count += 1
				found_position = Vector2i(x, y)

	assert_eq(count, 1)
	assert_eq(found_position, chosen_position)

func test_fill_unreachable_with_no_seeds() -> void:
	var seeds: Array[Vector2i] = []
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 30)

func test_fill_unreachable_with_seed_outside_grid() -> void:
	var seeds: Array[Vector2i] = [Vector2i(-1, 0)]
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 30)

func test_fill_unreachable_with_diagonal_gap() -> void:
	var seeds: Array[Vector2i] = [Vector2i(0, 0)]
	grid.set_cell(Vector2i(0, 1), GridData.Cell.LAND)
	grid.set_cell(Vector2i(1, 0), GridData.Cell.LAND)
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 27)

func test_fill_unreachable_with_enclosed_pocket() -> void:
	var seeds: Array[Vector2i] = [Vector2i(0, 0)]
	_enclose_point(Vector2i(2, 2))
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 1)
	assert_eq(grid.get_cell(Vector2i(2, 2)), GridData.Cell.LAND)

func test_fill_unreachable_with_vertical_wall_and_seed_on_one_side() -> void:
	for y in grid.height:
		grid.set_cell(Vector2i(2, y), GridData.Cell.LAND)
	var seeds: Array[Vector2i] = [Vector2i(0, 0)]
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 12)

func test_fill_unreachable_with_vertical_wall_and_seeds_on_both_sides() -> void:
	for y in grid.height:
		grid.set_cell(Vector2i(2, y), GridData.Cell.LAND)
	var seeds: Array[Vector2i] = [Vector2i(0, 0), Vector2i(4, 4)]
	var filled := grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_eq(filled, 0)

func test_set_cell_emits_cell_changed() -> void:
	watch_signals(grid)
	grid.set_cell(Vector2i(2, 3), GridData.Cell.LAND)
	assert_signal_emit_count(grid, "cell_changed", 1)
	assert_signal_emitted_with_parameters(grid, "cell_changed", [Vector2i(2, 3)])

func test_set_cell_outside_grid_changes_nothing() -> void:
	watch_signals(grid)
	grid.set_cell(Vector2i(5, 0), GridData.Cell.LAND)
	grid.set_cell(Vector2i(-1, 0), GridData.Cell.LAND)
	assert_signal_not_emitted(grid, "cell_changed")
	assert_eq(grid.get_cell(Vector2i(0, 1)), GridData.Cell.SEA)

func test_fill_unreachable_emits_one_signal_per_changed_cell() -> void:
	for y in grid.height:
		grid.set_cell(Vector2i(2, y), GridData.Cell.LAND)
	watch_signals(grid)
	var seeds: Array[Vector2i] = [Vector2i(0, 0)]
	grid.fill_unreachable(seeds, GridData.Cell.SEA, GridData.Cell.LAND)
	assert_signal_emit_count(grid, "cell_changed", 12)

func _enclose_point(point: Vector2i) -> void:
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx != 0 or dy != 0:
				grid.set_cell(point + Vector2i(dx, dy), GridData.Cell.LAND)
