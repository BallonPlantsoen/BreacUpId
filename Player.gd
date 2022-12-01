extends Node2D

# Summary
# This script contains the main loop of the program
 
#Player variables
var deck = []
var hand = []
var discard = []
var board = []

#The active customer
var currCustomer
var lineOfCustomers = []

#Places where the cards on the board are
var boardPos = [Vector2(-200, 350), Vector2(0, 350), Vector2(200, 350)]

#We will use this to open the tutorial once at start
var hasHadTutorial = false 
var canPlay = false
var isUpgrading = false

#Load templates
onready var cardTemplate = load("res://Card.tscn")
onready var customerTemplate = load("res://Customer.tscn")
onready var iconTemplate = load("res://IconBonus.tscn")



#On start load the scene; if hasHadTutorial, play the game. Otherwise open tut.
func _ready():
	if hasHadTutorial == false:
		$AnimationPlayer.play("Zoom_out")
		yield($AnimationPlayer, "animation_finished")
		$Label.show()
		$Label2.show()
		yield($Button, "button_up")
		$Label.hide()
		$Label2.hide()
		$Label5.show()
		$Label6.show()
		yield($Button, "button_up")
		$Label5.hide()
		$Label6.hide()
		$Label3.show()
		$Label4.show()
		yield($Button, "button_up")
		$Label3.hide()
		$Label4.hide()
		$Button.hide()
		$ColorRect.hide()
		hasHadTutorial = true
		$HELP.show()
	
	randomize()
	
	#Generate a deck op 20 Level1 cards
	for i in range(20):
		var card = cardTemplate.instance()
		card.shape = Globals.shapes.keys()[randi() % 3]
		card.rarity = 0
		card.points = randi()%2
		card.get_node("LabelText").text = Globals.text[(str(card.shape) + str(card.points))]
		deck.append(card)
		card.updateCard()
	deck.shuffle()
	
	
	#make customers
	for i in range(4):
		newCustomer()
	
	updateScores()
	
	#zoom in
	$AnimationPlayer.play("Zoom_in")
	yield($AnimationPlayer, "animation_finished")
	
	for i in range(5):
		drawCard()
	
	$HELP.show()

func drawCard():
	canPlay = false
	if len(deck) == 0:
		deck = discard
		discard = []
		deck.shuffle()
	var decksize = len(deck)
	var card = deck[randi()%decksize]
	
	hand.append(card)
	deck.erase(card)
	$HandContainer.add_child(card)
	updateHand()
	checkForUpgrades()

func checkForUpgrades():
	if len(board) != 3 and isUpgrading == false:
		var foundUpgrade = false
		for i in hand:
			var count = []
			count.append(i)
			for j in hand:
				if (i!=j and i.shape == j.shape and i.points == j.points and len(count) < 3):
					count.append(j)
			if len(count) == 3:
				isUpgrading = true
				foundUpgrade = true
				count[1].get_node("Sprite").material.set_shader_param("width", 10.0)
				count[2].get_node("Sprite").material.set_shader_param("width", 10.0)
				i.get_node("Sprite").material.set_shader_param("width", 10.0)
				
				$AnimationPlayer.play("Upgrade!")
				yield($AnimationPlayer, "animation_finished")
				
				hand.erase(count[1])
				hand.erase(count[2])
				hand.erase(i)
				
				$HandContainer.remove_child(count[1])
				$HandContainer.remove_child(count[2])
				$HandContainer.remove_child(i)
				
				$AnimationPlayer.play("Zoom_out")
				yield($AnimationPlayer, "animation_finished")
				$Upgrade.percent_visible = 0.0
				upgradeCard(i.rarity)
				
				break
		
		if foundUpgrade == false:
			canPlay = true

#This is called from Bonus (passive) effects
func addBonus(name, texture, text):
	Globals.bonuses[name] += 1
	Globals.difficulty += 1
	
	#add the icon to the grid
	var newIcon = iconTemplate.instance()
	newIcon.iconName = text
	newIcon.get_node("Sprite").set_texture(texture)
	newIcon.position.y += floor($PassiveContainer.get_child_count() / 5) * -50 
	newIcon.position.x += ($PassiveContainer.get_child_count() % 5 - 1) * -50
	$PassiveContainer.add_child(newIcon)
	
	for i in hand:
		i.canClick = true
	
	for i in $UpgradeUI/UpgradeContainer.get_children():
		$UpgradeUI/UpgradeContainer.remove_child(i)
	
	updateHand()
	checkForUpgrades()

