extends Node2D

var board = [
	[["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""]],
	[["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""]],
	[["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""]],
	[["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""]],
	[["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""]],
	[["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""]],
	[["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""]],
	[["w",""],["b",""],["w",""],["b",""],["w",""],["b",""],["w",""],["b",""]],
	
]

var guiBoard = []
# Called when the node enters the scene tree for the first time.
func _ready():
	#not working yet, need to check how to bind it
	guiBoard = [
	[[$Background/a8/Label],[$Background/a7/Label],[$Background/a6/Label],[$Background/a5/Label],[$Background/a4/Label],[$Background/a3/Label],[$Background/a2/Label],[$Background/a1/Label]],
	[[$Background/b8/Label],[$Background/b7/Label],[$Background/b6/Label],[$Background/b5/Label],[$Background/b4/Label],[$Background/b3/Label],[$Background/b2/Label],[$Background/b1/Label]],
	[[$Background/c8/Label],[$Background/c7/Label],[$Background/c6/Label],[$Background/c5/Label],[$Background/c4/Label],[$Background/c3/Label],[$Background/c2/Label],[$Background/c1/Label]],
	[[$Background/d8/Label],[$Background/d7/Label],[$Background/d6/Label],[$Background/d5/Label],[$Background/d4/Label],[$Background/d3/Label],[$Background/d2/Label],[$Background/d1/Label]],
	[[$Background/e8/Label],[$Background/e7/Label],[$Background/e6/Label],[$Background/e5/Label],[$Background/e4/Label],[$Background/e3/Label],[$Background/e2/Label],[$Background/e1/Label]],
	[[$Background/f8/Label],[$Background/f7/Label],[$Background/f6/Label],[$Background/f5/Label],[$Background/f4/Label],[$Background/f3/Label],[$Background/f2/Label],[$Background/f1/Label]],
	[[$Background/g8/Label],[$Background/g7/Label],[$Background/g6/Label],[$Background/g5/Label],[$Background/g4/Label],[$Background/g3/Label],[$Background/g2/Label],[$Background/g1/Label]],
	[[$Background/h8/Label],[$Background/h7/Label],[$Background/h6/Label],[$Background/h5/Label],[$Background/h4/Label],[$Background/h3/Label],[$Background/h2/Label],[$Background/h1/Label]]	
	]
	guiBoard[0][0] = "works"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FENLineEdit_text_changed(new_text):
	var fen = new_text
	val(fen)
	pass # Replace with function body.

func val(fen):
	$ValidateLabel.text = str(fen.find('/'))
	#dodać walidację liczenia backslashy i spacji z trymowaniem
	var isValid = false
	var fenArr = fen.split("/", true, 0)
	var lastCell = fenArr[-1]
	fenArr.remove(fenArr.size()-1)
	fenArr += lastCell.split(" ", true, 0)
	#print_debug(fenArr)
	#print_debug(len(fenArr))
	
	# if the length is right the notation has 
	# the right amount of segments
	if len(fenArr) == 13:
		for i in range(8):
			var line = fenArr[i].split("", true, 0)
			var col = 0
			for j in line:
				for k in j:
					print_debug("k: ",k)
					print_debug("col: ",col)
					if isNumber(k):
						print_debug(k)
						print_debug(typeof(k))
						for g in range(int(k)):
							board[i][col][1] = ""
							col += 1
					else:
						board[i][col][1] = k
						col += 1
					
	for i in range(len(board)):
		print_debug(board[i])
	setBoard()

func isNumber(i):
	var isnumber = false
	for j in "12345678":
		if j == i:
			isnumber = true
	return isnumber

func isChess(n):
	for j in "rnbqkpRNBQKP12345678":
		if j == n:
			return true
	return false
	
func isMove(n):
	var ismove = false
	for j in "wb":
		if j == n:
			ismove = true
	return ismove

func setBoard():
	for i in range(8):
		for j in range(8):
			guiBoard[i][j].text = board[i][j][1]
	
func fill():
	pass
