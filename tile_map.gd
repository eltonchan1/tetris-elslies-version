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
var o_0 := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]
var o_90 := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]
var o_180 := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]
var o_270 := [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]
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
var srs_offset_jlstz := {
	"0->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
	"1->2": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
	"2->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
	"3->0": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
	"1->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
	"2->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
	"3->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
	"0->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
	"0->2": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(-1, 0)],
	"2->0": [Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0)],
	"1->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 2), Vector2i(0, 1)],
	"3->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 2), Vector2i(-1, 1), Vector2i(0, 2), Vector2i(0, 1)]
}

var srs_offset_i := {
	"0->1": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
	"1->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
	"2->3": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
	"3->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
	"1->0": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
	"2->1": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
	"3->2": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
	"0->3": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)],
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
const start_pos := Vector2i(5, 0)  # Changed from (5, 1) to (5, 2)
var cur_pos : Vector2i
var speed : float
const ACCEL : float = 0.1

# lock delay vars
var lock_delay_timer : float = 0.0
const LOCK_DELAY_MAX : float = 0.5
var lock_delay_active : bool = false
var move_reset_count : int = 0
const MAX_MOVE_RESETS : int = 15

# input vars
var das_left : float = 0.0
var das_right : float = 0.0
const DAS_DELAY : float = 0.133
const ARR : float = 0.033

# hold
var held_piece = null
var held_piece_atlas : Vector2i
var can_hold : bool = true

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
var ghost_atlas : Vector2i = Vector2i(7, 0)

func _ready():
	print("DEBUG: _ready() called")
	new_game()
	print("DEBUG: Connecting StartButton")
	$HUD.get_node("StartButton").pressed.connect(new_game)
	print("DEBUG: _ready() completed")

func new_game():
	print("DEBUG: new_game() START")
	game_running = false
	active_piece = []
	
	print("DEBUG: Resetting variables")
	score = 0
	speed = 1.0
	steps = [0, 0, 0]
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	das_left = 0.0
	das_right = 0.0
	held_piece = null
	can_hold = true
	
	# Reset the 7-bag randomizer
	shapes = shapes_full.duplicate()
	shapes.shuffle()
	
	print("DEBUG: Hiding GameOverLabel")
	$HUD.get_node("GameOverLabel").hide()
	$HUD.get_node("ScoreLabel").text = "SCORE: 0"
	
	print("DEBUG: About to clear board - board_layer is: ", board_layer)
	# Clear the playfield area based on your board coordinates (0,0) to (12,22)
	# Playfield is columns 1-10, rows 1-20 (with walls at 0, 11 and floor at 21)
	if board_layer != null:
		print("DEBUG: Clearing only playfield area (not walls/floor)")
		# Clear above the board (negative rows) to catch stuck pieces
		for i in range(-5, 0):
			for j in range(1, COLS + 1):
				board_layer.erase_cell(Vector2i(j, i))
		# Clear the main playfield
		for i in range(0, ROWS + 1):  # Clear rows 0-20 (not row 21 which is the floor)
			for j in range(1, COLS + 1):  # Clear columns 1-10 (inside walls)
				board_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: Playfield cleared successfully")
	
	print("DEBUG: About to clear active layer - active_layer is: ", active_layer)
	if active_layer != null:
		print("DEBUG: Clearing active_layer (current piece and previews)")
		# Clear a large area for current piece, ghost, and next piece preview
		for i in range(-5, ROWS + 10):
			for j in range(-5, COLS + 20):
				active_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: active_layer cleared successfully")
	
	print("DEBUG: Picking pieces")
	piece_type = pick_piece()
	print("DEBUG: piece_type = ", piece_type)
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	print("DEBUG: piece_atlas = ", piece_atlas)
	
	next_piece_type = pick_piece()
	print("DEBUG: next_piece_type = ", next_piece_type)
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	print("DEBUG: next_piece_atlas = ", next_piece_atlas)
	
	game_running = true
	print("DEBUG: About to create_piece()")
	create_piece()
	print("DEBUG: new_game() COMPLETE")

func _process(delta):
	if game_running:
		handle_input(delta)
		steps[2] += speed
		
		if steps[2] > steps_req:
			move_piece(Vector2i.DOWN)
			steps[2] = 0
		
		if lock_delay_active:
			lock_delay_timer += delta
			if lock_delay_timer >= LOCK_DELAY_MAX:
				lock_piece()

