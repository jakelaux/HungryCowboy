extends Node2D

export(PackedScene) var MELE: PackedScene       = preload("res://Scenes/Enemies/MeleEnemy.tscn")
export(PackedScene) var RANGED: PackedScene     = preload("res://Scenes/Enemies/RangedEnemy.tscn")
export(PackedScene) var TUMBLEWEED: PackedScene = preload("res://Scenes/World/Tumbleweed.tscn")

var score = Score
var first_play = true

onready var HUD              = $HUD
onready var player           = $YSort/Player
onready var playerHead       = $YSort/Player/PlayerHead
onready var startPosition    = $StartPosition
onready var ghostTimer       = $GhostTimer
onready var rangedGhostTimer = $RangedGhostTimer
onready var tumbleweedTimer  = $TumbleweedTimer
onready var startTimer       = $StartTimer
onready var music            = $Music

func _ready():
	randomize()
	
func new_game():
	player.state = 0
	score.score  = 0 
	player.animationPlayer.play('Idle')
	playerHead.visible = true
	player.stats.health = 6
	player.stats.max_health = 6
	score.set_score(0)
	player.start(startPosition.position)
	HUD.show_message("Boy am I hungry...")
	if first_play:
		yield(get_tree().create_timer(2),"timeout")
		var start_msg = ["In fact, I'm so hungry","that I think I could eat bullets \n straight out of the air!","But... I think if I eat more than \n six bullets which is the amount \n that can fit in my chamber","(that's what I call \n my belly he he he)","I may die...","I'm also allergic to ghosts \n so if one touches me \n I'm pretty sure I'll die as well...","Tarnation..."]
		yield(startup_dialog(start_msg), 'completed')
		HUD.hide_intro()
		first_play = false
	music.play()
	ghostTimer.start()
	rangedGhostTimer.start()
	tumbleweedTimer.start()
	ghostTimer.wait_time = 3
	rangedGhostTimer.wait_time = 2
	yield(startTimer,'timeout')

func startup_dialog(dialog_array):
	for msg in dialog_array:
		HUD.show_intro(msg)
		yield(get_tree().create_timer(4),"timeout")
	
func game_over():
	get_tree().call_group('Enemies','queue_free')
	ghostTimer.stop()
	rangedGhostTimer.stop()
	HUD.show_game_over()

func _on_GhostTimer_timeout():
	spawn_ghost(MELE)

func _on_RangedGhostTimer_timeout():
	spawn_ghost(RANGED)

func spawn_ghost(packed_scene):
	#Generate a randomized spawn location on the spawn path
	var ghost_spawn = $GhostPath/GhostSpawn
	ghost_spawn.unit_offset = randf()
	#Initialize the mob and add to main scene
	var ghost = packed_scene.instance()
	add_child(ghost)
	#Turn the mob in the direction it should be facing and randomize the angle of the mob
	ghost.position = ghost_spawn.position

func _on_HUD_start_game():
	new_game()

func _on_Player_player_dead():
	game_over()

func _on_DifficultyTimer_timeout():
	
	if ghostTimer.wait_time >= .25:
		ghostTimer.wait_time = ghostTimer.wait_time * .75
	if rangedGhostTimer.wait_time >= .25:
		rangedGhostTimer.wait_time = rangedGhostTimer.wait_time * .75

func _on_TumbleweedTimer_timeout():
	spawn_ghost(TUMBLEWEED)
