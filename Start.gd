extends Node2D

onready var timer1 = get_node("Timer")

signal timer_end

func _ready():
	$CanvasLayer/AnimationPlayer.play("dip_to_normal")
	yield($CanvasLayer/AnimationPlayer, "animation_finished")
	
	$AnimatedSprite.play("load")
	
	run_timer(3)
	yield(self, "timer_end")
	
	$CanvasLayer/AnimationPlayer.play("dip_to_black")
	yield($CanvasLayer/AnimationPlayer, "animation_finished")
	
	get_tree().change_scene("res://Player.tscn")

func _create_timer(time):
	timer1.set_timer_process_mode(0)
	timer1.set_wait_time(time)
	timer1.connect("timeout", self, "_emit_timer_end_signal")
	timer1.start()

func run_timer(seconds):
	_create_timer(seconds)

func _emit_timer_end_signal():
	emit_signal("timer_end")
