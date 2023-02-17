extends CanvasLayer

signal start_game

var score = Score

onready var scoreLabel        = $ScoreLabel
onready var messageLabel      = $MessageLabel
onready var messageTimer      = $MessageTimer
onready var button            = $Button
onready var controlsContainer = $controlsContainer 
onready var intro             = $Intro

func _process(delta):
	scoreLabel.text = str(score.score)
	
func show_message(text):
	messageLabel.text = text
	messageLabel.show()
	messageTimer.start()
	
func show_intro(text):
	intro.text = text
	intro.show()
	
func hide_intro():
	intro.hide()

func show_game_over():
	show_message('Game Over')
	yield(messageTimer,'timeout')
	messageLabel.text = "The Hungry Cowboy"
	messageLabel.show()
	yield(get_tree().create_timer(1),"timeout")
	button.show()
	controlsContainer.show()

func _on_MessageTimer_timeout():
	messageLabel.hide()

func _on_Button_pressed():
	button.hide()
	controlsContainer.hide()
	emit_signal('start_game')
