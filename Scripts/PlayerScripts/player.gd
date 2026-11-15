extends CharacterBody2D

var input
@export var speed = 100.0
@export var gravity = 10

var max_jumps = 1
var jump_count = 0
@export var jump_force = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	movement(delta)

func movement(delta):
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input != 0:
		if input > 0:
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100.0, speed)
			$AnimationPlayer.play("WalkRight")
			$Sprite2D.flip_h = false
		if input < 0:
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100.0, -speed)
			$AnimationPlayer.play("WalkRight")
			$Sprite2D.flip_h = true
	if input == 0 && is_on_floor():
		velocity.x = 0
		$AnimationPlayer.play("Idle")
	if input == 0 && !is_on_floor():
		$AnimationPlayer.play("Idle")
		
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_pressed("ui_accept") && is_on_floor() && jump_count < max_jumps:
		jump_count += 1
		velocity.y -= jump_force
		velocity.x = input
		
	if Input.is_action_just_released("ui_accept") && !is_on_floor():
		velocity.x = input
	
	gravity_force()
	move_and_slide()

func gravity_force():
	velocity.y += gravity
