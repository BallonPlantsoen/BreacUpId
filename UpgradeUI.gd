extends Node2D

onready var cardTemplate = load("res://Card.tscn")

var shownCards = []
var boardPos = [Vector2(1000, 950), Vector2(1800, 950), Vector2(2600, 950)]

onready var border1 = load("res://art/Border.png")
onready var border2 = load("res://art/Border2.png")
onready var border3 = load("res://art/Border3.png")

onready var bonusTemplate = load("res://Bonus.tscn")


onready var isCustomerUpgrade : bool = true

func generateCustomerUpgrade():
	#For internal use:
	isCustomerUpgrade = true
	$Label.text = "New card!"
	
	#Setup the decklist at call
	updateDeckList("CALL")
	
	#Bonuses will pop up randomly, based on the extra score above the target
	if Globals.totalPoints > 1:
		#10% + 10% for each bonus taken
		var baseChance = 1 + Globals.bonuses["%bons"]
		if randi() % 8 < baseChance:
			var bonusCard = bonusTemplate.instance()
			var listOfBonuses = ["bonus", "%racc", "%bons"]
			for i in Globals.bonuses:
				if listOfBonuses.has(i) == false:
					if Globals.bonuses[i] == 0:
						listOfBonuses.append(i)
			bonusCard.bonusName = listOfBonuses[randi() % listOfBonuses.size()]
			bonusCard.applyData()
			bonusCard.scale = Vector2(4,4)
			shownCards.append(bonusCard)
			$UpgradeContainer.add_child(bonusCard)
	
	
	#Generate 3 cards
	for i in range(3 - len($UpgradeContainer.get_children())):
		var card = cardTemplate.instance()
		card.rarity = 0
		card.points = randi()%3
		if randi()%8 < Globals.bonuses["%racc"]:
			card.rarity = 1
			card.points = int(rand_range(3,5))
		card.shape = Globals.shapes.keys()[randi() % 3]
		card.scale = Vector2(4,4)
		card.isUpgrade = true
		shownCards.append(card)
		card.get_node("LabelText").text = Globals.text[(str(card.shape) + str(card.points))]
		$UpgradeContainer.add_child(card)
	for i in len(shownCards):
		shownCards[i].position = boardPos[i]
	shownCards = []
	get_tree().root.get_node("Player").canPlay = true

func generateUpgrade(rarity):
	isCustomerUpgrade = false
	$Label.text = "Upgrade!"
	updateDeckList("CALL")
	for i in range(3):
		var card = cardTemplate.instance()
		card.rarity = rarity + 1
		card.points = int(rand_range(3 * (rarity+1), 3*(rarity+1) + 2))
		card.shape = Globals.shapes.keys()[randi() % 3]
		card.scale = Vector2(4,4)
		card.isUpgrade = true
		card.get_node("LabelText").text = Globals.text[(str(card.shape) + str(card.points))]
		shownCards.append(card)
		$UpgradeContainer.add_child(card)
	for i in len(shownCards):
		shownCards[i].position = boardPos[i]
	shownCards = []
	get_tree().root.get_node("Player").canPlay = true

func updateDeckList(type):
	$Values02.text = "$0$\n$1$\n$2$"
	$Values03.text = "$3$\n$4$\n$5$"
	$Values04.text = "$6$\n$7$\n$8$"
	var cardList = []
	var a = [0,0,0,0,0,0,0,0,0,0]
	for i in get_tree().root.get_node("Player").deck: cardList.append(i)
	for i in get_tree().root.get_node("Player").hand: cardList.append(i)
	for i in get_tree().root.get_node("Player").discard: cardList.append(i)
	for i in cardList:
		if str(i.shape) == type:
			a[i.points] += 1
	
	var cc = 0
	for i in a:
		if cc <= 2:
			$Values02.text = $Values02.text.replace("$"+str(cc)+"$", str(i) + "x")
		elif cc > 2 and cc < 6:
			$Values03.text = $Values03.text.replace("$"+str(cc)+"$", str(i) + "x")
		elif cc > 5:
			$Values04.text = $Values04.text.replace("$"+str(cc)+"$", str(i) + "x")
		cc+=1
	
	if type == "CALL":
		$Border.set_texture(border3)
	elif type == "PERSON":
		$Border.set_texture(border2)
	elif type == "TEXT":
		$Border.set_texture(border1)


func addToBoard(card):
	card.isUpgrade = false
	var newcard = cardTemplate.instance()
	newcard.shape = card.shape
	newcard.rarity = card.rarity
	newcard.points = card.points
	newcard.get_node("LabelText").text = card.get_node("LabelText").text
	newcard.updateCard()
	shownCards = []
	if isCustomerUpgrade:
		self.hide()
		get_parent().get_node("AnimationPlayer").play("Zoom_in")
		yield(get_parent().get_node("AnimationPlayer"), "animation_finished")
		get_parent().deck.append(newcard)
		get_parent().deck.shuffle()
		get_parent().updateHand()
		newcard.isUpgrade = false
		get_parent().checkForUpgrades()
	else:
		self.hide()
		get_parent().get_node("AnimationPlayer").play("Zoom_in")
		yield(get_parent().get_node("AnimationPlayer"), "animation_finished")
		#get_parent().hand.append(card)
		get_parent().deck.push_front(newcard)
		for i in get_parent().deck:
			print(i.shape, i.points)
		get_parent().drawCard()
		get_parent().drawCard()
		get_parent().drawCard()
		#get_parent().get_node("HandContainer").add_child(card)
		get_parent().updateHand()
		newcard.isUpgrade = false
	
	for i in get_parent().hand:
		i.canClick = true
	
	get_parent().get_node("BoardContainer").show()
	get_parent().get_node("HandContainer").show()
	for i in $UpgradeContainer.get_children():
		$UpgradeContainer.remove_child(i)
	
	get_parent().canPlay = true
	get_parent().isUpgrading = false


func _on_FaceTimeMenu_mouse_entered():
	updateDeckList("CALL")
	

func _on_SpeechMenu_mouse_entered():
	updateDeckList("PERSON")

func _on_PhoneMenu_mouse_entered():
	updateDeckList("TEXT")


