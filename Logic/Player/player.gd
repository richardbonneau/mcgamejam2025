extends CharacterBody3D

@export var player_index:int = 0

@export var speed = 100.0  # Maximum movement speed
@export var acceleration = 100.0  # How quickly to reach max speed
@export var drag_factor = 0.92  # Underwater drag (lower = more drag)
@export var rotation_speed = 3.0  # Speed of rotation (in radians per second)

# Store initial Z position
var initial_z = 0.0
var target_rotation = -PI/2  # -PI/2 for right, PI/2 for left

var dead: bool = false

@export var respawn_time = 3.0

func _ready():
	Health.PlayerDied.connect(_player_died)
	initial_z = position.z
	__spawn()

func _physics_process(delta):
	if (!dead):
		# Get input direction (only X and Y)
		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_axis("ui_left", "ui_right")
		input_dir.y = Input.get_axis("ui_up", "ui_down")
		input_dir = input_dir.normalized()
		
		# Apply acceleration in the input direction
		if input_dir != Vector3.ZERO:
			velocity.x += input_dir.x * acceleration * delta
			velocity.y -= input_dir.y * acceleration * delta
			
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
		
		# Update target rotation based on movement direction
		if abs(velocity.x) > 0.1:  # Only change target when there's significant horizontal movement
			target_rotation = -PI/2 if velocity.x > 0 else PI/2
		
		# Smoothly interpolate current rotation to target
		if abs(rotation.y - target_rotation) > 0.01:  # If we're not already at target
			var shortest_angle = fposmod(target_rotation - rotation.y + PI, PI * 2) - PI
			rotation.y += sign(shortest_angle) * min(rotation_speed * delta, abs(shortest_angle))
		
		move_and_slide()
		
		# Lock Z position
		position.z = initial_z

func _player_died(playerIndex: int):
	if (playerIndex == player_index):
		dead = true
		print("Player "+str(player_index)+" has died.")
		#TODO : trigger death animation?
		hide() #Hides body from view
		#TODO : Disable collisions
		await get_tree().create_timer(respawn_time).timeout
		_respawn()

func __spawn():
	# Player "0" will start facing right
	# Player "1" will start facing left
	rotation.y = (-1 ** (player_index+1)) * PI/2 
	
	#Stops movement
	velocity.x = 0;
	velocity.y = 0;
	
	#Sets health
	Health.HealDamage.emit(player_index, Health.MAX_HEALTH)
	
	#TODO : Spawn (initial position in the scene, export x + y?)
	position.z = initial_z
	
	#TODO : Enable collisions
	

func _respawn():
	__spawn()
	show()
	dead = false
	print("Player "+str(player_index)+" has respawned.")
