extends Node2D

# to do
	# add like more satisfying scoring n stuff (numbers)
	# art redesign & uis
		# ultrakill style
	# main menu
		# fancy it up, make it look good
	# diff gamemodes???
		# 40l, blitz, etc
	# sound design & music
		# satisfying


# NODE REFERENCES
@onready var board_layer : TileMapLayer = $Game/board
@onready var active_layer : TileMapLayer = $Game/active
@onready var wave_material : ShaderMaterial = $"Game/Particles/CanvasLayer/ColorRect".material
@onready var hold_layer : TileMapLayer = $Game/hold

# CONSTANTS
const COLS : int = 10
const ROWS : int = 19
const GRAVITY_INCREASE : float = 0.001
const MAX_GRAVITY : float = 20.0
const LOCK_DELAY_MAX : float = 0.5
const MAX_MOVE_RESETS : int = 15
const BASE_SOFT_DROP : float = 0.01667
const CAMERA_NUDGE_AMOUNT : float = 8.0
const CAMERA_RETURN_SPEED : float = 15.0
const TRAUMA_DECAY : float = 1.5
const MAX_SHAKE_OFFSET : float = 30.0
const WAVE_DECAY : float = 2.0

# Scoring constants
const SINGLE : int = 100
const DOUBLE : int = 300
const TRIPLE : int = 500
const QUAD : int = 800
const SPIN_SINGLE: int = 800
const SPIN_DOUBLE: int = 1200
const SPIN_TRIPLE: int = 1600

const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
const start_pos := Vector2i(5, -1)
const steps_req : int = 50

# TETROMINO DEFINITIONS (SRS coordinates)
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

var shapes := [z, l, o, s, i, j, t]
var shapes_full := shapes.duplicate()

# SRS WALL KICK DATA
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

# GAME STATE VARIABLES
var steps : Array
var cur_pos : Vector2i
var gravity : float = 0.02
var gravity_counter : float = 0.0 
var game_running : bool
var game_time : float = 0.0
var timer_running : bool = false

# Lock delay
var lock_delay_timer : float = 0.0
var lock_delay_active : bool = false
var move_reset_count : int = 0

# Input handling
var remappable_actions : Array = [
	["left_move", "LeftContainer/LButton"],
	["right_move", "RightContainer/RButton"],
	["soft_drop", "SDContainer/SDButton"],
	["hard_drop", "HDContainer/HDButton"],
	["ccw_rotation", "CCWContainer/CCWButton"],
	["cw_rotation", "CWContainer/CWButton"],
	["180_rotation", "180Container/180Button"],
	["hold", "HoldContainer/HoldButton"],
	["pause_exit", "PauseExitContainer/PauseExitButton"],
]
var awaiting_remap_action : String = ""
var remap_buttons : Dictionary = {}
var das_left : float = 0.0
var das_right : float = 0.0
var das_delay_sec : float = 10.0 / 60.0
var arr_sec : float = 2.0 / 60.0
var dcd_sec : float = 1.0 / 60.0
var left_release_timer : float = 0.0
var right_release_timer : float = 0.0
var sdf : float = 6.0
var soft_dropping : bool = false

# Hold system
var held_piece = null
var held_piece_atlas : Vector2i
var can_hold : bool = true

# Active piece
var piece_type
var next_pieces : Array = []
var next_pieces_atlas : Array = []
var rotation_index : int = 0
var active_piece : Array
var last_action_was_rotation : bool = false
var pending_spin_type : int = 0

# Scoring
var score : int
var combo_count : int = 0
var b2b_active : bool = false
var soft_drop_cells : int = 0
var hard_drop_cells : int = 0
var last_clear_had_lines : bool = false
var b2b_count : int = 0
var last_clear_was_difficult : bool = false
var level : int = 1
var lines_cleared_total : int = 0
var lines_for_next_level : int = 3

# Tilemap
var tile_id : int = 1
var piece_atlas : Vector2i
var ghost_atlas : Vector2i = Vector2i(7, 0)

# Camera & effects
var camera_offset : Vector2 = Vector2.ZERO
var trauma : float = 0.0
var wave_intensity : float = 0.0

