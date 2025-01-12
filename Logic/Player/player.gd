extends CharacterBody3D
class_name Player

@export var player_index:int = 0

@export var movement_point:Node3D
@export var orbit_radius = 2.0  # Distance from player
@export var speed = 20  # Maximum movement speed
@export var acceleration = 100.0  # How quickly to reach max speed
@export var drag_factor = 0.92  # Underwater drag (lower = more drag)
@export var rotation_speed = 3.0  # Speed of rotation (in radians per second)

# Store initial Z position
var initial_z = 0.0
var target_rotation = -PI/2  # -PI/2 for right, PI/2 for left
var orbit_angle = 0.0

var dead: bool = false

var cargo: Array = []
@export var max_weight: float = 30.0

@export var respawn_time = 3.0

var initial_position

func _ready():
	Health.PlayerDied.connect(_player_died)
	initial_z = position.z
	initial_position = position
	if player_index % 2 == 0: $GREENDSUBMARINE.show()
	elif player_index % 2 == 1: $REDSUBMARINE.show()
	__spawn()


func _physics_process(delta):
	# Ensure movement point exists
	if not movement_point:
		push_error("Movement point not assigned!")
		return
	
	update_movement_point_position(Vector2.RIGHT)
	
	# Get input direction from gamepad
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("l_stick_left" + str(player_index), "l_stick_right" + str(player_index))
	input_dir.y = Input.get_axis("l_stick_up"   + str(player_index), "l_stick_down"  + str(player_index))
	
	# Convert to 2D, inverting Y if needed
	var stick_input = Vector2(input_dir.x, -input_dir.y)
	
	if stick_input.length() > 0.1:
		# Move the 'movement_point' in front of sub
		update_movement_point_position(stick_input.normalized())
		
		# (Optional) Make submarine look at movement point
		look_at_movement_point()
		
		# Move towards the movement point
		var dir_to_point = movement_point.global_position - global_position
		dir_to_point.z = 0
		dir_to_point = dir_to_point.normalized()
		
		velocity.x += dir_to_point.x * acceleration * delta
		velocity.y += dir_to_point.y * acceleration * delta
		
		# Also add direct input acceleration
		velocity.x += input_dir.x * acceleration * delta
		velocity.y -= input_dir.y * acceleration * delta  # minus sign if you want to invert Y
		
		# Clamp speed
		var current_vel_2d = Vector2(velocity.x, velocity.y)
		if current_vel_2d.length() > speed:
			current_vel_2d = current_vel_2d.normalized() * speed
			velocity.x = current_vel_2d.x
			velocity.y = current_vel_2d.y
		
		# Underwater drag
		velocity.x *= drag_factor
		velocity.y *= drag_factor
		velocity.z = 0
		
		# Decide orientation based on velocity direction
		if velocity.length() > 0.1:
			var vel_2d = Vector2(velocity.x, velocity.y)
			var target_rot = get_target_orientation(vel_2d)
			
			rotation.x = smooth_angle(rotation.x, target_rot.x, rotation_speed, delta)
			rotation.y = smooth_angle(rotation.y, target_rot.y, rotation_speed, delta)
			rotation.z = 0
		
		# Actually move
		move_and_slide()
		
		# Lock Z position
		position.z = initial_z


func get_target_orientation(velocity_2d: Vector2) -> Vector3:
	var angle = velocity_2d.angle()
	var angle_deg = rad_to_deg(angle)
	
	if angle_deg > -45 and angle_deg < 45:
		# Right
		return Vector3(0, -PI/2, 0)
	elif angle_deg >= 45 and angle_deg < 135:
		# Up
		return Vector3(PI/2, 0, 0)
	elif angle_deg >= 135 or angle_deg < -135:
		# Left
		return Vector3(0, PI/2, 0)
	else:
		# Down: tilt nose down (-PI/2) but add a 180° yaw (PI) to show top
		return Vector3(-PI/2, PI, 0)



func smooth_angle(current_angle: float, target_angle: float, speed: float, delta: float) -> float:
	var shortest = fposmod((target_angle - current_angle) + PI, PI * 2) - PI
	return current_angle + sign(shortest) * min(speed * delta, abs(shortest))


func _player_died(playerIndex: int):
	if (playerIndex == player_index):
		dead = true
		print("Player "+str(player_index)+" has died.")
		#TODO : trigger death animation?
		#TODO : drop all cargo or shuffle it on the map?
		cargo = []
		hide() #Hides body from view
		await get_tree().create_timer(respawn_time).timeout
		_respawn()

func __spawn():
	#Stops movement
	velocity.x = 0;
	velocity.y = 0;
	#TODO : Spawn (initial position in the scene, export x + y?)
	position = initial_position
	# Player "0" will start facing right
	# Player "1" will start facing left
	rotation.y = (-1 ** (player_index+1)) * PI/2 
	#Sets health
	Health.HealDamage.emit(player_index, Health.MAX_HEALTH)
	

func _respawn():
	__spawn()
	show()
	dead = false
	print("Player "+str(player_index)+" has respawned.")
	# Keep Z position constant
	position.z = initial_z
	velocity.z = 0
	
	move_and_slide()

func update_movement_point_position(direction: Vector2):
	if movement_point:
		# Calculate new position based on direction
		var target_pos = Vector3(
			position.x + direction.x * orbit_radius,
			position.y + direction.y * orbit_radius,
			position.z
		)
		movement_point.global_position = target_pos

func look_at_movement_point():
	if movement_point:
		# Calculate direction to movement point
		var direction = movement_point.global_position - global_position
		if direction.length() > 0.1:
			# Create a temporary position to look at that maintains the same Z coordinate
			var look_target = Vector3(
				movement_point.global_position.x,
				movement_point.global_position.y,
				global_position.z
			)
			look_at(look_target, Vector3.UP)

func pickup_treasure(item: Treasure):
	if dead: return false
	var weight: float = item.weight
	for treasure in cargo:
		weight += treasure.weight
	if weight > max_weight: return false
	cargo.append(item.duplicate())
	return true
	
func unload_cargo():
	while(cargo.size() > 0):
		var item = cargo.pop_back()
		Scoreboard.player_scored.emit(player_index, item.worth)
