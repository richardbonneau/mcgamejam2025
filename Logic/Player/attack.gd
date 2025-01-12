extends Node3D

@export var shooting_point:Node3D
@export var orbit_radius = 2.0  # Distance from player
@export var torpedo_scene: PackedScene
@export var fire_cooldown = 0.5  # seconds between shots
@export var min_stick_threshold = 0.1  # Lower threshold for more precise control

var can_fire = true
var cooldown_timer = 0.0
var aim_line: Line2D
var playerInstance: Player

func _ready():
	playerInstance = get_parent()
	# Create aim line
	aim_line = Line2D.new()
	add_child(aim_line)
	aim_line.width = 2.0
	aim_line.default_color = Color(1, 0, 0, 0.5)  # Semi-transparent red
	
	# Ensure shooting point exists
	if not shooting_point:
		push_error("Shooting point not assigned!")
		return

func _process(delta: float) -> void:
	# Handle cooldown
	if not can_fire:
		cooldown_timer += delta
		if cooldown_timer >= fire_cooldown:
			can_fire = true
			cooldown_timer = 0.0
	
	# Get input using the right stick
	var stick_x = Input.get_axis("r_stick_left"+str(playerInstance.player_index), "r_stick_right"+str(playerInstance.player_index))
	var stick_y = Input.get_axis("r_stick_up"+str(playerInstance.player_index), "r_stick_down"+str(playerInstance.player_index))
	
	# Create input vector
	var stick_input = Vector2(stick_x, -stick_y)  # Invert Y for correct orientation
	
	if stick_input.length() > min_stick_threshold:
		# Update shooting point position
		update_shooting_point_position(stick_input.normalized())
		# Update aim line
		update_aim_line()
	else:
		# Hide aim line when not aiming
		aim_line.visible = false
	
	# Check if R2 is pressed and we can fire
	if (!playerInstance.dead) and Input.is_action_pressed("r2"+str(playerInstance.player_index)) and can_fire and stick_input.length() > min_stick_threshold:
		# Calculate direction from player to shooting point
		var shoot_dir = (shooting_point.global_position - global_position)
		shoot_dir.z = 0  # Ensure we're in 2D plane
		fire_torpedo(Vector2(shoot_dir.x, shoot_dir.y).normalized())

func update_shooting_point_position(direction: Vector2) -> void:
	if shooting_point:
		# Calculate new position based on direction
		var target_pos = Vector3(
			global_position.x + direction.x * orbit_radius,
			global_position.y + direction.y * orbit_radius,
			global_position.z
		)
		shooting_point.global_position = target_pos

func update_aim_line() -> void:
	if shooting_point:
		aim_line.visible = true
		aim_line.clear_points()
		# Convert 3D positions to 2D for the line
		var start_pos = Vector2(global_position.x, global_position.y)
		var end_pos = Vector2(shooting_point.global_position.x, shooting_point.global_position.y)
		aim_line.add_point(start_pos)
		aim_line.add_point(end_pos)

func fire_torpedo(direction: Vector2) -> void:
	can_fire = false
	
	# Instance the torpedo
	var torpedo = torpedo_scene.instantiate()
	get_tree().get_root().add_child(torpedo)
	
	# Set torpedo's position to this spawner's global position
	torpedo.global_position = global_position
	torpedo.position.z = 0
	torpedo.player_id = playerInstance.player_index
	
	# Launch the torpedo
	torpedo.shoot(direction)
