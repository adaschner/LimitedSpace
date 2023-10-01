extends Node2D

@export var next_level: PackedScene

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var game_over = $CanvasLayer/GameOver
@onready var lives = $CanvasLayer/Lives
@onready var game_over_timer = $GameOverTimer
@onready var goal_audio_stream_player = $GoalAudioStreamPlayer
@onready var game_audio_stream_player = $GameAudioStreamPlayer

var start_menu = load("res://start_menu.tscn")

func _ready():
	if not next_level is PackedScene: 
		next_level = load("res://victory_screen.tscn")
	RenderingServer.set_default_clear_color(Color.SKY_BLUE)
	lives.text = "Lives: " + str(Global.lives)
	Events.level_completed.connect(show_level_completed)
	Events.game_over.connect(show_game_over)

func show_level_completed():
	game_audio_stream_player.stop()
	goal_audio_stream_player.play()
	level_completed.show()
	if not next_level is PackedScene: return
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()

	
func show_game_over():
	game_over.show()
	lives.hide()
	game_over_timer.start()
	get_tree().paused = true

func _on_game_over_timer_timeout():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://start_menu.tscn")
	Global.lives = Global.INITIAL_LIVES


func _on_game_audio_stream_player_finished():
	game_audio_stream_player.play()
