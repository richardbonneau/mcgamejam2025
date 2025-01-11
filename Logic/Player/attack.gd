extends Node3D

@export var torpedo_scene: PackedScene
@export var fire_cooldown = 0.5  # Time between shots

var can_fire = true
var cooldown_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !can_fire:
		cooldown_timer += delta
		if cooldown_timer >= fire_cooldown:
			can_fire = true
			cooldown_timer = 0.0
	
	# Get right analog stick input
	var analog_input = Vector2(
		Input.get_axis("r_stick_left", "r_stick_right"),
		Input.get_axis("r_stick_up", "r_stick_down")
	)
	
	# Check if R2 is pressed and we have a direction
	if Input.is_action_pressed("r2") and can_fire and analog_input.length() > 0.2:
		fire_torpedo(analog_input.normalized())

func fire_torpedo(direction: Vector2) -> void:
	can_fire = false
	
	# Instance the torpedo
	var torpedo = torpedo_scene.instantiate()
	get_tree().get_root().add_child(torpedo)
	
	# Set position
	torpedo.global_position = global_position
	
	# Launch the torpedo
	torpedo.shoot(direction)
