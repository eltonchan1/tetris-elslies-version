extends Node2D

# to do
# take stuff from https://tetrio.wiki.gg/wiki/BLITZ
# all clear detection
# combo detection
# b2b detection
# art redesign & uis
# vfx
# settings???
# menuing???
# diff gamemodes???
# sound design & music

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
const start_pos := Vector2i(5, 0)
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

# game piece vars - NOW USING ARRAYS FOR 5 NEXT PIECES
var piece_type
var next_pieces : Array = []  # Array of 5 next pieces
var next_pieces_atlas : Array = []  # Array of 5 atlas coords
var rotation_index : int = 0
var active_piece : Array
var last_action_was_rotation : bool = false
var pending_spin_lines : int = 0

# game vars
var score : int
var combo_count : int = 0
var last_clear_had_lines : bool = false
var b2b_count : int = 0
var last_clear_was_difficult : bool = false
const SINGLE : int = 100
const DOUBLE : int = 300
const TRIPLE : int = 500
const QUAD : int = 800
const SPIN_SINGLE: int = 800
const SPIN_DOUBLE: int = 1200
const SPIN_TRIPLE: int = 1600
const SPIN_QUAD: int = 2600
var game_running : bool

# tilemap vars
var tile_id : int = 0
var piece_atlas : Vector2i
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
	combo_count = 0
	last_clear_had_lines = false
	b2b_count = 0
	last_clear_was_difficult = false
	$HUD.get_node("ComboLabel").text = ""
	$HUD.get_node("B2BLabel").text = ""
	
	# Reset the 7-bag randomizer
	shapes = shapes_full.duplicate()
	shapes.shuffle()
	
	print("DEBUG: Hiding GameOverLabel")
	$HUD.get_node("GameOverLabel").hide()
	$HUD.get_node("ScoreLabel").text = "SCORE: 0"
	
	print("DEBUG: About to clear board - board_layer is: ", board_layer)
	if board_layer != null:
		print("DEBUG: Clearing only playfield area (not walls/floor)")
		for i in range(-5, 0):
			for j in range(1, COLS + 1):
				board_layer.erase_cell(Vector2i(j, i))
		for i in range(0, ROWS + 1):
			for j in range(1, COLS + 1):
				board_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: Playfield cleared successfully")
	
	print("DEBUG: About to clear active layer - active_layer is: ", active_layer)
	if active_layer != null:
		print("DEBUG: Clearing active_layer (current piece and previews)")
		for i in range(-5, ROWS + 10):
			for j in range(-5, COLS + 20):
				active_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: active_layer cleared successfully")
	
	print("DEBUG: Picking pieces")
	# Pick current piece
	piece_type = pick_piece()
	print("DEBUG: piece_type = ", piece_type)
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	print("DEBUG: piece_atlas = ", piece_atlas)
	
	# Pick 5 next pieces
	next_pieces.clear()
	next_pieces_atlas.clear()
	for i in range(5):
		var next = pick_piece()
		next_pieces.append(next)
		next_pieces_atlas.append(Vector2i(shapes_full.find(next), 0))
		print("DEBUG: next_pieces[", i, "] = ", next)
	
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
		
	if Input.is_action_just_pressed("restart"):
		new_game()

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
	print("DEBUG: create_piece() START")
	steps = [0, 0, 0]
	cur_pos = start_pos
	
	# O piece spawns one row higher and one column to the right
	if piece_type == o:
		cur_pos = Vector2i(start_pos.x + 1, start_pos.y)
	
	rotation_index = 0
	active_piece = piece_type[rotation_index]
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	
	draw_ghost_piece()
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
	draw_all_next_pieces()
	print("DEBUG: create_piece() COMPLETE")

func draw_all_next_pieces():
	clear_next_panel()
	
	# Draw all 5 next pieces vertically stacked
	const SPACING = 3  # Vertical spacing between pieces
	
	for idx in range(5):
		var base_y = 1 + (idx * SPACING)
		var next_pos = Vector2i(14, base_y)
		var current_piece = next_pieces[idx]
		
		# Adjust position for specific pieces
		if current_piece == o:
			next_pos = Vector2i(14, base_y)
		elif current_piece == i:
			next_pos = Vector2i(14, base_y)
		
		draw_piece(current_piece[0], next_pos, next_pieces_atlas[idx], active_layer)

func clear_piece():
	if active_piece == null or active_piece.is_empty():
		return
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)

func clear_ghost_piece():
	for i in range(ROWS + 10):
		for j in range(COLS + 10):
			var coords = active_layer.get_cell_atlas_coords(Vector2i(j, i))
			if coords == ghost_atlas:
				active_layer.erase_cell(Vector2i(j, i))

