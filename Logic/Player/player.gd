extends CharacterBody3D

@export var speed = 300.0  # Maximum movement speed
@export var acceleration = 1000.0  # How quickly to reach max speed
@export var drag_factor = 0.92  # Underwater drag (lower = more drag)

# Store initial Z position
var initial_z = 0.0

func _ready():
	initial_z = position.z

func _physics_process(delta):
	# Get input direction (only X and Y)
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	input_dir = input_dir.normalized()
	
	# Apply acceleration in the input direction
	if input_dir != Vector3.ZERO:
		velocity.x += input_dir.x * acceleration * delta
		velocity.y += input_dir.y * acceleration * delta
		
		# Clamp to max speed
		var current_velocity = Vector2(velocity.x, velocity.y)
		if current_velocity.length() > speed:
			current_velocity = current_velocity.normalized() * speed
			velocity.x = current_velocity.x
			velocity.y = current_velocity.y
	
	# Apply underwater drag when no input or slowing down
	velocity.x *= drag_factor
	velocity.y *= drag_factor
	
	# Keep Z velocity at 0
	velocity.z = 0
	
	move_and_slide()
	
	# Lock Z position
	position.z = initial_z