# INITIALIZATION
func _ready():
	print("DEBUG: _ready() called")
	main_menu(true)
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/ARRContainer/ARRSlider.value = 5.0 - (arr_sec * 60.0)
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DASContainer/DASSlider.value = 20.0 - (das_delay_sec * 60.0) + 1.0
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DCDContainer/DCDSlider.value = 20.0 - (dcd_sec * 60.0)
	if sdf >= 9999:
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SDFSlider.value = 41
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SettingsValue.text = "∞"
	else:
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SDFSlider.value = sdf
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SettingsValue.text = str(int(sdf)) + "X"
	var keybinds_base = $MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer
	for entry in remappable_actions:
		var action = entry[0]
		var btn_name = entry[1]
		var btn = keybinds_base.get_node(btn_name)
		remap_buttons[action] = btn
		btn.pressed.connect(_on_remap_button_pressed.bind(action))
	load_keybinds()
	refresh_remap_buttons()
	print("DEBUG: _ready() complete")

func get_remap_button(action: String) -> Button:
	return remap_buttons.get(action, null)

# MENU FUNCTIONS
func main_menu(on: bool):
	if on == true:
		$Game.visible = false
		$MainMenu.visible = true
		$MainMenu/PopUp/About.visible = false
		$MainMenu/PopUp/Settings.visible = false
		$MainMenu/PopUp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Game/Particles/CanvasLayer/ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		game_running = false
	if on == false:
		$Game.visible = true
		$MainMenu.visible = false

func _on_play_button_pressed() -> void:
	main_menu(false)
	new_game()

func _on_start_button_pressed() -> void:
	new_game()

func _on_main_menu_button_pressed() -> void:
	main_menu(true)

func _on_about_button_pressed() -> void:
	$MainMenu/PopUp/About.visible = true
	$MainMenu/PopUp/About.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_settings_button_pressed() -> void:
	$MainMenu/PopUp/Settings.visible = true
	$MainMenu/PopUp/Settings.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()

func _on_about_exit_button_pressed() -> void:
	$MainMenu/PopUp/About.visible = false
	$MainMenu/PopUp/About.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_settings_exit_button_pressed() -> void:
	$MainMenu/PopUp/Settings.visible = false
	$MainMenu/PopUp/Settings.mouse_filter = Control.MOUSE_FILTER_IGNORE

# GAME LOOP
func new_game():
	print("DEBUG: new_game() START")
	game_running = false
	active_piece = []
	
	# Reset game state
	print("DEBUG: Resetting variables")
	score = 0
	gravity = 0.01667
	gravity_counter = 0.0
	lock_delay_timer = 0.0
	lock_delay_active = false
	move_reset_count = 0
	das_left = 0.0
	das_right = 0.0
	left_release_timer = 0.0
	right_release_timer = 0.0
	held_piece = null
	can_hold = true
	hold_layer.modulate = Color(1, 1, 1, 1.0)
	clear_hold_panel()
	combo_count = 0
	last_clear_had_lines = false
	b2b_count = 0
	last_clear_was_difficult = false
	game_time = 0.0
	level = 1
	lines_cleared_total = 0
	lines_for_next_level = 3
	timer_running = false
	
	# Reset UI labels
	$Game/HUD.get_node("ComboLabel").text = ""
	$Game/HUD.get_node("B2BLabel").text = ""
	$Game/HUD.get_node("AllClearLabel").text = ""
	$Game/HUD.get_node("TimerLabel").text = "TIME: 0:00.000"
	$Game/HUD.get_node("GameOverLabel").hide()
	$Game/HUD.get_node("ScoreLabel").text = "SCORE: 0"
	$Game/HUD.get_node("LevelLabel").text = "LEVEL: " + str(level)
	
	# Reset bag randomizer
	shapes = shapes_full.duplicate()
	shapes.shuffle()
	
	# Clear playfield
	print("DEBUG: About to clear board - board_layer is: ", board_layer)
	if board_layer != null:
		print("DEBUG: Clearing only playfield area (not walls/floor)")
		for i in range(-5, 20):
			for j in range(1, 11):
				board_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: Playfield cleared successfully")
	
	# Clear active layer
	print("DEBUG: About to clear active layer - active_layer is: ", active_layer)
	if active_layer != null:
		print("DEBUG: Clearing active_layer (current piece and previews)")
		for i in range(-5, ROWS + 10):
			for j in range(-5, COLS + 20):
				active_layer.erase_cell(Vector2i(j, i))
		print("DEBUG: active_layer cleared successfully")
	
	# Initialize pieces
	print("DEBUG: Picking pieces")
	piece_type = pick_piece()
	print("DEBUG: piece_type = ", piece_type)
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	print("DEBUG: piece_atlas = ", piece_atlas)
	next_pieces.clear()
	next_pieces_atlas.clear()
	for i in range(5):
		var next = pick_piece()
		next_pieces.append(next)
		next_pieces_atlas.append(Vector2i(shapes_full.find(next), 0))
		print("DEBUG: next_pieces[", i, "] = ", next)
	
	# Reset camera & effects
	camera_offset = Vector2.ZERO
	trauma = 0.0
	$Game/Camera2D.offset = Vector2.ZERO
	
	game_running = true
	timer_running = true
	print("DEBUG: About to create_piece()")
	create_piece()
	print("DEBUG: new_game() COMPLETE")