func draw_ghost_piece():
	clear_ghost_piece()
	var ghost_pos = get_ghost_position()
	if ghost_pos != cur_pos:
		for i in active_piece:
			active_layer.set_cell(ghost_pos + i, tile_id, ghost_atlas)

func get_ghost_position() -> Vector2i:
	var ghost_pos = cur_pos
	var iterations = 0
	while can_move_to(ghost_pos + Vector2i.DOWN):
		ghost_pos += Vector2i.DOWN
		iterations += 1
		if iterations > 30:
			print("ERROR: Infinite loop in get_ghost_position!")
			break
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
			draw_ghost_piece()
			draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
			reset_lock_delay()
			last_action_was_rotation = true
			print("DEBUG: Rotation successful! Flag set to TRUE")
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
		draw_ghost_piece()
		draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
		
		if dir != Vector2i.DOWN:
			last_action_was_rotation = false
			print("DEBUG: Moved left/right - rotation flag reset to FALSE")
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
		# First hold - take from next pieces queue
		held_piece = piece_type
		held_piece_atlas = piece_atlas
		piece_type = next_pieces[0]
		piece_atlas = next_pieces_atlas[0]
		
		# Shift next pieces queue and add new piece at end
		next_pieces.pop_front()
		next_pieces_atlas.pop_front()
		var new_next = pick_piece()
		next_pieces.append(new_next)
		next_pieces_atlas.append(Vector2i(shapes_full.find(new_next), 0))
	else:
		# Swap current with held piece
		var temp_piece = piece_type
		var temp_atlas = piece_atlas
		piece_type = held_piece
		piece_atlas = held_piece_atlas
		held_piece = temp_piece
		held_piece_atlas = temp_atlas
	
	clear_hold_panel()
	var hold_pos = Vector2i(-3, 1)
	if held_piece == i:
		hold_pos = Vector2i(-4, 1)
	elif held_piece == o:
		hold_pos = Vector2i(-2, 1)
	draw_piece(held_piece[0], hold_pos, held_piece_atlas, active_layer)
	can_hold = false
	create_piece()

func clear_hold_panel():
	for i in range(-5, 2):
		for j in range(-1, 5):
			active_layer.erase_cell(Vector2i(i, j))

func clear_next_panel():
	# Clear larger area for 5 pieces
	for i in range(12, 18):
		for j in range(-2, 18):  # Extended to accommodate 5 pieces
			active_layer.erase_cell(Vector2i(i, j))

func reset_lock_delay():
	if lock_delay_active and move_reset_count < MAX_MOVE_RESETS:
		lock_delay_timer = 0.0
		move_reset_count += 1
		
		if not can_move(Vector2i.DOWN):
			lock_delay_active = true
		else:
			lock_delay_active = false

func check_spin(lines_cleared: int) -> void:
	print("DEBUG: check_spin() called with lines_cleared = ", lines_cleared)
	print("DEBUG: cur_pos = ", cur_pos)
	print("DEBUG: Checking corners around rotation center...")
	
	var corners = [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1),
	]
	
	var blocked_corners = 0
	for corner in corners:
		var check_pos = cur_pos + corner
		var is_blocked = not is_free(check_pos)
		print("DEBUG: Corner ", corner, " (world pos ", check_pos, ") is_blocked = ", is_blocked)
		if is_blocked:
			blocked_corners += 1
	
	print("DEBUG: Total blocked_corners = ", blocked_corners)
	
	if blocked_corners >= 3:
		print("DEBUG: SPIN CONDITION MET! Awarding bonus...")
		award_spin_bonus(lines_cleared)
	else:
		print("DEBUG: Not enough blocked corners for spin (need 3+)")

func award_spin_bonus(lines: int) -> void:
	var bonus = 0
	match lines:
		1: bonus = SPIN_SINGLE
		2: bonus = SPIN_DOUBLE
		3: bonus = SPIN_TRIPLE
		4: bonus = SPIN_QUAD
	
	score += bonus
	print("SPIN DETECTED! +" + str(bonus) + " points")

func get_line_clear_score(lines: int) -> int:
	match lines:
		1: return SINGLE
		2: return DOUBLE
		3: return TRIPLE
		4: return QUAD
		_: return 0

func lock_piece():
	print("DEBUG: lock_piece() called")
	land_piece()
	if last_action_was_rotation:
		check_spin_before_clear()
	check_rows()
	
	# Move to next piece in queue
	piece_type = next_pieces[0]
	piece_atlas = next_pieces_atlas[0]
	
	# Shift queue and add new piece at end
	next_pieces.pop_front()
	next_pieces_atlas.pop_front()
	var new_next = pick_piece()
	next_pieces.append(new_next)
	next_pieces_atlas.append(Vector2i(shapes_full.find(new_next), 0))
	
	clear_ghost_piece()
	can_hold = true
	create_piece()
	check_game_over()

