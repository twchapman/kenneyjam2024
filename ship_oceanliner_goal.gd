class_name Goal
extends Area3D

signal on_goal_reached

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body: Node):
	if body is OceanLiner or body.get_parent() is OceanLiner:
		on_goal_reached.emit()
