extends Node

@export var mob_scene: PackedScene
var score

func _ready():
	# Allow this node to continue receiving input while paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide pause message when game starts
	$HUD/PauseLabel.hide()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	get_tree().paused = false

	# Hide pause message when starting/restarting
	$HUD/PauseLabel.hide()

	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _input(event):
	if event.is_action_pressed("ui_cancel"):

		if get_tree().paused:
			$HUD/PauseLabel.hide()
			$Music.stream_paused = false
			get_tree().paused = false
		else:
			$HUD/PauseLabel.show()
			$Music.stream_paused = true
			get_tree().paused = true
