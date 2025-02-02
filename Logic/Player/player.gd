extends CharacterBody3D
class_name Player

@onready var explosion_packed_scene = preload("res://Logic/Player/Projectiles/Torpedo/explosion.tscn")

@export var player_index:int = 0

@export var movement_point:Node3D
@export var orbit_radius = 2.0  # Distance from player
@export var speed = 20  # Maximum movement speed
@export var acceleration = 100.0  # How quickly to reach max speed
@export var drag_factor = 0.92  # Underwater drag (lower = more drag)
@export var rotation_speed = 3.0  # Speed of rotation (in radians per second)
@export var smoothing_factor = 0.1  # How quickly to smooth movement input

# Store initial Z position
var initial_z = 0.0
var target_rotation = -PI/2  # -PI/2 for right, PI/2 for left
var orbit_angle = 0.0
var smoothed_stick_input := Vector2.ZERO

const JOY_AXIS_0 = 0  # Left stick X
const JOY_AXIS_1 = 1  # Left stick Y

var dead: bool = false

var cargo: Array = []
@export var max_weight: float = 10.0

@export var respawn_time = 3.0

var initial_position

func _ready():
	Health.PlayerDied.connect(_player_died)
	Health.PlayerBlinks.connect(_player_blinks)
	initial_z = position.z
	initial_position = position
	
	# Set collision layer based on player index
	# Player 0 is on layer 2, Player 1 is on layer 3
	var collision_area = $HitDetectionArea
	if collision_area:
		# Reset all collision layers first
		collision_area.set_collision_layer_value(2, false)
		collision_area.set_collision_layer_value(3, false)
		
		# Set the appropriate layer for this player
		if player_index % 2 == 0:
			collision_area.set_collision_layer_value(2, true)  # Layer 2 for player 0
			$GREENDSUBMARINE.show()
		else:
			collision_area.set_collision_layer_value(3, true)  # Layer 3 for player 1
			$REDSUBMARINE.show()
	
	__spawn()


func _physics_process(delta):
	if dead: return
	# Ensure movement point exists
	if not movement_point:
		push_error("Movement point not assigned!")
		return
	
	update_movement_point_position(Vector2.RIGHT)
	
	# Get raw input from gamepad
	var raw_x = Input.get_joy_axis(player_index, JOY_AXIS_0)
	var raw_y = Input.get_joy_axis(player_index, JOY_AXIS_1)
	
	# Convert to Vector2 and invert Y for proper orientation
	var raw_stick_input = Vector2(raw_x, -raw_y)
	
	# Don't process input if raw input is too small
	if raw_stick_input.length() < 0.1:
		velocity *= drag_factor
		velocity.z = 0
		move_and_slide()
		return
		
	# Apply smoothing
	smoothed_stick_input = lerp(smoothed_stick_input, raw_stick_input, smoothing_factor)
	
	if smoothed_stick_input.length() > 0.1:
		# Move the 'movement_point' in front of sub
		update_movement_point_position(smoothed_stick_input.normalized())
		
		# Make submarine look at movement point
		look_at_movement_point()
		
		# Move towards the movement point
		var dir_to_point = movement_point.global_position - global_position
		dir_to_point.z = 0
		dir_to_point = dir_to_point.normalized()
		
		velocity.x += dir_to_point.x * acceleration * delta
		velocity.y += dir_to_point.y * acceleration * delta
		
		# Also add smoothed input acceleration
		velocity.x += smoothed_stick_input.x * acceleration * delta
		velocity.y += smoothed_stick_input.y * acceleration * delta
		
		# Clamp speed
		var current_vel_2d = Vector2(velocity.x, velocity.y)
		if current_vel_2d.length() > speed:
			current_vel_2d = current_vel_2d.normalized() * speed
			velocity.x = current_vel_2d.x
			velocity.y = current_vel_2d.y
	
	# Underwater drag
	velocity *= drag_factor
	velocity.z = 0
	
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
		$AudioStreamPlayer.play()
		
		var explosion = explosion_packed_scene.instantiate()
		get_tree().root.add_child(explosion)
		explosion.global_position = global_position
		var other_player
		if player_index == 0: other_player = 1
		else: other_player = 0
		explosion.start_explosion(other_player)
		#Send the player outside the playable area
		position.x = 999
		position.y = 999
		#TODO : trigger death animation?
		#TODO : drop all cargo or shuffle it on the map?
		cargo = []
		hide() #Hides body from view
		await get_tree().create_timer(respawn_time).timeout
		_respawn()
		

func _player_blinks(playerIndex: int):
	if(playerIndex == player_index):
		for i in range(5): # 5 blinks over 1 second
			if player_index % 2 == 0: $GREENDSUBMARINE.hide()
			else: $REDSUBMARINE.hide()

			await get_tree().create_timer(0.1).timeout
			if player_index % 2 == 0: $GREENDSUBMARINE.show()
			else: $REDSUBMARINE.show()

			await get_tree().create_timer(0.1).timeout

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
	$Respawn.play()
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
	$PickupTreasure.play()
	if dead: return false
	var weight: float = item.weight
	for treasure in cargo:
		weight += treasure.weight
	if weight > max_weight: return false
	cargo.append(item.duplicate())
	return true
	
func unload_cargo():
	if cargo.size() > 0:
		print("unloading cargo")
		var item = cargo.pop_back()
		Scoreboard.player_scored.emit(player_index, item.worth)
		return true
	else: return false
