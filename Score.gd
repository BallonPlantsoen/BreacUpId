extends Node2D

onready var timer1 = get_node("Timer")
onready var text = load("res://FloatingText.tscn")

signal timer_end

func fail():
	if Globals.levels == 2:
		get_parent().get_node("Camera2D").add_trauma(.3)
		$Sprite4.hide()
		$Explosion.restart()
	elif Globals.levels == 1:
		get_parent().get_node("Camera2D").add_trauma(.3)
		$Sprite5.hide()
		$Explosion2.restart()
	elif Globals.levels == 0:
		get_parent().get_node("Camera2D").add_trauma(.3)
		$Sprite6.hide()
		$Explosion3.restart()
	run_timer(1)

func _create_timer(time):
	timer1.set_timer_process_mode(0)
	timer1.set_wait_time(time)
	timer1.connect("timeout", self, "_emit_timer_end_signal")
	timer1.start()

func run_timer(seconds):
	_create_timer(seconds)

func _emit_timer_end_signal():
	emit_signal("timer_end")
