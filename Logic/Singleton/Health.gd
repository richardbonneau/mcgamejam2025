extends Node

signal TakeDamage(player, damage)
signal HealDamage(player, damage)
signal PlayerDied(player)

signal PlayerBlinks(player)

const MAX_HEALTH = 100;

var playerHealth  = [MAX_HEALTH, MAX_HEALTH];
var playerBlinking = [false, false]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TakeDamage.connect(on_player_damaged)
	HealDamage.connect(on_player_healed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#TakeDamage.emit(0, 1) #for tests

func on_player_damaged(playerIndex: int, damageTaken: int):
	if (playerHealth[playerIndex] <= 0):
		return #Already dead
	
	if playerBlinking[playerIndex]: return
	
	playerHealth[playerIndex] -= damageTaken;
	
	if (playerHealth[playerIndex] <= 0):
		PlayerDied.emit(playerIndex);
	else: 
		PlayerBlinks.emit(playerIndex)
		playerBlinking[playerIndex] = true
		await get_tree().create_timer(1).timeout
		playerBlinking[playerIndex] = false

func on_player_healed(playerIndex: int, damageHealed: int):
	playerHealth[playerIndex] += damageHealed
	if (playerHealth[playerIndex] > MAX_HEALTH):
		playerHealth[playerIndex] = MAX_HEALTH
		