func check_spin_before_clear() -> void :
	print("DEBUG: check_spin_before_clear() - checking corners NOW")
	print("DEBUG: cur_pos = ", cur_pos)
	
	var corners = [
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1),
	]
	
	var blocked_corners = 0
	for corner in corners:
		var check_pos = cur_pos + corner
		var is_blocked = not is_free(check_pos)
		print("DEBUG: Corner ", corner, " (world pos ", check_pos, ") is_blocked = ", is_blocked)
		if is_blocked:
			blocked_corners += 1
		
	print("DEBUG: Total blocked_corners = ", blocked_corners)
	if blocked_corners >= 3:
		print("DEBUG: SPIN DETECTED! Will award bonus after line count")
		pending_spin_lines = -1  # -1 means "yes it's a spin, count lines later"
	else:
		print("DEBUG: Not a spin")
		pending_spin_lines = 0

func is_difficult_clear(lines: int, was_spin: bool) -> bool:
	if was_spin and lines > 0:
		return true
	if lines == 4:
		return true
	return false

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
	var cell_id = board_layer.get_cell_source_id(pos)
	if cell_id != -1:
		return false
	
	if pos.y > ROWS:
		return false
	
	if pos.x < 1 or pos.x > COLS:
		return false
	
	return true

func land_piece():
	print("DEBUG: land_piece() called")
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)
		board_layer.set_cell(cur_pos + i, tile_id, piece_atlas)

func check_rows():
	var lines_cleared = 0
	var row : int = ROWS
	while row > 0:
		var count = 0
		for i in range(COLS):
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		if count == COLS:
			lines_cleared += 1
			shift_rows(row)
			speed += ACCEL
		else:
			row -= 1
	print("DEBUG: check_rows() complete - lines_cleared = ", lines_cleared)
	print("DEBUG: pending_spin_lines = ", pending_spin_lines)
	if lines_cleared > 0:
		var was_spin = (pending_spin_lines == -1)
		var is_difficult = is_difficult_clear(lines_cleared, was_spin)
		if pending_spin_lines == -1:
			print("DEBUG: This was a spin! Awarding bonus for ", lines_cleared, " lines")
			award_spin_bonus(lines_cleared)
		else:
			var line_clear_points = get_line_clear_score(lines_cleared)
			print("DEBUG: Regular line clear - awarding ", line_clear_points, " points for ", lines_cleared, " lines")
			score += line_clear_points
		pending_spin_lines = 0
		if last_clear_had_lines:
			combo_count += 1
			var combo_bonus = combo_count * 50
			print("COMBO x", combo_count, "! +", combo_bonus, " bonus")
			$HUD.get_node("ComboLabel").text = "COMBO: " + str(combo_count)
			score += combo_bonus
		else:
			combo_count = 0
			print("First line clear - no combo yet")
		last_clear_had_lines = true
		
		if is_board_empty():
			var all_clear_bonus = 3500
			score += all_clear_bonus
			print("ALL CLEAR! +", all_clear_bonus, " points")
		
		if is_difficult:
			if last_clear_was_difficult:
				b2b_count += 1
				var b2b_bonus = b2b_count * 100
				score += b2b_bonus
				print("BACK-TO-BACK x", b2b_count, "! +", b2b_bonus, " bonus")
				$HUD.get_node("B2BLabel").text = "B2B: " + str(b2b_count)
			else:
				b2b_count = 0
				print("Back-to-Back started!")
				$HUD.get_node("B2BLabel").text = "B2B: 0"
			last_clear_was_difficult = true
			$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	else:
		if combo_count > 0:
			print("Combo broken!")
		combo_count = 0
		last_clear_had_lines = false
		if b2b_count > 0:
			print("Back-to-Back broken!")
		b2b_count = 0
		$HUD.get_node("B2BLabel").text = ""
		last_clear_was_difficult = false

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

func is_board_empty() -> bool:
	for row in range(1, ROWS + 1):
		for col in range(1, COLS + 1):
			if not is_free(Vector2i(col, row)):
				return false
	return true

func check_game_over():
	print("DEBUG: check_game_over() called")
	for i in active_piece:
		if not is_free(i + cur_pos):
			print("DEBUG: GAME OVER - collision detected")
			$HUD.get_node("GameOverLabel").show()
			game_running = false
			return
