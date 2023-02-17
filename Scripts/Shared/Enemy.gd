extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED    = 50
export var FRICTION     = 200
export var WANDER_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var score     = Score
var state     = CHASE
var velocity  = Vector2.ZERO
var knockback = Vector2.ZERO

onready var stats                = $Stats
onready var playerDetection      = $PlayerDetection
onready var sprite               = $Sprite
onready var hurtbox              = $Hurtbox
onready var softCollision        = $SoftCollision
onready var wanderController     = $WanderController
onready var animationPlayer      = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var hitbox               = $Hitbox/CollisionShape2D
onready var dieNoise             = $DieNoise

func _ready():
	state = pick_rand_state([IDLE, WANDER])
	animationPlayer.play("idle")
				
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
		
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_RANGE:
				update_wander()
		
		CHASE:
			var player = playerDetection.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400 
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_rand_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	
func seek_player():
	if playerDetection.can_see_player():
		state = CHASE
		
func pick_rand_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.DAMAGE
	knockback = area.knockback_vector *  120
	hurtbox.start_invincibility(0.4)
	
func _on_Stats_no_health():
	score.set_score(score.score+1)
	hitbox.set_deferred('disabled', true)
	animationPlayer.play("Die")
	dieNoise.play()

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func on_death_animation_finished():
	queue_free()