#This is called from a card, when the card is played from hand
func addToBoard(card):
	$HELP.hide()
	if hand.has(card):
		#Set isBoarded, so that it cannot be clicked or highlighted
		card.isBoarded = true
		
		#Calculate points
		var scoredPoints = calculatePoints(card)
		Globals.cusPoints += scoredPoints + card.points
		
		#Add camera trauma based on the points?
		print(scoredPoints)
		$Camera2D.add_trauma( .2 + float(scoredPoints) / 10.0)
		
		#Add card to board and update containers
		card.get_node("Sprite").material.set_shader_param("width", 0)
		hand.erase(card)
		board.append(card)
		$HandContainer.remove_child(card)
		$BoardContainer.add_child(card)
		updateBoard()
		drawCard()
		updateHand()
	
	if len(board) == 3:
		for i in hand:
			i.canClick = false
		if calculateBonuses() == false:
			Globals.levels -= 1
			if Globals.levels == -1:
				get_tree().quit()
			else:
				$Score.fail()
				yield($Score, "timer_end")
		
		if randi()%15 == 3:
			Globals.bonuses["%bons"] += 1
			Globals.difficulty += 1
		
		
		#empty the board
		for i in board:
			discard.append(i)
		for i in board:
			$BoardContainer.remove_child(i)
		board = []
		
		#add points to total
		Globals.totalPoints += Globals.cusPoints
		Globals.cusPoints = 0
		
		if Globals.totalPoints > 10:
			if Globals.totalPoints < 15:
				Globals.bonuses["%bons"] = 8
			else:
				Globals.bonuses["%bons"] = 3
		
		currCustomer.leaveRoom()
		newCustomer()
		
		updateBoard()
		$BoardContainer.hide()
		$HandContainer.hide()
		$AnimationPlayer.play("Zoom_out")
		yield($AnimationPlayer, "animation_finished")
		
		$UpgradeUI.isCustomerUpgrade = true
		$UpgradeUI.generateCustomerUpgrade()
		move_child($UpgradeUI, get_child_count())
		$UpgradeUI.show()
	updateScores()

func calculatePoints(card):
	#Calculate the scored points, including all bonuses
	var scoredPoints = 0
	
	var shape = card.shape
	var points = card.points
	
	#Shape bonus
	if currCustomer.bonus == shape:
		scoredPoints += Globals.bonuses["bonus"]
	
	#3 different types
	if len(board) == 2 and Globals.bonuses["3diff"] == 1:
		if board[0].shape != shape and board[1].shape != shape:
			scoredPoints += 5
	
	#3 identical types
	if len(board) == 2:
		if board[0].shape == shape and board[1].shape == shape:
			if Globals.bonuses["3call"] == 1 and str(shape) == "CALL":
				scoredPoints += 5
			if Globals.bonuses["3pers"] == 1 and str(shape) == "PERSON":
				scoredPoints += 5
			if Globals.bonuses["3text"] == 1 and str(shape) == "TEXT":
				scoredPoints += 5
	
	#Contains a word
	if Globals.bonuses["cont1"]:
		if "friend" in card.get_node("LabelText").text:
			scoredPoints += 2
	
	return scoredPoints


func calculateBonuses():
	#Calculates if this level was completed
	
	#If points <= 2 bonus
	if Globals.bonuses["totp2"] == 1:
		if Globals.cusPoints <= 2:
			return true
	
	#If points == 5 bonus
	if Globals.bonuses["totp5"] == 1:
		if Globals.cusPoints == 5:
			return true
	
	#Then if point goal is made
	if Globals.cusPoints >= currCustomer.points:
		return true
	else:
		return false

func updateScores():
	$TotalScore.text = str(Globals.totalPoints)
	$CurScore.text = str(Globals.cusPoints)

func upgradeCard(rarity):
	#give UI choice of 3 things
	$BoardContainer.hide()
	$HandContainer.hide()
	$UpgradeUI.isCustomerUpgrade = false
	move_child($UpgradeUI, get_child_count())
	$UpgradeUI.generateUpgrade(rarity)
	$UpgradeUI.show()

func updateBoard():
	for i in len(board):
		board[i].position = boardPos[i]
	
	canPlay = true

func updateHand():
	for i in len(hand):
		hand[i].show()
		hand[i].position = Vector2(0 - ((len(hand)-1) * 100) + i * 200, 570)

func newCustomer():
	if (len(lineOfCustomers) >= 3):
		currCustomer = lineOfCustomers[0]
		lineOfCustomers[0].enterRoom()
	var newCustomer = customerTemplate.instance()
	add_child(newCustomer)
	lineOfCustomers.append(newCustomer)
	
	for i in len(lineOfCustomers):
		if i != 0:
			lineOfCustomers[i].global_position = Vector2(1750, 1600.0 - (400 * i))
			lineOfCustomers[i].get_node("Path2D/PathFollow2D/Area2D").rotation_degrees = 180

func _on_Area2D_area_entered(area):
	print(area.get_parent())
	if "PathFollow" in area.get_parent().name:
		$Area2D/AnimationPlayer.play("Door_open")

func _on_Area2D_area_exited(area):
	if "PathFollow" in area.get_parent().name:
		$Area2D/AnimationPlayer.play("Door_close")



func _on_QuestionMark_mouse_entered():
	move_child($HELP, len(get_children()))
	$HELP.show()
	$QuestionMark/AnimationPlayer.play("Wiggle")

func _on_QuestionMark_mouse_exited():
	$HELP.hide()
	$QuestionMark/AnimationPlayer.stop()
	$QuestionMark/Sprite.rotation_degrees = 0
	$QuestionMark/Sprite.scale = Vector2(0.5, 0.5)



func _on_Quit_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released("click"):
		get_tree().quit()




func _on_Quit_mouse_entered():
	$Quit/AnimationPlayer.play("Wiggle")

func _on_Quit_mouse_exited():
	$Quit/AnimationPlayer.stop()
	$Quit/Sprite.rotation_degrees = 0
	$Quit/Sprite.scale = Vector2(0.5, 0.5)
