extends RigidBody3D

const ropeSegmentPrefab = preload("res://rope_segment.tscn")

const ropeLength: float = 1.34
@export var ropeSegments: Array[RopeSegment] = []
@export var camera: Camera3D = null
var cameraOffset = Vector3()

func _ready():
	cameraOffset = camera.global_position - global_position

var thrust = Vector3(0, 0, 25000)
var torque = 200

func _process(delta):
	camera.global_position = global_position + cameraOffset

func _integrate_forces(state):
	if Input.is_action_pressed("move_forward"):
		var forward_direction = global_transform.basis.z
		state.apply_force(forward_direction * 250, Vector3.ZERO)
		#state.apply_force(thrust.rotated(rotation.normalized(), 0))
	var rotation_direction = 0
	if Input.is_action_pressed("turn_right"):
		rotation_direction -= 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction += 1
	state.apply_torque(Vector3(0, rotation_direction * torque, 0))
