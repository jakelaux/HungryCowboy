extends Area2D

export var SPEED:    = 100
export var DAMAGE:   = 1
var knockback_vector = Vector2.ZERO
var damage = DAMAGE

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += SPEED * direction * delta
	
func destroy():
	queue_free()

func _on_Bullet_area_entered(area):
	queue_free()
	
func _on_Bullet_body_entered(body):
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
