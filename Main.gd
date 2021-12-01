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
var cleanBoard = board.duplicate(true)
# Called when the node enters the scene tree for the first time.
func _ready():
	val($FENLineEdit.text)
	paintBoard()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FENLineEdit_text_changed(new_text):
	var fen = new_text
	val(fen)
	pass # Replace with function body.

func val(fen):
	#dodać walidację liczenia backslashy i spacji z trymowaniem
	var isValid = false
	var fenArr = fen.split("/", true, 0)
	var lastCell = fenArr[-1]
	fenArr.remove(fenArr.size()-1)
	fenArr += lastCell.split(" ", true, 0)
	#print_debug(fenArr)
	#print_debug(len(fenArr))
	
	## BUILDING THE BOARD
	
	# main logic behind building the board is
	# to write figures as they are and
	# understand numbers as an amount of empty spaces
	var colNumber = true
	var colNumberI
	# if the length is right the notation has 
	# the right amount of segments
	if len(fenArr) == 13:
		for i in range(8):
			var line = fenArr[i].split("", true, 0)
			var col = 0
			for j in line:
				for k in j:
					if col==8:
						$ValidateLabel.text = "Too much columns in row: "+str(i)
						pass
					#print_debug("k: ",k)
					#print_debug("col: ",col)
					if isNumber(k):
						#print_debug(k)
						#print_debug(typeof(k))
						for g in range(int(k)):
							board[i][col][1] = ""
							col += 1
					elif isFigure(k):
						board[i][col][1] = k
						col += 1
					else:
						# If one of the chars inputed in first 8 segments
						# is not 1-8 nor "rnbqkpRNBQKP", then the syntax
						# is invalid
						$ValidateLabel.text = "Invalid character in row: "+str(i)
						messCleaner()
						pass
						
			if col!=8:
				colNumber = false
				colNumberI = i + 1
	
	if !colNumber:
		$ValidateLabel.text = "Incorrect number of columns in row: " + str(colNumberI)
		messCleaner()
	elif len(fenArr) != 13 && colNumber:
		$ValidateLabel.text = "A part of FEN notation is missing"
		messCleaner()
		pass
	else:
		$ValidateLabel.text = "Number of columns in each row is corrct"

	for i in range(len(board)):
		print_debug(board[i])
	paintBoard()

	## SECOND PART OF FEN
	# "Who's on the move?"
	var onMove
	if isMove(fenArr[8]):
		onMove = fenArr[8]
		if onMove == "w":
			$ValidateOnMoveLabel.text = "Whites are on the move"
		elif onMove == "b":
			$ValidateOnMoveLabel.text = "Blacks are on the move"
	else:
		$ValidateOnMoveLabel.text = "Not specified who's on the move"
	
	# "Castling"
	if castling(fenArr[9]):
		$ValidateCastlingLabel.text = "Castling is correctly marked"
	else:
		$ValidateCastlingLabel.text = "Castling FEN part is incorrect"

	# "En Passant"
	if isEnPassant(fenArr[10],onMove):
		$ValidateEnPassantLabel.text = "En Passant is marked correctly"
	else:
		$ValidateEnPassantLabel.text = "En Passant is marked incorrectly"
	
	# "Halfmove"
	if isHalfMove(fenArr[11]):
		$ValidateHMLabel.text = "Halfmove is marked correctly"
	else:
		$ValidateHMLabel.text = "Halfmove is marked incorrectly"
	
	# "Fullmove"
	if isFullMove(fenArr[11],fenArr[12]):
		$ValidateFMLabel.text = "Fullmove is marked correctly"
	else:
		$ValidateFMLabel.text = "Fullmove is marked incorrectly"
		
	$ValidateKingLabel.text = correctKing()
	
func messCleaner():
	board = cleanBoard
	paintBoard()
	
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
	
func isFigure(n):
	for j in "rnbqkpRNBQKP":
		if j == n:
			return true
	return false
	
func isMove(n):
	var ismove = false
	for j in "wb":
		if j == n:
			ismove = true
	return ismove

func castling(n):
	# if it's "-", it means there are none and it is very likely
	if n == "-":
		return true
	
	# checking if the castling is not dublicated
	for i in n:
		if n.count(i)>1:
			return false
	
	for i in n:
		if i == "K":
			if board[7][4][1]!="K" || board[7][7][1]!="R":
				return false
		elif i == "Q":
			if board[7][4][1]!="K" || board[7][0][1]!="R":
				return false
		elif i == "k":
			if board[0][4][1]!="k" || board[0][7][1]!="r":
				return false
		elif i == "q":
			if board[0][4][1]!="k" || board[0][0][1]!="r":
				return false
	return true

func isEnPassant(n, m):
	if n == "-":
		return true
	elif len(n)!=2:
		return false
	
	if "abcdefgh".count(n[0])==0:
		return false
	
	if m == "w":
		if n[1]!="6":
			return false
		else:
			match n[0]:
				"a":
					if board[3][0][1] == "p":
						return true
				"b":
					if board[3][1][1] == "p":
						return true
				"c":
					if board[3][2][1] == "p":
						return true
				"d":
					if board[3][3][1] == "p":
						return true
				"e":
					if board[3][4][1] == "p":
						return true
				"f":
					if board[3][5][1] == "p":
						return true
				"g":
					if board[3][6][1] == "p":
						return true
				"h":
					if board[3][7][1] == "p":
						return true
	elif m == "b":
		if n[1]!="3":
			return false
		else:
			match n[0]:
				"a":
					if board[4][0][1] == "P":
						return true
				"b":
					if board[4][1][1] == "P":
						return true
				"c":
					if board[4][2][1] == "P":
						return true
				"d":
					if board[4][3][1] == "P":
						return true
				"e":
					if board[4][4][1] == "P":
						return true
				"f":
					if board[4][5][1] == "P":
						return true
				"g":
					if board[4][6][1] == "P":
						return true
				"h":
					if board[4][7][1] == "P":
						return true
	return false
	