func _process(delta):
	if game_running:
		handle_input(delta)
		update_camera(delta)
		if timer_running:
			game_time += delta
			update_timer_display()
		# Gravity processing
		while gravity_counter >= 1.0:
			if can_move(Vector2i.DOWN):
				move_piece(Vector2i.DOWN)
				if soft_dropping:
					score += 1
					$Game/HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
				gravity_counter -= 1.0
			else:
				gravity_counter = 0.0
				if not lock_delay_active:
					lock_delay_active = true
					lock_delay_timer = 0.0
				break
		# Lock delay processing
		if lock_delay_active:
			lock_delay_timer += delta
			if lock_delay_timer >= LOCK_DELAY_MAX:
				lock_piece()
		wave_material.set_shader_parameter(
			"zoom",
			0.002 + trauma * 0.01
			)
		
		wave_material.set_shader_parameter(
			"offset",
			Vector2(
			randf_range(-0.001, 0.001),
			randf_range(-0.001, 0.001)
			) * trauma
		)


func update_timer_display():
	var minutes = int(game_time / 60)
	var seconds = int(game_time) % 60
	var milliseconds = int((game_time - int(game_time)) * 1000)
	var time_string = "%d:%02d.%03d" % [minutes, seconds, milliseconds]
	$Game/HUD.get_node("TimerLabel").text = time_string

# INPUT HANDLING
func handle_input(delta):
	left_release_timer = max(0, left_release_timer - delta)
	right_release_timer = max(0, right_release_timer - delta)
	
	# Priority actions
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
	if Input.is_action_just_pressed("left_move"):
		right_release_timer = 0.0
		das_right = 0.0
	if Input.is_action_just_pressed("right_move"):
		left_release_timer = 0.0
		das_left = 0.0
	# Soft drop
	if Input.is_action_pressed("soft_drop"):
		soft_dropping = true
		if sdf >= 9999:
			while can_move(Vector2i.DOWN):
				move_piece(Vector2i.DOWN)
				score += 1
				$Game/HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
			gravity_counter = 0.0
		else:
			var old_counter = gravity_counter
			gravity_counter += (2.5 * BASE_SOFT_DROP * sdf * delta * 60.0)
			var cells_this_frame = int(gravity_counter) - int(old_counter)
			if cells_this_frame > 0 and can_move(Vector2i.DOWN):
				score += cells_this_frame
	else:
		soft_dropping = false
		gravity_counter += gravity * delta * 60.0
	# Left movement with DAS/ARR
	if Input.is_action_pressed("left_move") and not Input.is_action_pressed("right_move"):
		if right_release_timer <= 0:
			das_left += delta
			das_right = 0.0
			if Input.is_action_just_pressed("left_move") or das_left >= das_delay_sec:
				if das_left >= das_delay_sec:
					das_left -= arr_sec
				move_piece(Vector2i.LEFT)
	elif Input.is_action_pressed("right_move") and not Input.is_action_pressed("left_move"):
		if left_release_timer <= 0:
			das_right += delta
			das_left = 0.0
			if Input.is_action_just_pressed("right_move") or das_right >= das_delay_sec:
				if das_right >= das_delay_sec:
					das_right -= arr_sec
				move_piece(Vector2i.RIGHT)
	# Both held simultaneously - move in the most recently pressed direction
	elif Input.is_action_pressed("left_move") and Input.is_action_pressed("right_move"):
		if Input.is_action_just_pressed("right_move"):
			move_piece(Vector2i.RIGHT)
		elif Input.is_action_just_pressed("left_move"):
			move_piece(Vector2i.LEFT)
	else:
		if das_left >= das_delay_sec:
			right_release_timer = dcd_sec
		if das_right >= das_delay_sec:
			left_release_timer = dcd_sec
		das_left = 0.0
		das_right = 0.0
	
	# Restart
	if Input.is_action_just_pressed("restart"):
		new_game()

