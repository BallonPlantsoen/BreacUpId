extends Area2D


var shape = Globals.shapes.NULL
var rarity = 0
var points = 0

var startScale = Vector2(0.9, 0.9)

var canClick = true
var isUpgrade = false
var isBoarded = false


onready var cardFTtext = load("res://art/CardFaceTimer.png")
onready var cardSPtext = load("res://art/CardSpeech.png")
onready var cardTXtext = load("res://art/CardText.png")

func _ready():
	updateCard()

func updateCard():
	$LabelValue.text = str(points)
	match rarity:
		0:
			$LabelRarity.text = "normal"
		1:
			$LabelRarity.text = "rare"
		2:
			$LabelRarity.text = "legendary"
	match shape:
		"TEXT":
			$Sprite.texture = cardTXtext
		"CALL":
			$Sprite.texture = cardFTtext
		"PERSON":
			$Sprite.texture = cardSPtext

func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released("click") and canClick and get_tree().root.get_node("Player").canPlay:
		self.scale = Vector2(0.9, 0.9)
		self.startScale = Vector2(0.9, 0.9)
		get_parent().get_parent().addToBoard(self)

func _on_Area2D_mouse_entered():
	startScale = self.scale
	if isUpgrade == false and isBoarded == false:
		for i in get_tree().root.get_node("Player").hand:
			if (i != self and i.shape == shape and i.points == points):
				i.get_node("Sprite").material.set_shader_param("width", 10.0)
				$Sprite.material.set_shader_param("width", 10.0)
	elif (isUpgrade):
		var parent = get_parent().get_parent()
		match shape:
			"CALL":
				parent.updateDeckList("CALL")
			"PERSON":
				parent.updateDeckList("PERSON")
			"TEXT":
				parent.updateDeckList("TEXT")
	if startScale.x > 1.5:
		$AnimationPlayer.play("Wiggle_BIG")
	else:
		$AnimationPlayer.play("Wiggle")
	var newPoints = points
	var bonuses = get_tree().root.get_node("Player").calculatePoints(self)
	get_tree().root.get_node("Player/CurScore").text += "+" + str(newPoints)
	if bonuses != 0:
		get_tree().root.get_node("Player/BonusScore").text += "+" + str(bonuses)

func _on_Area2D_mouse_exited():
	self.rotation = 0
	self.scale = startScale
	if self.is_inside_tree():
		var newtext = get_tree().root.get_node("Player/CurScore").text
		newtext = newtext.split('+')[0]
		get_tree().root.get_node("Player/CurScore").text = newtext
		for i in get_tree().root.get_node("Player").hand:
			i.get_node("Sprite").material.set_shader_param("width", 0.0)
		get_tree().root.get_node("Player/BonusScore").text = ""
	$AnimationPlayer.stop()
