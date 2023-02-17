extends Sprite

var health = 0
var stats  = PlayerStats

onready var animationPlayer = $AnimationPlayer
func _ready():
	stats.connect("health_changed", self, "set_chamber")

func set_chamber(value):
	if stats.health == 7:
		animationPlayer.play('0Bullets')
	elif stats.health == 6:
		animationPlayer.play('1 Bullet')
	elif stats.health == 5:
		animationPlayer.play('2 Bullet')
	elif stats.health == 4:
		animationPlayer.play('3 Bullet')
	elif stats.health == 3:
		animationPlayer.play('4 Bullet')
	elif stats.health == 2:
		animationPlayer.play('5 Bullet')
	elif stats.health == 1:
		animationPlayer.play('6 Bullet')
