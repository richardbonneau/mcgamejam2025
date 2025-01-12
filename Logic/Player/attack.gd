extends Node3D

@export var shooting_point: Node3D
@export var orbit_radius = 4.0  # Distance from player
@export var torpedo_scene: PackedScene
@export var fire_cooldown = 0.5  # seconds between shots
@export var min_stick_threshold = 0.001  # Lower threshold for more precise control

var can_fire = true
var cooldown_timer = 0.0
var aim_line: Line2D
var playerInstance: Player

# Store the current smoothed stick input
var smoothed_stick_input := Vector2.ZERO
var smoothing_factor := 0.1

const JOY_AXIS_2 = 2
const JOY_AXIS_3 = 3

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
	
	# Get raw input using the right stick
	var raw_x = Input.get_joy_axis(playerInstance.player_index, JOY_AXIS_2)
	var raw_y = Input.get_joy_axis(playerInstance.player_index, JOY_AXIS_3)
	
	# Convert to Vector2 and invert Y for proper orientation
	var raw_stick_input = Vector2(raw_x, -raw_y)

	# Don't process input if raw input is too small
	if raw_stick_input.length() < 0.05:
		aim_line.visible = false
		return

	# Apply smoothing
	smoothed_stick_input = lerp(smoothed_stick_input, raw_stick_input, smoothing_factor)

	# Apply deadzone
	if smoothed_stick_input.length() < min_stick_threshold:
		smoothed_stick_input = Vector2.ZERO

	# Update shooting point and aim line if aiming
	if smoothed_stick_input.length() > 0:
		update_shooting_point_position(smoothed_stick_input.normalized())
		update_aim_line()
	else:
		aim_line.visible = false
	
	# Check if R2 is pressed and we can fire
	if not playerInstance.dead and can_fire and smoothed_stick_input.length() > min_stick_threshold:
		var shoot_dir = (shooting_point.global_position - global_position)
		shoot_dir.z = 0  # Ensure we're in 2D plane
		fire_torpedo(Vector2(shoot_dir.x, shoot_dir.y).normalized())

func update_shooting_point_position(direction: Vector2) -> void:
	if shooting_point:
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
		var start_pos = Vector2(global_position.x, global_position.y)
		var end_pos = Vector2(shooting_point.global_position.x, shooting_point.global_position.y)
		aim_line.add_point(start_pos)
		aim_line.add_point(end_pos)

func fire_torpedo(direction: Vector2) -> void:
	if playerInstance.dead: return
	can_fire = false
	var torpedo = torpedo_scene.instantiate()
	get_tree().get_root().add_child(torpedo)
	torpedo.global_position = global_position
	torpedo.position.z = 0
	torpedo.player_id = playerInstance.player_index
	torpedo.shoot(direction, playerInstance.player_index)
