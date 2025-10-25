extends Node2D

# tilemap layer references
@onready var board_layer : TileMapLayer = $board
@onready var active_layer : TileMapLayer = $active

# tetrominoes (using proper SRS coordinates - relative to rotation center)
# I piece
var i_0 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
var i_90 := [Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var i_180 := [Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var i_270 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]
var i := [i_0, i_90, i_180, i_270]

# T piece
var t_0 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)]
var t_90 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0)]
var t_180 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
var t_270 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 0)]
var t := [t_0, t_90, t_180, t_270]

# O piece
var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

# Z piece
var z_0 := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)]
var z_90 := [Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 0), Vector2i(0, 1)]
var z_180 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
var z_270 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1)]
var z := [z_0, z_90, z_180, z_270]

# S piece
var s_0 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1)]
var s_90 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)]
var s_180 := [Vector2i(-1, 1), Vector2i(0, 1), Vector2i(0, 0), Vector2i(1, 0)]
var s_270 := [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1)]
var s := [s_0, s_90, s_180, s_270]

# L piece
var l_0 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1)]
var l_90 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
var l_180 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1)]
var l_270 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, -1)]
var l := [l_0, l_90, l_180, l_270]

# J piece
var j_0 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, -1)]
var j_90 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, -1)]
var j_180 := [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)]
var j_270 := [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 1)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [s, l, o, z, i, j, t]
var shapes_full := shapes.duplicate()

# SRS wall kick data (offset tests for rotation)
# Format: [rotation_from][rotation_to] = [test1, test2, test3, test4, test5]
var srs_offset_jlstz := {
	# Clockwise rotations
	"0->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
	"1->2": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
	"2->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
	"3->0": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
	# Counter-clockwise rotations
	"1->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
	"2->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
	"3->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
	"0->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
	# 180 rotations
	"0->2": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(-1, 0)],
	"2->0": [Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0)],
	"1->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 1)],
	"3->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 2), Vector2i(-1, 1), Vector2i(0, 2), Vector2i(0, 1)]
}

var srs_offset_i := {
	# Clockwise rotations
	"0->1": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
	"1->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
	"2->3": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
	"3->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
	# Counter-clockwise rotations
	"1->0": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
	"2->1": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
	"3->2": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
	"0->3": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
	# 180 rotations
	"0->2": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(-1, 0)],
	"2->0": [Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0)],
	"1->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 1)],
	"3->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 2), Vector2i(-1, 1), Vector2i(0, 2), Vector2i(0, 1)]
}

# grid vars
const COLS : int = 10
const ROWS : int = 20

# movement vars
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(5, 2)
var cur_pos : Vector2i
var speed : float
const ACCEL : float = 0.25

# lock delay vars
var lock_delay_timer : float = 0.0
const LOCK_DELAY_MAX : float = 0.5  # 500ms lock delay
var lock_delay_active : bool = false
var move_reset_count : int = 0
const MAX_MOVE_RESETS : int = 15  # Maximum times you can reset lock delay

# input vars
var das_left : float = 0.0  # Delayed Auto Shift
var das_right : float = 0.0
const DAS_DELAY : float = 0.133  # ~133ms before auto-repeat
const ARR : float = 0.033  # Auto Repeat Rate - ~33ms between moves

# game piece vars
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array

# game vars
var score : int
const REWARD : int = 100
var game_running : bool

# tilemap vars
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i
var ghost_atlas : Vector2i = Vector2i(7, 0)  # Assuming you have a ghost tile at index 7

func _ready():
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)

func new_game():
	# reset vars
	score = 0
	speed = 1.0
	game_running = true
	steps = [0, 0, 0] # left, right, down
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	das_left = 0.0
	das_right = 0.0
	$HUD.get_node("GameOverLabel").hide()
	# clear everything
	clear_piece()
	clear_board()
	clear_panel()
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	create_piece()

func _process(delta):
	if game_running:
		handle_input(delta)
		
		# apply downward movement every frame
		steps[2] += speed
		
		# automatic drop
		if steps[2] > steps_req:
			move_piece(Vector2i.DOWN)
			steps[2] = 0
		
		# handle lock delay
		if lock_delay_active:
			lock_delay_timer += delta
			if lock_delay_timer >= LOCK_DELAY_MAX:
				lock_piece()

func handle_input(delta):
	# Hard drop (space bar or ui_accept)
	if Input.is_action_just_pressed("hard_drop"):
		hard_drop()
		return
	
	# Rotation
	if Input.is_action_just_pressed("cw_rotation"):
		rotate_piece_srs(1)  # Clockwise (CW)
	if Input.is_action_just_pressed("ccw_rotation"):
		rotate_piece_srs(-1)  # Counter-Clockwise (CCW)
	if Input.is_action_just_pressed("180_rotation"):
		rotate_piece_srs(2)  # 180 degree rotation
	
	# Soft drop (hold down)
	if Input.is_action_pressed("soft_drop"):
		steps[2] += 20  # Faster drop
	
	# DAS (Delayed Auto Shift) for left/right
	if Input.is_action_pressed("left_move"):
		das_left += delta
		das_right = 0.0
		if Input.is_action_just_pressed("left_move") or das_left >= DAS_DELAY:
			if das_left >= DAS_DELAY:
				das_left -= ARR
			move_piece(Vector2i.LEFT)
	elif Input.is_action_pressed("right_move"):
		das_right += delta
		das_left = 0.0
		if Input.is_action_just_pressed("right_move") or das_right >= DAS_DELAY:
			if das_right >= DAS_DELAY:
				das_right -= ARR
			move_piece(Vector2i.RIGHT)
	else:
		das_left = 0.0
		das_right = 0.0