func refresh_remap_buttons():
	for action in remap_buttons:
		var btn = remap_buttons[action]
		btn.text = get_key_name_for_action(action)

func get_key_name_for_action(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return "UNBOUND"

func _on_remap_button_pressed(action: String):
	awaiting_remap_action = action
	remap_buttons[action].text = "Press a key..."

func _input(event):
	if awaiting_remap_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			awaiting_remap_action = ""
			refresh_remap_buttons()
			get_viewport().set_input_as_handled()
			return
		InputMap.action_erase_events(awaiting_remap_action)
		InputMap.action_add_event(awaiting_remap_action, event)
		save_keybinds()
		awaiting_remap_action = ""
		refresh_remap_buttons()
		get_viewport().set_input_as_handled()

func save_keybinds():
	var config = ConfigFile.new()
	for action in remap_buttons:
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				config.set_value("keybinds", action, event.physical_keycode)
	config.save("user://keybinds.cfg")

func load_keybinds():
	var config = ConfigFile.new()
	if config.load("user://keybinds.cfg") != OK:
		return
	for action in remap_buttons:
		if config.has_section_key("keybinds", action):
			var keycode = config.get_value("keybinds", action)
			var event = InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)

# PIECE MANAGEMENT
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
	gravity_counter = 0.0
	cur_pos = start_pos
	
	# O piece spawns one cell to the right
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

# DRAWING FUNCTIONS
func draw_all_next_pieces():
	clear_next_panel()
	const SPACING = 3
	
	for idx in range(5):
		var base_y = 1 + (idx * SPACING)
		var next_pos = Vector2i(14, base_y)
		var current_piece = next_pieces[idx]
		
		# Adjust positioning for O and I pieces
		if current_piece == o:
			next_pos = Vector2i(14, base_y)
		elif current_piece == i:
			next_pos = Vector2i(14, base_y)
		
		draw_piece(current_piece[0], next_pos, next_pieces_atlas[idx], active_layer)

func draw_piece(piece, pos, atlas, layer):
	for i in piece:
		layer.set_cell(pos + i, tile_id, atlas)

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

func clear_next_panel():
	for i in range(12, 18):
		for j in range(-2, 18):
			active_layer.erase_cell(Vector2i(i, j))

func clear_hold_panel():
	for i in range(-5, 2):
		for j in range(-1, 5):
			hold_layer.erase_cell(Vector2i(i, j))

# PIECE MOVEMENT & ROTATION
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
		# Collision detected - nudge camera
		if dir == Vector2i.LEFT:
			nudge_camera(Vector2.RIGHT)
		elif dir == Vector2i.RIGHT:
			nudge_camera(Vector2.LEFT)
		elif dir == Vector2i.DOWN:
			if not lock_delay_active:
				lock_delay_active = true
				lock_delay_timer = 0.0

func rotate_piece_srs(direction: int):
	var old_rotation = rotation_index
	var new_rotation = (rotation_index + direction) % 4
	if new_rotation < 0:
		new_rotation += 4
	
	var new_piece = piece_type[new_rotation]
	
	# O piece doesn't rotate
	if piece_type == o:
		return
	
	# Select wall kick data
	var offset_data = srs_offset_jlstz
	if piece_type == i:
		offset_data = srs_offset_i
	
	# Try each wall kick offset
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
	var ghost_pos = get_ghost_position()
	hard_drop_cells = ghost_pos.y - cur_pos.y  # cells dropped
	cur_pos = ghost_pos
	draw_piece(active_piece, cur_pos, piece_atlas, active_layer)
	score += hard_drop_cells * 2
	spawn_hard_drop_particles()
	lock_piece()

