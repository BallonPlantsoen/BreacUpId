extends Node2D

var points = 0
var bonus = Globals.shapes.NULL

var walking = false

onready var iconPhone = load("res://art/IconPhone.png")
onready var iconSpeech = load("res://art/IconSpeech.png")
onready var iconFT = load("res://art/IconFaceTime.png")

func _ready():
	self.global_position.x = 1750.0
	self.global_position.y = 800

func updateCustomer():
	$Path2D/PathFollow2D/Area2D/Label.text = str(points)
	if bonus == "TEXT":
		$Path2D/PathFollow2D/Area2D/Sprite2.set_texture(iconPhone)
	elif bonus == "PERSON":
		$Path2D/PathFollow2D/Area2D/Sprite2.set_texture(iconSpeech)
	elif bonus == "CALL":
		$Path2D/PathFollow2D/Area2D/Sprite2.set_texture(iconFT)
	
func leaveRoom():
	get_parent().lineOfCustomers.pop_at(0)
	queue_free()

func enterRoom():
	randomize()
	##rewrite points & bonus selection
	var optimalShapeBonus = 0
	var deck = []
	for i in get_parent().deck:
		deck.append(i)
	for i in get_parent().hand:
		deck.append(i)
	
	var shapeList = [0,0,0]
	if len(deck) > 14:
		bonus = Globals.shapes.keys()[randi() % 3]
		print("Customer with random bonus of " + str(bonus))
	else:
		for i in deck:
			if i.shape == "TEXT":
				shapeList[0] += 1
			elif i.shape == "PERSON":
				shapeList[1] += 1
			elif i.shape == "CALL":
				shapeList[2] += 1
		bonus = Globals.shapes.keys()[shapeList.find(shapeList.max())]
		optimalShapeBonus += 1
		print("Customer with chosen bonus of " + str(bonus))
	
	var listOfPoints = []
	for i in get_parent().hand:
		var points = i.points
		if i.shape == bonus:
			points += Globals.bonuses["bonus"]
		listOfPoints.append(points)
	var cc = 0
	for i in range(len(get_parent().deck)-1):
		if cc > 5:
			break
		cc+=1
		var points = get_parent().deck[i].points
		if get_parent().deck[i].shape == bonus:
			points += Globals.bonuses["bonus"]
		listOfPoints.append(points)
	print("LOP:", listOfPoints)
	
	var tot = 0 
	for i in listOfPoints:
		tot += i
	var avg = floor(tot/len(listOfPoints))
	
	#get minimum
	listOfPoints.sort()
	var minimum = 2
	for i in range(3):
		minimum += listOfPoints[i]
	
	#Get maximum
	var maximum = 0
	for i in range(-1, -4, -1):
		maximum += listOfPoints[i]
	
	#Based on difficulty
	print(avg, minimum, maximum)
	
	minimum += Globals.difficulty + optimalShapeBonus
	var finalmax = abs(avg - maximum) + Globals.difficulty + optimalShapeBonus
	
	points = int(rand_range(minimum, finalmax))
	
	updateCustomer()
	
	self.global_position.x = 1750.0
	self.global_position.y = 800
	$Path2D/PathFollow2D/Area2D.rotation_degrees = -90
	
	$Path2D.curve = Curve2D.new()
	$Path2D.curve.add_point(Vector2(000, 000), Vector2(-0, 0), Vector2(0, 0))
	$Path2D.curve.add_point(Vector2(000, -1500), Vector2(-50, 50), Vector2(-100, 50))
	$Path2D.curve.add_point(Vector2(-1750, -1550), Vector2(100, -100), Vector2(-50, 50))
	$Path2D.curve.add_point(Vector2(-1750, -820))
	
	#Walk to 0.0
	walking = true
	$Path2D/PathFollow2D/Area2D/Tween.interpolate_property($Path2D/PathFollow2D, "offset", 0.0, 
		$Path2D.curve.get_baked_length(), 4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Path2D/PathFollow2D/Area2D/Tween.start()
	yield($Path2D/PathFollow2D/Area2D/Tween, "tween_completed")
	
	updateCustomer()
	
	$Path2D/PathFollow2D/Area2D/AnimationPlayer.play("Popbubble")
	$Path2D/PathFollow2D/Area2D/IconSpeech.show()
	$Path2D/PathFollow2D/Area2D/Sprite2.modulate = Color(1,1,1,0)
	$Path2D/PathFollow2D/Area2D/Sprite2.show()
	$Path2D/PathFollow2D/Area2D/Label.modulate = Color(1,1,1,0)
	$Path2D/PathFollow2D/Area2D/Label.show()
	yield($Path2D/PathFollow2D/Area2D/AnimationPlayer, "animation_finished")