func pick_piece():
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	return piece

func create_piece():
	# reset vars
	steps = [0, 0, 0]
	cur_pos = start_pos
	rotation_index = 0
	active_piece = piece_type[rotation_index]
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
	draw_ghost_piece()
	# show next piece
	draw_piece(next_piece_type[0], Vector2i(16, 7), next_piece_atlas, active_layer)

func clear_piece():
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)

func clear_ghost_piece():
	# Clear all ghost pieces (inefficient but simple)
	for i in range(ROWS + 10):
		for j in range(COLS + 10):
			if active_layer.get_cell_atlas_coords(Vector2i(j, i)) == ghost_atlas:
				active_layer.erase_cell(Vector2i(j, i))

func draw_ghost_piece():
	clear_ghost_piece()
	var ghost_pos = get_ghost_position()
	if ghost_pos != cur_pos:  # Only draw if not at same position
		for i in active_piece:
			active_layer.set_cell(ghost_pos + i, tile_id, ghost_atlas)

func get_ghost_position() -> Vector2i:
	var ghost_pos = cur_pos
	while can_move_to(ghost_pos + Vector2i.DOWN):
		ghost_pos += Vector2i.DOWN
	return ghost_pos

func draw_piece(piece, pos, atlas, layer):
	for i in piece:
		layer.set_cell(pos + i, tile_id, atlas)

func rotate_piece_srs(direction: int):
	var old_rotation = rotation_index
	var new_rotation = (rotation_index + direction) % 4
	if new_rotation < 0:
		new_rotation += 4
	
	var new_piece = piece_type[new_rotation]
	
	# O piece doesn't rotate
	if piece_type == o:
		return
	
	# Determine which offset data to use
	var offset_data = srs_offset_jlstz
	if piece_type == i:
		offset_data = srs_offset_i
	
	# Get the offset tests for this rotation
	var key = str(old_rotation) + "->" + str(new_rotation)
	var offsets = offset_data.get(key, [Vector2i.ZERO])
	
	# Try each offset
	for offset in offsets:
		if can_fit(new_piece, cur_pos + offset):
			clear_piece()
			cur_pos += offset
			rotation_index = new_rotation
			active_piece = new_piece
			draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
			draw_ghost_piece()
			reset_lock_delay()
			return

func hard_drop():
	clear_piece()
	cur_pos = get_ghost_position()
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
	lock_piece()  # Immediately lock

func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
		draw_ghost_piece()
		
		# Reset lock delay if moved successfully
		if dir != Vector2i.DOWN:
			reset_lock_delay()
	else:
		if dir == Vector2i.DOWN:
			# Hit the floor, start lock delay
			if not lock_delay_active:
				lock_delay_active = true
				lock_delay_timer = 0.0

func reset_lock_delay():
	if lock_delay_active and move_reset_count < MAX_MOVE_RESETS:
		lock_delay_timer = 0.0
		move_reset_count += 1
		
		# Check if still on ground
		if not can_move(Vector2i.DOWN):
			lock_delay_active = true
		else:
			lock_delay_active = false

func lock_piece():
	land_piece()
	check_rows()
	piece_type = next_piece_type
	piece_atlas = next_piece_atlas
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	clear_panel()
	clear_ghost_piece()
	create_piece()
	check_game_over()

func can_move(dir):
	return can_move_to(cur_pos + dir)

func can_move_to(pos):
	for i in active_piece:
		if not is_free(i + pos):
			return false
	return true

func can_fit(piece, pos):
	for i in piece:
		if not is_free(i + pos):
			return false
	return true

func is_free(pos):
	return board_layer.get_cell_source_id(pos) == -1

func land_piece():
	# remove each segment from the active layer and move to board layer
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)
		board_layer.set_cell(cur_pos + i, tile_id, piece_atlas)

func clear_panel():
	for i in range(14, 19):
		for j in range(5, 9):
			active_layer.erase_cell(Vector2i(i, j))

func check_rows():
	var row : int = ROWS
	while row > 0:
		var count = 0
		for i in range(COLS):
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		# if row is full then erase it
		if count == COLS:
			shift_rows(row)
			score += REWARD
			$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
			speed += ACCEL
		else:
			row -= 1

func shift_rows(row):
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = board_layer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				board_layer.erase_cell(Vector2i(j + 1, i))
			else:
				board_layer.set_cell(Vector2i(j + 1, i), tile_id, atlas)

func clear_board():
	for i in range(ROWS):
		for j in range(COLS):
			board_layer.erase_cell(Vector2i(j + 1, i + 1))

func check_game_over():
	for i in active_piece:
		if not is_free(i + cur_pos):
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false
