extends Label

var tween 

func _ready():
	tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "rotation_degrees", 5, 1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", -5, 1).set_ease(Tween.EASE_IN_OUT)
