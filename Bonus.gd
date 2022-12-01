extends Area2D

var bonusName = "bonus"

onready var friendzoneIcon = load("res://art/FriendzoneIcon.png")
onready var fiveIcon = load("res://art/FiveRed.png")
onready var twoIcon = load("res://art/TwoRed.png")
onready var faceTimeIcon = load("res://art/IconFaceTimeRed.png")
onready var phoneIcon = load("res://art/IconPhoneRed.png")
onready var speechIcon = load("res://art/IconSpeechRed.png")
onready var levelUpIcon = load("res://art/LevelUpRed.png")
onready var threeIcon = load("res://art/ThreeOfAKindRed.png")


var bonusTypes = {
	"3diff" : ["Three of a Kind!","When you have 3 different bonuses, gain +5 points"],
	"3call" : ["Good call!","When you have 3 CALL-bonuses, gain +5 points"],
	"3pers" : ["All talk, no action","When you have 3 PERSON-bonuses, gain +5 points"],
	"3text" : ["Message in a Bottle","When you have 3 TEXT-bonuses, gain +5 points"],
	"cont1" : ["The Friendzone","Cards with the text 'Friend' in it, have +2"],
	"totp2" : ["Close call","When your rounds points are equal to 2, win the round"],
	"totp5" : ["Take five!","When your rounds points are equal to 5, win the round"],
	"bonus" : ["Level up!","Bonus shapes give +1 more bonus points"],
	"%racc" : ["A rare sight!","Customers have increased chance to give rarer cards"],
	"%bons" : ["Home improvements","You have a higher chance to get bonuses"]
	}

func _ready():
	$Explosion.restart()
	$LabelText.text = bonusTypes[bonusName][1]
	$LabelName.text = bonusTypes[bonusName][0]
	
	if bonusName == "cont1":
		$Icon.set_texture(friendzoneIcon)
	elif bonusName == "3diff":
		$Icon.set_texture(threeIcon)
	elif bonusName == "3call":
		$Icon.set_texture(faceTimeIcon)
	elif bonusName == "3pers":
		$Icon.set_texture(speechIcon)
	elif bonusName == "3text":
		$Icon.set_texture(phoneIcon)
	elif bonusName == "totp2":
		$Icon.set_texture(twoIcon)
	elif bonusName == "totp5":
		$Icon.set_texture(fiveIcon)
	elif bonusName == "bonus":
		$Icon.set_texture(levelUpIcon)
	elif bonusName == "%racc":
		$Icon.set_texture(levelUpIcon)
	elif bonusName == "%bons":
		$Icon.set_texture(levelUpIcon)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released("click"):
		get_parent().get_parent().hide()
		get_tree().root.get_node("Player/AnimationPlayer").play("Zoom_in")
		yield(get_tree().root.get_node("Player/AnimationPlayer"), "animation_finished")
		get_tree().root.get_node("Player/BoardContainer").show()
		get_tree().root.get_node("Player/HandContainer").show()
		get_tree().root.get_node("Player").addBonus(bonusName, $Icon.texture, $LabelText.text)

func applyData():
	pass


func _on_Area2D_mouse_entered():
	$AnimationPlayer.play("Wiggle_BIG")
	$Explosion.restart()


func _on_Area2D_mouse_exited():
	$AnimationPlayer.stop()
	self.rotation = 0
	self.scale = Vector2(4,4)
