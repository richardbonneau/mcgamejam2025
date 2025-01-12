extends Control
@export var player_index:int = 0  # Which player's health to show
@export var bar_color: Color = Color(0.2, 0.8, 0.2)  # Default green color
@onready var progress_bar = $MarginContainer/ProgressBar

func _ready():
	# Connect to Health singleton signals
	Health.TakeDamage.connect(_on_health_changed)
	Health.HealDamage.connect(_on_health_changed)
	
	# Set initial value
	progress_bar.max_value = Health.MAX_HEALTH
	progress_bar.value = Health.playerHealth[player_index]
	
	# Create a unique style for this instance
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = bar_color
	style_box.set_corner_radius_all(5)
	progress_bar.add_theme_stylebox_override("fill", style_box)

func _on_health_changed(_player_index: int, _damage: int):
	if _player_index == player_index:
		progress_bar.value = Health.playerHealth[player_index]
