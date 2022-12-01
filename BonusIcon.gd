extends Area2D

var iconName = ""

func _on_Area2D_mouse_entered():
	get_parent().get_node("IconText").text = iconName
	
func _on_Area2D_mouse_exited():
	get_parent().get_node("IconText").text = ""