func handle_input(delta):
	if Input.is_action_just_pressed("hard_drop"):
		hard_drop()
		return
	
	# Hold piece
	if Input.is_action_just_pressed("hold"):
		hold_piece()
		return
	
	if Input.is_action_just_pressed("cw_rotation"):
		rotate_piece_srs(1)
	if Input.is_action_just_pressed("ccw_rotation"):
		rotate_piece_srs(-1)
	if Input.is_action_just_pressed("180_rotation"):
		rotate_piece_srs(2)
	
	if Input.is_action_pressed("soft_drop"):
		steps[2] += 20
	
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
	print("DEBUG: pick_piece() called")
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	print("DEBUG: pick_piece() returning piece")
	return piece

func create_piece():
	print("DEBUG: create_piece() START")
	steps = [0, 0, 0]
	cur_pos = start_pos
	
	# O piece spawns one row higher
	if piece_type == o:
		cur_pos = Vector2i(start_pos.x, start_pos.y - 1)
	
	rotation_index = 0
	active_piece = piece_type[rotation_index]
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	
	print("DEBUG: Drawing piece at ", cur_pos)
	print("DEBUG: Drawing ghost")
	draw_ghost_piece()  # Draw ghost FIRST
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)  # Draw active piece SECOND
	print("DEBUG: Drawing next piece")
	clear_next_panel()
	# O piece in next panel needs to be shifted right by 1
	var next_pos = Vector2i(14, 1)
	if next_piece_type == o:
		next_pos = Vector2i(15, 1)
	draw_piece(next_piece_type[0], next_pos, next_piece_atlas, active_layer)
	print("DEBUG: create_piece() COMPLETE")

func clear_piece():
	if active_piece == null or active_piece.is_empty():
		return
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)

func clear_ghost_piece():
	print("DEBUG: clear_ghost_piece() START")
	for i in range(ROWS + 10):
		for j in range(COLS + 10):
			var coords = active_layer.get_cell_atlas_coords(Vector2i(j, i))
			if coords == ghost_atlas:
				active_layer.erase_cell(Vector2i(j, i))
	print("DEBUG: clear_ghost_piece() COMPLETE")

func draw_ghost_piece():
	print("DEBUG: draw_ghost_piece() START")
	clear_ghost_piece()
	print("DEBUG: Getting ghost position")
	var ghost_pos = get_ghost_position()
	print("DEBUG: Ghost position is: ", ghost_pos)
	if ghost_pos != cur_pos:
		print("DEBUG: Drawing ghost at ", ghost_pos)
		for i in active_piece:
			active_layer.set_cell(ghost_pos + i, tile_id, ghost_atlas)
	print("DEBUG: draw_ghost_piece() COMPLETE")

func get_ghost_position() -> Vector2i:
	print("DEBUG: get_ghost_position() START - cur_pos = ", cur_pos)
	var ghost_pos = cur_pos
	var iterations = 0
	while can_move_to(ghost_pos + Vector2i.DOWN):
		ghost_pos += Vector2i.DOWN
		iterations += 1
		if iterations > 30:
			print("ERROR: Infinite loop in get_ghost_position!")
			break
	print("DEBUG: get_ghost_position() COMPLETE - ghost_pos = ", ghost_pos)
	return ghost_pos

func draw_piece(piece, pos, atlas, layer):
	print("DEBUG: draw_piece() - drawing at pos ", pos, " with atlas ", atlas)
	for i in piece:
		layer.set_cell(pos + i, tile_id, atlas)

func rotate_piece_srs(direction: int):
	var old_rotation = rotation_index
	var new_rotation = (rotation_index + direction) % 4
	if new_rotation < 0:
		new_rotation += 4
	
	var new_piece = piece_type[new_rotation]
	
	if piece_type == o:
		return
	
	var offset_data = srs_offset_jlstz
	if piece_type == i:
		offset_data = srs_offset_i
	
	var key = str(old_rotation) + "->" + str(new_rotation)
	var offsets = offset_data.get(key, [Vector2i.ZERO])
	
	for offset in offsets:
		if can_fit(new_piece, cur_pos + offset):
			clear_piece()
			cur_pos += offset
			rotation_index = new_rotation
			active_piece = new_piece
			draw_ghost_piece()  # Draw ghost FIRST
			draw_piece(active_piece, cur_pos, piece_atlas, active_layer)  # Draw active piece SECOND
			reset_lock_delay()
			return

