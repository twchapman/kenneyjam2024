class_name Goal
extends Area3D

signal on_goal_reached

#func _input(event):
	#if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_P:
		#on_goal_reached.emit()

func _on_body_entered(body: Node):
	if body is OceanLiner or body.get_parent() is OceanLiner:
		on_goal_reached.emit()