func hold_piece():
	if not can_hold:
		return
	
	print("DEBUG: hold_piece() called")
	clear_piece()
	clear_ghost_piece()
	
	if held_piece == null:
		# First hold - take from next queue
		held_piece = piece_type
		held_piece_atlas = piece_atlas
		piece_type = next_pieces[0]
		piece_atlas = next_pieces_atlas[0]
		
		next_pieces.pop_front()
		next_pieces_atlas.pop_front()
		var new_next = pick_piece()
		next_pieces.append(new_next)
		next_pieces_atlas.append(Vector2i(shapes_full.find(new_next), 0))
	else:
		# Swap with held piece
		var temp_piece = piece_type
		var temp_atlas = piece_atlas
		piece_type = held_piece
		piece_atlas = held_piece_atlas
		held_piece = temp_piece
		held_piece_atlas = temp_atlas
	
	# Draw held piece
	clear_hold_panel()
	var hold_pos = Vector2i(-3, 1)
	if held_piece == i:
		hold_pos = Vector2i(-4, 1)
	elif held_piece == o:
		hold_pos = Vector2i(-2, 1)
	draw_piece(held_piece[0], hold_pos, held_piece_atlas, hold_layer)
	can_hold = false
	hold_layer.modulate = Color(0.4, 0.4, 0.4, 1.0)
	create_piece()

func reset_lock_delay():
	if lock_delay_active and move_reset_count < MAX_MOVE_RESETS:
		lock_delay_timer = 0.0
		move_reset_count += 1
		
		if not can_move(Vector2i.DOWN):
			lock_delay_active = true
		else:
			lock_delay_active = false

# SCORING & SPIN DETECTION
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
	
	print("SPIN DETECTED! +" + str(bonus) + " points")

func get_line_clear_score(lines: int) -> int:
	match lines:
		1: return SINGLE
		2: return DOUBLE
		3: return TRIPLE
		4: return QUAD
		_: return 0

# VISUAL EFFECTS
func spawn_hard_drop_particles():
	var particle_template = $Game/Particles/HardDropContact
	var particle_bg_template = $Game/Particles/HardDropBG
	
	# Get the piece color from its atlas coordinates
	var piece_color = get_piece_color(piece_atlas)
	
	for block_offset in active_piece:
		var block_grid_pos = cur_pos + block_offset
		var below_pos = block_grid_pos + Vector2i(0, 1)
		var has_contact = not is_free(below_pos)
		
		if has_contact:
			var block_world_pos = board_layer.map_to_local(block_grid_pos)
			block_world_pos.y += 16
			
			# Spawn contact particles
			var new_particles = particle_template.duplicate()
			$Game/Particles.add_child(new_particles)
			new_particles.position = block_world_pos
			new_particles.color = piece_color  # Set color
			new_particles.one_shot = true
			new_particles.emitting = true
			new_particles.finished.connect(new_particles.queue_free)
			
			# Spawn background particles
			var new_bg_particles = particle_bg_template.duplicate()
			$Game/Particles.add_child(new_bg_particles)
			new_bg_particles.position = block_world_pos + Vector2(0, -304)
			new_bg_particles.color = piece_color  # Set color
			new_bg_particles.one_shot = true
			new_bg_particles.emitting = true
			new_bg_particles.finished.connect(new_bg_particles.queue_free)

func get_piece_color(atlas_coords: Vector2i) -> Color:
	match atlas_coords.x:
		0: return Color(1, 0, 0, 0.5)
		1: return Color(1, 0.5, 0, 0.5)
		2: return Color(1, 1, 0, 0.5)
		3: return Color(0, 1, 0, 0.5)
		4: return Color(0, 1, 1, 0.5)
		5: return Color(0, 0, 1, 0.5)
		6: return Color(0.5, 0, 1, 0.5)
		_: return Color(1, 1, 1, 0.5)

# COLLISION DETECTION
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

# PIECE LOCKING & LINE CLEARING
func lock_piece():
	print("DEBUG: lock_piece() called")
	nudge_camera(Vector2.UP)
	land_piece()
	pending_spin_type = get_spin_type()
	check_rows()
	# Get next piece
	piece_type = next_pieces[0]
	piece_atlas = next_pieces_atlas[0]
	next_pieces.pop_front()
	next_pieces_atlas.pop_front()
	var new_next = pick_piece()
	next_pieces.append(new_next)
	next_pieces_atlas.append(Vector2i(shapes_full.find(new_next), 0))
	clear_ghost_piece()
	can_hold = true
	hold_layer.modulate = Color(1, 1, 1, 1.0)
	create_piece()
	check_game_over()

func land_piece():
	print("DEBUG: land_piece() called")
	for i in active_piece:
		active_layer.erase_cell(cur_pos + i)
		board_layer.set_cell(cur_pos + i, tile_id, piece_atlas)

