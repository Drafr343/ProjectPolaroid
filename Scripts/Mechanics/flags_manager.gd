extends Node

var hasMotelKey = false
var hasMooseCoin = false

func GiveMotelKey():
	hasMotelKey = true;
	print("The player now has the motel key")

func HasMotelKey():
	return hasMotelKey

func GiveMooseCoin():
	hasMooseCoin = true;
	print("The player now has the moose coin")

func HasMooseCoin():
	return hasMooseCoin