func hard_drop():
	clear_piece()
	cur_pos = get_ghost_position()
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
	lock_piece()

func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_ghost_piece()  # Draw ghost FIRST
		draw_piece(active_piece, cur_pos, piece_atlas, active_layer)  # Draw active piece SECOND
		
		if dir != Vector2i.DOWN:
			reset_lock_delay()
	else:
		if dir == Vector2i.DOWN:
			if not lock_delay_active:
				lock_delay_active = true
				lock_delay_timer = 0.0

func hold_piece():
	if not can_hold:
		return
	
	print("DEBUG: hold_piece() called")
	clear_piece()
	clear_ghost_piece()
	
	if held_piece == null:
		# First hold
		held_piece = piece_type
		held_piece_atlas = piece_atlas
		piece_type = next_piece_type
		piece_atlas = next_piece_atlas
		next_piece_type = pick_piece()
		next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	else:
		# Swap current with held piece
		var temp_piece = piece_type
		var temp_atlas = piece_atlas
		piece_type = held_piece
		piece_atlas = held_piece_atlas
		held_piece = temp_piece
		held_piece_atlas = temp_atlas
	
	clear_hold_panel()
	# I piece needs to be shifted left by 1, O piece needs to be shifted right by 1
	var hold_pos = Vector2i(-3, 1)  # Moved up from 2 to 1
	if held_piece == i:
		hold_pos = Vector2i(-4, 1)
	elif held_piece == o:
		hold_pos = Vector2i(-2, 1)
	draw_piece(held_piece[0], hold_pos, held_piece_atlas, active_layer)
	can_hold = false
	clear_next_panel()
	create_piece()

func clear_hold_panel():
	for i in range(-5, 2):
		for j in range(-1, 5):
			active_layer.erase_cell(Vector2i(i, j))

func clear_next_panel():
	# Clear the next piece preview area
	for i in range(12, 18):
		for j in range(-2, 6):
			active_layer.erase_cell(Vector2i(i, j))

func reset_lock_delay():
	if lock_delay_active and move_reset_count < MAX_MOVE_RESETS:
		lock_delay_timer = 0.0
		move_reset_count += 1
		
		if not can_move(Vector2i.DOWN):
			lock_delay_active = true
		else:
			lock_delay_active = false

func lock_piece():
	print("DEBUG: lock_piece() called")
	land_piece()
	check_rows()
	piece_type = next_piece_type
	piece_atlas = next_piece_atlas
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	clear_ghost_piece()
	can_hold = true  # Reset hold when piece locks
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
	# First check if there's a tile on board_layer (walls, floor, or locked pieces)
	var cell_id = board_layer.get_cell_source_id(pos)
	if cell_id != -1:
		print("DEBUG: is_free(", pos, ") = false (occupied by tile)")
		return false
	
	# If we're checking below the playfield, treat as occupied (floor)
	if pos.y > ROWS:
		print("DEBUG: is_free(", pos, ") = false (below playfield)")
		return false
	
	# If we're checking outside horizontal bounds, treat as occupied (walls)
	if pos.x < 1 or pos.x > COLS:
		print("DEBUG: is_free(", pos, ") = false (outside walls)")
		return false
	
	print("DEBUG: is_free(", pos, ") = true")
	return true

func land_piece():
	print("DEBUG: land_piece() called")
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)
		board_layer.set_cell(cur_pos + i, tile_id, piece_atlas)

func check_rows():
	print("DEBUG: check_rows() START")
	var row : int = ROWS
	while row > 0:
		var count = 0
		for i in range(COLS):
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		if count == COLS:
			print("DEBUG: Row ", row, " is full - clearing")
			shift_rows(row)
			score += REWARD
			$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
			speed += ACCEL
		else:
			row -= 1
	print("DEBUG: check_rows() COMPLETE")

func shift_rows(row):
	print("DEBUG: shift_rows() for row ", row)
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = board_layer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				board_layer.erase_cell(Vector2i(j + 1, i))
			else:
				board_layer.set_cell(Vector2i(j + 1, i), tile_id, atlas)

func check_game_over():
	print("DEBUG: check_game_over() called")
	for i in active_piece:
		if not is_free(i + cur_pos):
			print("DEBUG: GAME OVER - collision detected")
			$HUD.get_node("GameOverLabel").show()
			game_running = false
			return
