extends Node3D

@export var StartUI: Node
@export var GameUI: Node
@export var timeGroup: Node
@export var time: Label
@export var damageGroup: Node
@export var damageLabel: Label
@export var TuggedBoat: OceanLiner
@export var Goal_: Goal

@export var EndUI: Node
@export var PayoutBase: Label
@export var PayoutBonus: Label
@export var PayoutDamage: Label
@export var PayoutTotal: Label
@export var PressAnyKeyToRestart: Label

@export var Go: AudioStream
@export var Congrats: AudioStream

var paused = true
var started = false
var gameover = false
var timeElapsed = 0
var damage = 0
var basePay = 100
var basePayDisplay = -1
var timeBonus = 120
var timeBonusDisplay = -1
var damagesDisplay = -1
var total = 0
var totalDisplay = -1
var totalDisplayDelay = 0
var counting = false
var canRestart = false
var damageIncrease = 1

func _ready():
	TuggedBoat.connect("on_collision", on_tuggedboat_collision)
	Goal_.connect("on_goal_reached", on_goal_reached)
	var damageUI = GameUI.get_child(0)

func _process(delta):
	if not paused:
		timeElapsed += delta
		time.text = "%d:%02d" % [floor(timeElapsed) / 60, fmod(timeElapsed, 60)]
	
	if counting:
		if basePayDisplay < basePay:
			basePayDisplay += 1
			PayoutBase.text = "$%s" % basePayDisplay
			PayoutBase.label_settings.font_color = Color.SEA_GREEN
			if not ($PayoutAudio as AudioStreamPlayer).playing:
				($PayoutAudio as AudioStreamPlayer).pitch_scale = 1 + (float(basePayDisplay) / float(basePay))
				($PayoutAudio as AudioStreamPlayer).play()
		elif timeBonusDisplay < timeBonus:
			timeBonusDisplay += 1
			PayoutBonus.text = "$%s" % timeBonusDisplay
			PayoutBonus.label_settings.font_color = Color.SEA_GREEN
			if not ($PayoutAudio as AudioStreamPlayer).playing:
				($PayoutAudio as AudioStreamPlayer).pitch_scale = 1 + (float(timeBonusDisplay) / float(timeBonus))
				($PayoutAudio as AudioStreamPlayer).play()
		elif damagesDisplay < damage:
			if damagesDisplay > 10000:
				damageIncrease = 100
			elif damagesDisplay > 100:
				damageIncrease = 10
			else:
				damageIncrease = 1
			damagesDisplay += damageIncrease
			PayoutDamage.text = "$%s" % mini(damagesDisplay, damage)
			PayoutDamage.label_settings.font_color = Color.FIREBRICK
			if not ($PayoutAudio as AudioStreamPlayer).playing:
				($PayoutAudio as AudioStreamPlayer).pitch_scale = 1 - (float(damagesDisplay) / float(damage))
				($PayoutAudio as AudioStreamPlayer).play()
		elif totalDisplay < totalDisplayDelay:
			totalDisplay += delta
		else:
			var payoutTemplate = "$%s" if total > 0 else "-$%s"
			PayoutTotal.text = payoutTemplate % absi(total)
			if total < 0:
				PayoutTotal.label_settings.font_color = Color.FIREBRICK
			else:
				PayoutTotal.label_settings.font_color = Color.SEA_GREEN
			counting = false
			canRestart = true
			($VoicePlayer as AudioStreamPlayer).stream = Congrats
			($VoicePlayer as AudioStreamPlayer).play()
			PressAnyKeyToRestart.show()

func on_tuggedboat_collision():
	damage += randi_range(950, 2500)
	if not damageGroup.visible:
		damageGroup.show()
		var dtween = get_tree().create_tween()
		dtween.tween_property(damageGroup, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_IN)
		dtween.tween_property(damageGroup, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
	damageLabel.text = "$%s" % damage
	
func on_goal_reached():
	if not gameover:
		gameover = true
		paused = true
		GameUI.hide()
		for child in get_children():
			if child is RigidBody3D:
				child.freeze = true
		counting = true
		timeBonus = maxi(0, timeBonus - floor(timeElapsed)) * 10
		total = basePay + timeBonus - damage
		EndUI.show()
		($MusicPlayer as AudioStreamPlayer).stop()
		$Tugboat/MotorPlayer.stop()

func _input(event):
	if not (event is InputEventKey and event.pressed):
		return
	if not started:
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
		($VoicePlayer as AudioStreamPlayer).play()
	elif canRestart:
		get_tree().reload_current_scene()

func _on_music_player_finished():
	$MusicPlayer.play()
