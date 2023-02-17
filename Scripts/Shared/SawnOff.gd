extends Position2D

onready var sprite          = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var bulletSpawn     = $BulletSpawn
onready var playerDetection = $PlayerDetection

export(PackedScene) var BULLET: PackedScene = preload("res://Scenes/Shared/Bullet.tscn")

func _physics_process(delta):
	var player = playerDetection.player
	if player != null:
		self.rotation = lerp_angle(self.rotation, PI + self.global_position.angle_to_point(player.global_position),0.3)
	
func enemyShoot(bullet_direction):
	if BULLET:
		var bullet = BULLET.instance()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = $BulletSpawn.global_position
		var bullet_rotation = bullet_direction.angle()
		bullet.rotation = bullet_rotation
		animationPlayer.play("Shoot")