# 0 no spin, 1 mini spin, 2 full spin
func get_spin_type() -> int:
	if not last_action_was_rotation:
		return 0
	if piece_type == o:
		return 0
	
	var corners = [Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(1,1)]
	var blocked = 0
	for c in corners:
		if not is_free(cur_pos + c):
			blocked += 1
	
	if blocked < 3:
		return 0
	
	# t mini vs full distinction
	if piece_type == t:
		var front_corners : Array
		match rotation_index:
			0: front_corners = [Vector2i(-1,-1), Vector2i(1,-1)]
			1: front_corners = [Vector2i(1,-1), Vector2i(1,1)]
			2: front_corners = [Vector2i(-1,1), Vector2i(1,1)]
			3: front_corners = [Vector2i(-1,-1), Vector2i(-1,1)]
		var front_blocked = 0
		for fc in front_corners:
			if not is_free(cur_pos + fc):
				front_blocked += 1
		if front_blocked == 2:
			return 2  # full spin
		else:
			return 1  # mini spin
	return 2

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
			spawn_line_clear_particles(row - lines_cleared + 1)
			shift_rows(row)
			gravity = min(gravity + GRAVITY_INCREASE, MAX_GRAVITY)
		else:
			row -= 1
	update_level(lines_cleared)
	print("DEBUG: check_rows() complete - lines_cleared = ", lines_cleared)
	print("DEBUG: pending_spin_type = ", pending_spin_type)
	if lines_cleared > 0:
		trauma = min(trauma + (lines_cleared * 0.25), 1.0)
		wave_intensity = lines_cleared * 0.2
		$Game/Particles/LineClearBoard.emitting = true
		var spin_type = pending_spin_type
		var points = 0
		var is_difficult = false
		if spin_type == 2:
			is_difficult = true
			match lines_cleared:
				0: points = 400
				1: points = 800
				2: points = 1200
				3: points = 1600
				4: points = 2600
		elif spin_type == 1:
			is_difficult = true
			match lines_cleared:
				0: points = 100
				1: points = 200
				2: points = 400
				3: points = 800
				4: points = 1600
		else:
			match lines_cleared:
				1: points = 100
				2: points = 300
				3: points = 500
				4: 
					points = 800
					is_difficult = true
		# b2b mult
		if is_difficult and b2b_active:
			points = int(points * 1.5)
			b2b_count += 1
			$Game/HUD.get_node("B2BLabel").text = "B2B: " + str(b2b_count)
		elif is_difficult:
			b2b_active = true
			b2b_count = 1
			$Game/HUD.get_node("B2BLabel").text = "B2B: 1"
		else:
			if b2b_active:
				$Game/HUD.get_node("B2BLabel").text = ""
			b2b_active = false
			b2b_count = 0
		
		# Combo bonus (combo_count * 50, added separately)
		if last_clear_had_lines:
			combo_count += 1
			score += combo_count * 50
			$Game/HUD.get_node("ComboLabel").text = "COMBO: " + str(combo_count)
		else:
			combo_count = 1
			$Game/HUD.get_node("ComboLabel").text = ""
		last_clear_had_lines = true
		
		# All Clear
		if is_board_empty():
			points += 3500
			$Game/HUD.get_node("AllClearLabel").text = "ALL CLEAR"
		else:
			$Game/HUD.get_node("AllClearLabel").text = ""
		
		score += points * level
		$Game/HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	
	else:
		var spin_type = pending_spin_type
		if spin_type == 2:
			score += 400
		elif spin_type == 1:
			score += 100
		combo_count = 0
		last_clear_had_lines = false
		$Game/HUD.get_node("ComboLabel").text = ""
		$Game/HUD.get_node("AllClearLabel").text = ""
		$Game/HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)

func shift_rows(row):
	print("DEBUG: shift_rows() for row ", row)
	var atlas
	for i in range(row, -5, -1):
		for j in range(COLS):
			atlas = board_layer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				board_layer.erase_cell(Vector2i(j + 1, i))
			else:
				board_layer.set_cell(Vector2i(j + 1, i), tile_id, atlas)

func is_difficult_clear(lines: int, was_spin: bool) -> bool:
	if was_spin and lines > 0:
		return true
	if lines == 4:
		return true
	return false

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
			timer_running = false
			$Game/HUD.get_node("GameOverLabel").show()
			game_running = false
			return

