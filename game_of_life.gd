extends Node2D

const CELL_SIZE = 10

var grid = []
var generation = 0
var drawing = false

var GRID_WIDTH : int
var GRID_HEIGHT : int

func _ready():
	# Calculate grid dimensions based on viewport size
	var viewport_rect = get_viewport_rect().size
	
	# Calculate grid dimensions
	GRID_WIDTH = floor(viewport_rect.x / CELL_SIZE)
	GRID_HEIGHT = floor(viewport_rect.y / CELL_SIZE)
	
	print("Viewport Size: ", viewport_rect)
	print("Grid Dimensions: ", GRID_WIDTH, " x ", GRID_HEIGHT)
	
	# Initialize grid with calculated dimensions
	setup_grid()
	
	$TileMap.tile_set = preload("res://game_of_life_tileset.tres")
	
	# Connect timer programmatically
	$Timer.timeout.connect(_on_Timer_timeout)
	$Timer.wait_time = 0.1  # Adjust speed as needed
	
	$Play.pressed.connect(play)
	$Pause.pressed.connect(pause)
	$TimeControl.value_changed.connect(time_value_change)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Start/stop drawing on mouse press/release
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
		
		# Toggle cell on click
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			draw_at_mouse_position()
	
	# Draw while mouse is held down
	if event is InputEventMouseMotion and drawing:
		draw_at_mouse_position()

func draw_at_mouse_position():
	# Get global mouse position
	var global_mouse_pos = get_global_mouse_position()
	
	# Calculate grid coordinates, ensuring they're within bounds
	var grid_x = clamp(floor(global_mouse_pos.x / CELL_SIZE), 0, GRID_WIDTH - 1)
	var grid_y = clamp(floor(global_mouse_pos.y / CELL_SIZE), 0, GRID_HEIGHT - 1)
	
	# Ensure we're within grid bounds
	if grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT:
		# Toggle cell state
		grid[grid_y][grid_x] = 1 - grid[grid_y][grid_x]
		
		# Update tilemap
		if grid[grid_y][grid_x] == 1:
			$TileMap.set_cell(0, Vector2i(grid_x, grid_y), 0, Vector2i(0, 0))
		else:
			$TileMap.clear_layer(0)  # Clear the entire layer, then redraw existing cells
			redraw_grid()
			
func redraw_grid():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] == 1:
				$TileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

func setup_grid():
	grid = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(0)  # Start with empty grid
		grid.append(row)

func _on_Timer_timeout():
	next_generation()

func pause():
	$Timer.stop()

func play():
	$Timer.start()
	
func time_value_change(value: float):
	$Timer.wait_time = value

func next_generation():
	var new_grid = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			var neighbors = count_neighbors(x, y)
			if grid[y][x] == 1:
				# Survival rules
				row.append(1 if neighbors == 2 or neighbors == 3 else 0)
			else:
				# Reproduction
				row.append(1 if neighbors == 3 else 0)
		new_grid.append(row)
	
	grid = new_grid
	update_tilemap()
	generation += 1
	$GenerationLabel.text = "Generation: %d" % generation

func count_neighbors(x: int, y: int) -> int:
	var neighbors = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = (x + dx + GRID_WIDTH) % GRID_WIDTH
			var ny = (y + dy + GRID_HEIGHT) % GRID_HEIGHT
			
			neighbors += grid[ny][nx]
	
	return neighbors

func update_tilemap():
	$TileMap.clear_layer(0)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] == 1:
				$TileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

# Optional: Handle window resizing
func _on_resized():
	# Recalculate grid if window is resized
	var viewport_rect = get_viewport_rect().size
	
	GRID_WIDTH = floor(viewport_rect.x / CELL_SIZE)
	GRID_HEIGHT = floor(viewport_rect.y / CELL_SIZE)
	
	setup_grid()
	update_tilemap()
