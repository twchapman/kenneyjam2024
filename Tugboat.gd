extends RigidBody3D

const ropeSegmentPrefab = preload("res://rope_segment.tscn")

const ropeLength: float = 1.34
@export var ropeSegments: Array[RopeSegment] = []
@export var camera: Camera3D = null
var cameraOffset = Vector3()

func _ready():
	cameraOffset = camera.global_position - global_position

var thrust = 250
var torque = 200

func _process(delta):
	if not $MotorPlayer.playing and not self.freeze:
		$MotorPlayer.play()
	camera.global_position = global_position + cameraOffset

func _integrate_forces(state):
	if Input.is_action_pressed("move_forward"):
		var forward_direction = global_transform.basis.z
		state.apply_force(forward_direction * thrust, Vector3.ZERO)
		#state.apply_force(thrust.rotated(rotation.normalized(), 0))
		($MotorPlayer as AudioStreamPlayer).pitch_scale = 0.7
	else:
		($MotorPlayer as AudioStreamPlayer).pitch_scale = 0.5
	var rotation_direction = 0
	if Input.is_action_pressed("turn_right"):
		rotation_direction -= 1
	if Input.is_action_pressed("turn_left"):
		rotation_direction += 1
	state.apply_torque(Vector3(0, rotation_direction * torque, 0))

func _on_motor_player_finished():
	$MotorPlayer.play()