func isHalfMove(n):
	if n == "0":
		return true
	elif len(n)>3:
		return false
	for i in n:
		if "1234567890".count(i)==0:
			return false
	if int(n)>=100:
		return false
	return true

func isFullMove(n, half):
	if n == "0":
		return true
	elif len(n)>2:
		return false
	for i in n:
		if "1234567890".count(i)==0:
			return false
	if (int(n)/2)>int(half):
		return false
	return true

func correctKing():
	var King = 0
	var king = 0
	var ki = ""
	var kj = ""
	# checking for amount of kings and not next
	# to each other
	for i in range(len(board)):
		if (king>1 || King>1):
			return "There are too many kings!"
		for j in range(len(board[i])):
			if board[i][j][1] == "k":
				# if we find a king, we take his coordinates
				# and check for any nearby
				if kingNear(i,j):
					return "Kings are too close"
				king += 1
			elif board[i][j][1] == "K":
				# if we find a king, we take his coordinates
				# and check for any nearby
				if kingNear(i,j):
					return "Kings are too close"
				King += 1
	if (king==0 || King==0):
		return "King is missing"
	return "Kings are correctly placed"
	
func kingNear(r,c):
	# we check only the one on right in the same row
	# and -1 , 0 , 1 positions in next row
	if c<7:
		if board[r][c+1][1] == "k" or board[r][c+1][1] == "K":
			return true
	if c>0 and r<7:
		if board[r+1][c-1][1] == "k" or board[r+1][c-1][1] == "K":
			return true
	if r<7:
		if board[r+1][c][1] == "k" or board[r+1][c][1] == "K":
			return true
	if c<7 and r<7:
		if board[r+1][c+1][1] == "k" or board[r+1][c+1][1] == "K":
			return true
	return false
	
func paintBoard():
	$Background/a8/Label.text = board[0][0][1]
	$Background/b8/Label.text = board[0][1][1]
	$Background/c8/Label.text = board[0][2][1]
	$Background/d8/Label.text = board[0][3][1]
	$Background/e8/Label.text = board[0][4][1]
	$Background/f8/Label.text = board[0][5][1]
	$Background/g8/Label.text = board[0][6][1]
	$Background/h8/Label.text = board[0][7][1]
	
	$Background/a7/Label.text = board[1][0][1]
	$Background/b7/Label.text = board[1][1][1]
	$Background/c7/Label.text = board[1][2][1]
	$Background/d7/Label.text = board[1][3][1]
	$Background/e7/Label.text = board[1][4][1]
	$Background/f7/Label.text = board[1][5][1]
	$Background/g7/Label.text = board[1][6][1]
	$Background/h7/Label.text = board[1][7][1]
	
	$Background/a6/Label.text = board[2][0][1]
	$Background/b6/Label.text = board[2][1][1]
	$Background/c6/Label.text = board[2][2][1]
	$Background/d6/Label.text = board[2][3][1]
	$Background/e6/Label.text = board[2][4][1]
	$Background/f6/Label.text = board[2][5][1]
	$Background/g6/Label.text = board[2][6][1]
	$Background/h6/Label.text = board[2][7][1]
	
	$Background/a5/Label.text = board[3][0][1]
	$Background/b5/Label.text = board[3][1][1]
	$Background/c5/Label.text = board[3][2][1]
	$Background/d5/Label.text = board[3][3][1]
	$Background/e5/Label.text = board[3][4][1]
	$Background/f5/Label.text = board[3][5][1]
	$Background/g5/Label.text = board[3][6][1]
	$Background/h5/Label.text = board[3][7][1]
	
	$Background/a4/Label.text = board[4][0][1]
	$Background/b4/Label.text = board[4][1][1]
	$Background/c4/Label.text = board[4][2][1]
	$Background/d4/Label.text = board[4][3][1]
	$Background/e4/Label.text = board[4][4][1]
	$Background/f4/Label.text = board[4][5][1]
	$Background/g4/Label.text = board[4][6][1]
	$Background/h4/Label.text = board[4][7][1]
	
	$Background/a3/Label.text = board[5][0][1]
	$Background/b3/Label.text = board[5][1][1]
	$Background/c3/Label.text = board[5][2][1]
	$Background/d3/Label.text = board[5][3][1]
	$Background/e3/Label.text = board[5][4][1]
	$Background/f3/Label.text = board[5][5][1]
	$Background/g3/Label.text = board[5][6][1]
	$Background/h3/Label.text = board[5][7][1]
	
	$Background/a2/Label.text = board[6][0][1]
	$Background/b2/Label.text = board[6][1][1]
	$Background/c2/Label.text = board[6][2][1]
	$Background/d2/Label.text = board[6][3][1]
	$Background/e2/Label.text = board[6][4][1]
	$Background/f2/Label.text = board[6][5][1]
	$Background/g2/Label.text = board[6][6][1]
	$Background/h2/Label.text = board[6][7][1]
	
	$Background/a1/Label.text = board[7][0][1]
	$Background/b1/Label.text = board[7][1][1]
	$Background/c1/Label.text = board[7][2][1]
	$Background/d1/Label.text = board[7][3][1]
	$Background/e1/Label.text = board[7][4][1]
	$Background/f1/Label.text = board[7][5][1]
	$Background/g1/Label.text = board[7][6][1]
	$Background/h1/Label.text = board[7][7][1]
	
func fill():
	pass
