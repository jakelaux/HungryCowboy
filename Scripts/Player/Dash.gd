extends Node2D

const dash_delay = 0.5

onready var dashTimer  = $DashTimer
onready var ghostTimer = $GhostTimer 
var ghostScene = preload("res://Scenes/Player/DashGhost.tscn")
var canDash = true
var sprite
var head
var head_pos

func startDash(sprite, head, duration):
	self.sprite   = sprite
	self.head     = head
	dashTimer.wait_time = duration
	dashTimer.start()
	ghostTimer.start()
	instanceGhost()

func instanceGhost():
	var ghost: Sprite = ghostScene.instance()
	var h_ghost: Sprite = ghostScene.instance()
	get_parent().get_parent().add_child(ghost)
	get_parent().get_parent().add_child(h_ghost)
	ghost.global_position    = global_position
	ghost.texture            = sprite.texture
	ghost.vframes            = sprite.vframes
	ghost.hframes            = sprite.hframes
	ghost.frame              = sprite.frame
	ghost.flip_h             = sprite.flip_h
	h_ghost.global_position  = global_position
	h_ghost.global_position.y = h_ghost.global_position.y - 10
	h_ghost.texture          = head.texture
	h_ghost.vframes          = head.vframes
	h_ghost.hframes          = head.hframes
	h_ghost.frame            = head.frame
	h_ghost.flip_h           = head.flip_h
	
func isDashing():
	return !dashTimer.is_stopped()

func endDash():
	ghostTimer.stop()
	canDash = false
	yield(get_tree().create_timer(dash_delay), 'timeout')
	canDash = true

func _on_DashTimer_timeout():
	endDash()

func _on_GhostTimer_timeout():
	instanceGhost()
