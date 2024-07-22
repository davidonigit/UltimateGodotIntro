extends CharacterBody2D

signal laser(pos, direction)
signal grenade(pos, direction)

var can_laser: bool = true
var can_grenade: bool = true

@export var max_speed: int = 500
var speed: int = max_speed

func hit():
	Globals.health -= 10


func _process(_delta):
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed
	move_and_slide()
	Globals.player_pos = global_position
	
	# rotate
	look_at(get_global_mouse_position())
	var player_direction = (get_global_mouse_position() - position).normalized()
	
	if (Input.is_action_pressed("primary action") and can_laser and Globals.laser_amount > 0):
		can_laser = false
		Globals.laser_amount -= 1
		$TimerLaser.start()
		var laser_markers = $LaserStartPositions.get_children()
		var selected_laser = laser_markers[randi() % laser_markers.size()]
		laser.emit(selected_laser.global_position, player_direction)
		$GPUParticles2D.emitting = true
	
	if (Input.is_action_pressed("secondary action") and can_grenade and Globals.grenade_amount > 0):
		can_grenade = false
		Globals.grenade_amount -= 1
		$TimerGrenade.start()
		var grenade_marker = $LaserStartPositions.get_children()[0]
		grenade.emit(grenade_marker.global_position, player_direction)


func _on_timer_laser_timeout():
	can_laser = true


func _on_timer_grenade_timeout():
	can_grenade = true
