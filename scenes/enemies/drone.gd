extends CharacterBody2D

var speed: int = 200
var max_speed: int = 600
var active: bool = false
var speed_multiplier:int = 1

var health:int = 30
var vulnerable:bool = true

var explosion_active: bool = false
var explosion_radius: int = 280

func _ready():
	$Explosion.hide()

func _process(delta):
	if active and health > 0:
		look_at(Globals.player_pos)
		var direction = (Globals.player_pos - global_position).normalized()
		velocity = direction * speed * speed_multiplier
		var collision = move_and_collide(velocity * delta)
		if collision:
			explode()
			
		if explosion_active:
			var targets = get_tree().get_nodes_in_group("Entity") + get_tree().get_nodes_in_group("Container")
			for target in targets:
				var in_range = target.global_position.distance_to(global_position) < explosion_radius
				if "hit" in target and in_range:
					target.hit()
		
func hit():
	if vulnerable:
		$DroneImage.material.set_shader_parameter('progress', 1.0)
		health -= 10
		vulnerable = false
		$HitCooldown.start()
		$AudioStreamPlayer2D.play()
	if health <= 0:
		explode()


func explode():
	$AnimationPlayer.play("explosion")
	explosion_active = true


func stop_movement():
	speed_multiplier = 0


func _on_notice_area_2d_body_entered(_body):
	active = true
	var tween = create_tween()
	tween.tween_property(self, 'speed', max_speed, 3)


func _on_hit_cooldown_timeout():
	$DroneImage.material.set_shader_parameter('progress', 0.0)
	vulnerable = true
