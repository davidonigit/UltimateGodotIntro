extends CharacterBody2D

var active: bool = false
var vulnerable: bool = true
var attacking:bool = false
var speed: int = 300

var health: int = 20

signal laser(pos,direction)

func hit():
	active = true
	if vulnerable:
		health -= 10
		vulnerable = false
		$Timers/HitCooldown.start()
		$AnimatedSprite2D.material.set_shader_parameter('progress', 1.0)
		$Particles/HitParticles.emitting = true
		$AudioStreamPlayer2D.play()
	if health <= 0:
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _process(_delta):
	if active and not attacking:
		var direction = (Globals.player_pos - global_position).normalized()	
		velocity = direction * speed
		look_at(Globals.player_pos)
		move_and_slide()
		$AnimatedSprite2D.play("walk")


func _on_notice_area_2d_body_entered(_body):
	active = true


func _on_notice_area_2d_body_exited(_body):
	active = false
	$AnimatedSprite2D.stop()


func _on_attack_area_2d_body_entered(_body):
	attacking = true
	$AnimatedSprite2D.play("attack")


func _on_attack_area_2d_body_exited(_body):
	attacking = false


func _on_animated_sprite_2d_animation_finished():
	if attacking:
		Globals.health -= 10
		$Timers/AttackCooldown.start()


func _on_attack_cooldown_timeout():
	$AnimatedSprite2D.play("attack")


func _on_hit_cooldown_timeout():
	vulnerable = true
	$AnimatedSprite2D.material.set_shader_parameter('progress', 0.0)
