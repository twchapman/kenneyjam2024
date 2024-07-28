extends Node3D

@export var StartUI: Node
@export var GameUI: Node
@export var timeGroup: Node
@export var time: Label
@export var damageGroup: Node
@export var damageLabel: Label
@export var TuggedBoat: OceanLiner
@export var Goal_: Goal

var paused = true
var started = false
var timeElapsed = 0
var damage = 0

func _ready():
	TuggedBoat.connect("on_collision", on_tuggedboat_collision)
	Goal_.connect("on_goal_reached", on_goal_reached)
	var damageUI = GameUI.get_child(0)

func _process(delta):
	if not paused:
		timeElapsed += delta
		time.text = "%d:%02d" % [floor(timeElapsed) / 60, fmod(timeElapsed, 60)]

func on_tuggedboat_collision():
	damage += randi_range(950, 2500)
	if not damageGroup.visible:
		damageGroup.show()
		var dtween = get_tree().create_tween()
		dtween.tween_property(damageGroup, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_IN)
		dtween.tween_property(damageGroup, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
	damageLabel.text = "$%s" % damage
	
func on_goal_reached():
	paused = true
	for child in get_children():
		if child is RigidBody3D:
			child.freeze = true

func _input(event):
	if not started and event is InputEventKey and event.pressed:
		paused = false
		started = true
		StartUI.hide()
		GameUI.show()
		for child in get_children():
			if child is RigidBody3D:
				child.freeze = false
		timeGroup.show()
		var ttween = get_tree().create_tween()
		ttween.tween_property(timeGroup, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_IN)
		ttween.tween_property(timeGroup, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
