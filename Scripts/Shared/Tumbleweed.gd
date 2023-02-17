extends Node2D

onready var animationPlayer = $KinematicBody2D/Sprite/AnimationPlayer
onready var kinematicBody2D = $KinematicBody2D

func _physics_process(delta):
	kinematicBody2D.move_and_slide(Vector2(100,0))
	animationPlayer.play("Roll")

