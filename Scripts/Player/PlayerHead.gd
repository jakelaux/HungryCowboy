extends Position2D

onready var headAnimation = $HeadAnimation
onready var head          = $Head
onready var bulletSpawn   = $BulletSpawn
onready var bullets       = 0
onready var spitSound     = $SpitSound

var stats = PlayerStats

export(PackedScene) var BULLET: PackedScene = preload("res://Scenes/Shared/Bullet.tscn")

enum { MOVE, SHOOT, SPECIAL, WAITFOR }
var state = MOVE

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	if mouse_position.x < self.get_global_position().x:
		head.flip_v = true
		head.offset.y = 16
		bulletSpawn.position.y = 3
	else:
		head.flip_v = false
		head.offset.y = 0
		bulletSpawn.position.y = -4
	match state:
		MOVE:
			move_state(delta)
		SHOOT:
			var bullet_direction = self.global_position.direction_to(mouse_position)
			if stats.health > 6:
				state = MOVE
				pass
			elif stats.health <= 6:
				stats.health += 1
				shoot(bullet_direction)
		SPECIAL:
			pass
		WAITFOR:
			pass
	
func move_state(delta):
	if Input.is_action_just_pressed("shoot"):
		state = SHOOT
	else:
		headAnimation.play("Idle")

func shoot(bullet_direction: Vector2):
	if BULLET:
		spitSound.play()
		var bullet = BULLET.instance()
		headAnimation.play("Shoot")
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = bulletSpawn.global_position
		var bullet_rotation = bullet_direction.angle()
		bullet.rotation = bullet_rotation
		state = WAITFOR
	
func _on_HeadAnimation_animation_finished(anim_name):
	headAnimation.play("Idle")
	state = MOVE
