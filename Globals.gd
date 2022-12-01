extends Node

enum shapes {TEXT, PERSON, CALL, NULL}

#Data tree for bonuses
var bonuses = {
	"3diff" : 0,
	"3call" : 0,
	"3pers" : 0,
	"3text" : 0,
	"cont1" : 0,
	"totp2" : 0,
	"totp5" : 0,
	"bonus" : 1,
	"%racc" : 0,
	"%bons" : 0
	}

var totalPoints = 0
var cusPoints = 0
var levels = 3
var difficulty = 0

var text = {
	"CALL0": "I just\ndon't feel that spark", 
	"CALL1": "I need\nsome space",
	"CALL2": "Let's take\na break",
	"CALL3": "Things\nhappen for a reason", 
	"CALL4": "We need\nto talk",
	"CALL5": "You'll\nfind someone soon",
	"CALL6": "We are\ntoo young",
	"CALL7": "There are\nplenty fish in the sea", 
	"CALL8": "We are\nlooking for different things",
	"CALL9": "You're\nbetter off without me",
	"PERSON0": "I just\ndon't feel that spark", 
	"PERSON1": "We need\nto talk",
	"PERSON2": "It's not\nyou its me",
	"PERSON3": "I'm\nnot good enough for you", 
	"PERSON4": "Let's stay\nfriends",
	"PERSON5": "You'll\nfind someone soon",
	"PERSON6": "There are\nplenty fish in the sea",
	"PERSON7": "Things\nhappen for a reason", 
	"PERSON8": "We need\nto talk",
	"PERSON9": "I need\nsome space",
	"TEXT0": "I need\nto focus on my career", 
	"TEXT1": "We are\ntoo young", 
	"TEXT2": "I am\nnot ready for a commitment",
	"TEXT3": "I love you\nbut I'm not in love",
	"TEXT4": "We need\nto talk",
	"TEXT5": "Let's stay\nfriends",
	"TEXT6": "If only\nwe met in five years",
	"TEXT7": "You'll\nfind someone soon",
	"TEXT8": "We are\nlooking for different things",
	"TEXT9": "I just\ndon't feel that spark", 
	}
