extends Position2D

var string = ""
var speed = 1
var initScale = Vector2(1,1)

func _ready(): 
	$Label.text = string
	
	$Tween.interpolate_property(self, 'scale', scale, initScale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(self, 'scale', initScale, Vector2(0.1,0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(self, 'position', position, position - Vector2(50,50), (0.7 * speed), Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	

func _on_Tween_tween_all_completed():
	self.queue_free()
