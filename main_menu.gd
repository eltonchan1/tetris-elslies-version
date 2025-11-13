extends Node2D

func _ready() -> void:
	if $VBoxContainer/PlayButton.pressed:
		start_game()
		$".".visible = true

func start_game():
	emit_signal("game_start")
	$".".visible = false