func spawn_line_clear_particles(row: int):
	var particle_template = $Game/Particles/LineClear
	for col in range(COLS):
		var block_grid_pos = Vector2i(col + 1, row)
		var block_world_pos = board_layer.map_to_local(block_grid_pos)
		var new_particles = particle_template.duplicate()
		$Game/Particles.add_child(new_particles)
		new_particles.position = block_world_pos
		new_particles.one_shot = true
		new_particles.emitting = true
		new_particles.finished.connect(new_particles.queue_free)

func update_level(lines_just_cleared: int):
	lines_cleared_total += lines_just_cleared
	while lines_cleared_total >= lines_for_next_level:
		lines_cleared_total -= lines_for_next_level
		level += 1
		lines_for_next_level = (level * 2) + 1
		gravity = get_gravity_for_level(level)
		$Game/HUD.get_node("LevelLabel").text = "LEVEL: " + str(level)

func get_gravity_for_level(lvl: int) -> float:
	match lvl:
		1: return 0.01667
		2: return 0.021
		3: return 0.027
		4: return 0.035
		5: return 0.045
		6: return 0.059
		7: return 0.077
		8: return 0.1
		9: return 0.133
		10: return 0.18
		11: return 0.25
		12: return 0.35
		13: return 0.5
		14: return 0.7
		15: return 1.0
		16: return 1.4
		17: return 2.0
		18: return 3.0
		19: return 4.0
		20: return 5.5
		21: return 7.0
		22: return 9.0
		23: return 11.0
		24: return 14.0
		_: return 20.0

# CAMERA SYSTEM
func update_camera(delta):
	# Return camera to center
	camera_offset = camera_offset.lerp(Vector2.ZERO, CAMERA_RETURN_SPEED * delta)
	
	# Decay trauma for screen shake
	trauma = max(trauma - TRAUMA_DECAY * delta, 0.0)
	wave_intensity = max(wave_intensity - WAVE_DECAY * delta, 0.0)
	
	# Update wave shader
	if wave_material:
		wave_material.set_shader_parameter("amplitude", wave_intensity)
		wave_material.set_shader_parameter("center", Vector2(0.5, 0.5))
	
	# Calculate shake offset
	var shake_offset = Vector2.ZERO
	if trauma > 0.0:
		var shake_amount = trauma * trauma
		shake_offset.x = randf_range(-MAX_SHAKE_OFFSET, MAX_SHAKE_OFFSET) * shake_amount
		shake_offset.y = randf_range(-MAX_SHAKE_OFFSET, MAX_SHAKE_OFFSET) * shake_amount
	
	# Apply both offsets to camera
	$Game/Camera2D.offset = camera_offset + shake_offset

func nudge_camera(direction: Vector2):
	camera_offset += direction * CAMERA_NUDGE_AMOUNT

# SETTINGS CALLBACKS
func _on_arr_slider_value_changed(value: float) -> void:
	var frames = $MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/ARRContainer/ARRSlider.max_value - value
	arr_sec = frames / 60.0
	var ms = snapped(arr_sec * 1000.0, 0.01)
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/ARRContainer/SettingsValue.text = str(int(frames)) + "F / " + str(ms) + "ms"

func _on_das_slider_value_changed(value: float) -> void:
	var frames = $MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DASContainer/DASSlider.max_value - value + $MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DASContainer/DASSlider.min_value
	das_delay_sec = frames / 60.0
	var ms = snapped(das_delay_sec * 1000.0, 0.01)
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DASContainer/SettingsValue.text = str(int(frames)) + "F / " + str(ms) + "ms"

func _on_dcd_slider_value_changed(value: float) -> void:
	var frames = $MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DCDContainer/DCDSlider.max_value - value
	dcd_sec = frames / 60.0
	var ms = snapped(dcd_sec * 1000.0, 0.01)
	$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/DCDContainer/SettingsValue.text = str(int(frames)) + "F / " + str(ms) + "ms"

func _on_sdf_slider_value_changed(value: float) -> void:
	print("DEBUG SDF: Slider changed to: ", value)
	if value == 41:
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SettingsValue.text = "∞"
		sdf = 9999
		print("DEBUG SDF: Set sdf to 9999")
	else:
		$MainMenu/PopUp/Settings/SettingsPanel/VBoxContainer/SDFContainer/SettingsValue.text = str(int(value)) + "X"
		sdf = value
		print("DEBUG SDF: Set sdf to ", value)
	print("DEBUG SDF: Current sdf value is now: ", sdf)
