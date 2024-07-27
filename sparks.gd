extends Node3D

var life = 0


func _process(delta):
	life += delta
	if life > ($CPUParticles3D as CPUParticles3D).lifetime:
		queue_free()
