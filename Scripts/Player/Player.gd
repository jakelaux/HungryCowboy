extends KinematicBody2D

signal player_dead

export var ACCELERATION  = 500
export var MAX_SPEED     = 80
export var DASH_SPEED    = 17000
export var DASH_DURATION = 0.2
export var FRICTION      = 500

enum { MOVE, DASH, DEATH }

var state       = MOVE
var velocity    = Vector2.ZERO
var dash_vector = Vector2.DOWN
var stats       = PlayerStats
var screen_size = Vector2.ZERO

onready var animationPlayer      = $AnimationPlayer 
onready var sprite               = $Sprite
onready var hurtbox              = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var playerHead           = $PlayerHead
onready var headSprite           = playerHead.head
onready var dash                 = $Dash
onready var dashSound            = $dashSound
onready var hurtSound            = $HurtSound

func _ready():
	screen_size = get_viewport_rect().size
	stats.connect("no_health", self, "handle_death")
	animationPlayer.play("Idle")
	
func _physics_process(delta):
	if stats.health == 7:
		sprite.scale.x = 1
	elif stats.health == 6:
		sprite.scale.x = 1.1
	elif stats.health == 5:
		sprite.scale.x = 1.2
	elif stats.health == 4:
		sprite.scale.x = 1.3
	elif stats.health == 3:
		sprite.scale.x = 1.4
	elif stats.health == 2:
		sprite.scale.x = 1.5
	elif stats.health == 1:
		sprite.scale.x = 1.6
		
	match state:
		MOVE:
			move_state(delta)
		DASH:
			dash_state(delta)
		DEATH:
			pass
	
func move_state(delta):
	var input_vector = get_input_vector()
	if input_vector != Vector2.ZERO:
		animationPlayer.play("Walk")
		if Input.get_action_strength("ui_left") > Input.get_action_strength("ui_right"):
			playerHead.position.x = 0
			sprite.flip_h = true
			playerHead.position.y = -1
		else:
			sprite.flip_h = false
			playerHead.position.y = -1
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationPlayer.play("Idle")
		playerHead.position.y = 0
		if sprite.flip_h == true:
			playerHead.position.x = 2
		else:
			playerHead.position.x = 0
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()
	if Input.is_action_just_pressed("dash") && dash.canDash && !dash.isDashing():
		state = DASH

func dash_state(delta):
	dashSound.play()
	dash.startDash(sprite, headSprite, DASH_DURATION)
	var dash_vector = get_input_vector()
	velocity = dash_vector * DASH_SPEED * delta
	state = MOVE
	move()
		
func move():
	velocity = move_and_slide(velocity)
	self.global_position.x = clamp(self.global_position.x, 0, screen_size.x)
	self.global_position.y = clamp(self.global_position.y, 0, screen_size.y)
	
func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector
	
func handle_death():
	playerHead.set_deferred('visible', false)
	state = DEATH
	stats.health = 6
	animationPlayer.play("Die")

func on_death_animation_finished():
	emit_signal("player_dead")

func start(new_position):
	position = new_position

func _on_Hurtbox_area_entered(area):
	if dash.isDashing():
		return
	hurtSound.play()
	if area.name == 'Bullet':
		stats.health -= 1
	elif area.name == 'Hitbox':
		stats.health -= 7
	hurtbox.start_invincibility(0.2)

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")
