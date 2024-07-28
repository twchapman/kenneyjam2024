class_name OceanLiner
extends RigidBody3D

var local_collision_points = []
var sparks = preload("res://sparks.tscn")
var smokes = preload("res://smoke.tscn")
var can_spark = true
var sparktimer = 1
var sparktimerleft = sparktimer

@export var collision_sound: Array[AudioStream] = []

signal on_collision

func _ready():
	connect("body_entered",_on_body_entered)

func _process(delta):
	if not can_spark:
		sparktimerleft -= delta
		if sparktimerleft < 0:
			can_spark = true
			sparktimerleft = sparktimer

func _integrate_forces(state):
	local_collision_points.clear()
	for point in state.get_contact_count():
		local_collision_points.push_back(state.get_contact_collider_position(point))

func _on_body_entered(body: Node):
	if (can_spark or true) and not body is RopeSegment:
		can_spark = false
		var sparkss = 5
		for point in local_collision_points:
			sparkss -= 1
			if sparkss < 0:
				break
			var spark = sparks.instantiate() as Node3D
			spark.position = point
			get_tree().root.add_child(spark)
			var smoke = smokes.instantiate() as Node3D
			smoke.position = point
			get_tree().root.add_child(smoke)
			on_collision.emit()
			var random_index = randi_range(0, collision_sound.size() - 1)
			$AudioStreamPlayer.stream = collision_sound[random_index]
			$AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.2)
			$AudioStreamPlayer.play()
