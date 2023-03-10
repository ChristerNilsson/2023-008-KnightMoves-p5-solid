import {log,range} from '../js/utils.js'

S = 50
N = 8
NOQUEENS = [3,4,10,13,17,18,19,20,21,22,24,26,29,31,32,34,37,39,41,42,43,44,45,46,50,53,59,60]
mx = S
my = S/2
os = if navigator.userAgent.includes 'Windows' then 'Windows' else 'Mac'
audio = new Audio 'shortclick.mp3'

r = (i) => i // N
c = (i) => i % N
sum = (arr)	=> arr.reduce(((a, b) => a + b), 0)

class Board
	constructor : -> @values = _.map range(N*N), (i) => {ri:r(i), ci:c(i)}
	draw : =>
		for {ri,ci} in @values
			fill if (ri+ci) % 2 then 'darkgray' else 'lightgray'
			rect mx+S*ci, my+S*ri, S, S
			fill 'black'
			textSize 0.5*S
		for i in range N
			text "abcdefgh"[i], mx+S/2+S*i, my+8.5*S
			text "87654321"[i], mx-S/2, my+S/2+S*i

window.onresize = -> 
	H = min(innerHeight//10,innerWidth//10)
	W = H
	S = W
	mx = (innerWidth - 8*S)/2
	my = S/2
	resizeCanvas innerWidth, innerHeight
	rita()

drawText = (txt,ix) => 
	dy = if os=='Windows' then 0.1*S else 0.0*S
	text txt, mx+S/2+S*c(ix), my+S/2+S*r(ix)+dy

class Counts
	constructor : -> @values = []
	draw : =>
		fill 'black'
		textSize 0.5*S
		for i in range @values.length
			drawText @values[i], Z.targets.values[i]
		text sum(@values)+" moves in #{(new Date - Z.start)/1000} seconds", mx+4*S, my+9.25*S
	update : =>
		@values.push Z.count + 1
		Z.count = 0

class Knight
	constructor : (@value) ->
	draw : =>
		fill 'black'
		textSize S
		drawText '♘', @value

class KnightHops
	constructor :  ->
		k = Z.knight.value
		ts = Z.targets.values
		if k==-1 then return []
		@values = []
		col = c k
		row = r k
		for dc in [-2,-1,1,2]
			for dr in [-2,-1,1,2]
				if Math.abs(dc) == Math.abs(dr) then continue
				c2 = col + dc
				r2 = row + dr
				index = c2+N*r2
				if c2 in range(N) and r2 in range(N) and index in ts then @values.push index
		@values.sort (a,b) -> a-b
	draw : =>
		col = c Z.queen.value
		if col%2==1 then return
		fill 'white'
		for i in @values
			circle mx+S/2+S*c(i), my+S/2+S*r(i), S/4
	click : =>
		for index in @values
			if inside index
				audio.play()
				Z.knight = new Knight index
				Z.knightHops = new KnightHops
				if index == Z.target.value
					Z.counts.update()
					Z.target.update Z.targets.values[Z.counts.values.length+1]
					if Z.counts.values.length == Z.targets.values.length-1 then Z.state = 2
				else
					Z.count++

class Queen
	constructor : (@value) ->
	draw : =>
		fill 'black'
		textSize S
		drawText '♛', @value
	click : => if inside @value then Z.state = 0

class Queens
	constructor : -> @values = _.filter range(N*N), (i) -> i not in NOQUEENS
	draw : =>
		fill 'black'
		textSize S
		for i in @values
			drawText '♛', i
	click : =>
		for index in @values
			if inside index
				Z.count = 0
				Z.counts = new Counts
				Z.queen = new Queen index
				Z.queenHops = new QueenHops
				Z.targets  = new Targets
				Z.knight = new Knight Z.targets.values[Z.counts.values.length]
				Z.target = new Target Z.targets.values[Z.counts.values.length+1]
				Z.knightHops = new KnightHops
				Z.state = 1
				Z.start = new Date

class QueenHops
	constructor : ->
		@queen =  Z.queen.value
		f = (i) =>
			ci = c i
			ri = r i
			dc = Math.abs ci - @cq
			dr = Math.abs ri - @rq
			ci == @cq or ri == @rq or dc == dr
		@cq = c @queen
		@rq = r @queen
		@values = _.filter range(N*N), f
	draw: =>
		row = r Z.queen.value
		if row%2==0 then return
		fill 'black'
		for i in @values
			if i != @queen then circle mx+S/2+S*c(i), my+S/2+S*r(i), S/4

class Target
	constructor : (@value) ->
	draw : =>
		push()
		stroke 'yellow'
		strokeWeight 3
		noFill()
		circle mx+S/2+S*c(@value), my+S/2+S*r(@value), S/2
		pop()
	update : () => @value = Z.targets.values[Z.counts.values.length+1]

class Targets
	constructor : -> @values = range(N*N).filter (i) => i not in Z.queenHops.values

inside = (index) ->
	ci = c index
	ri = r index
	S*ci < mouseX-mx < S*ci+S and S*ri < mouseY-my < S*ri+S

Z = {} # object to hold global variables.
Z.state = 0
Z.count = 0 #new Count
Z.counts = new Counts
Z.board =  new Board
Z.queen = new Queen 0
Z.queens = new Queens
Z.queenHops = new QueenHops
Z.targets = new Targets
Z.knight = new Knight Z.targets.values[0]
Z.target = new Target Z.targets.values[1]
Z.knightHops = new KnightHops

rita = =>
	background 'gray'
	textSize S
	if Z.state==0 then ops = "board,queens"
	if Z.state==1 then ops = "board,queen,queenHops,knight,target,counts,knightHops"
	if Z.state==2 then ops = "board,queen,queenHops,knight,counts"
	Z[op].draw() for op in ops.split ','

window.mousePressed = =>
	Z["queens,knightHops,queen".split(',')[Z.state]].click()
	rita()

window.setup = =>
	createCanvas innerWidth, innerHeight
	frameRate 1
	textAlign CENTER, CENTER
	rita()

######################################

# range = _.range
# logg = console.log
# logg navigator.userAgent
# os = if navigator.userAgent.includes 'Windows' then 'Windows' else 'Mac'


# intro = ["Select a queen"]

# sum = (arr)	=> arr.reduce(((a, b) => a + b), 0)

# NOQUEEN = [3,4,10,13,17,18,19,20,21,22,24,26,29,31,32,34,37,39,41,42,43,44,45,46,50,53,59,60]
# N = 8
# W = 0
# H = 0
# R = W//10
# c = (n) => n %% N
# r = (n) => n // N
# rects = []

# Queen = '♛'
# Knight = '♘'
# queen = 0
# queenHops = [] # indexes of squares taken by queen
# targets = [] # indexes of squares that knight must visit
# state = 0
# marginx = 0
# marginy = 0

# makeKnightHops = (knight) =>
# 	if knight==-1 then return []
# 	res = []
# 	col = c knight
# 	row = r knight
# 	for dc in [-2,-1,1,2]
# 		for dr in [-2,-1,1,2]
# 			if abs(dc) == abs(dr) then continue
# 			c2 = col + dc
# 			r2 = row + dr
# 			index = c2+8*r2
# 			if c2 in range(8) and r2 in range(8) and index in targets then res.push index
# 	res.sort (a,b) -> a-b
# 	res

# knight = 0
# knightHops = []
# clicks = 0
# counts = []	# number of clicks for each target
# taken = 0
# results = ['Move the knight to the yellow ring']

# start = 0

# window.onresize = -> reSize()

# reSize = ->
# 	H = min(innerHeight//11,innerWidth//9)
# 	W = H
# 	R = W//10
# 	resizeCanvas innerWidth, innerHeight
# 	rects = []
# 	marginx = (innerWidth-10*W)/2 + W//3
# 	marginy = H
# 	for index in range N*N
# 		ri = r index
# 		ci = c index
# 		col = if (ri + ci) % 2 then 'lightgray' else 'darkgray'
# 		x = 3*W/2 + W * c index
# 		y = H * (7-r index)
# 		rects.push new Rect index, marginx+x, marginy+y, W,H, col
# 	rects.push new Rect 64, marginx+W*0.6, marginy+8*H, 0.8*W,0.8*H, col


# placeQueen = (index) =>
# 	logg 'Q' + Position index
# 	if NOQUEEN.includes index
# 		logg 'No queen here'
# 		return

# 	queen = index
# 	makeQueenHops()
# 	targets = range(N*N).filter (i) => not queenHops.includes i
# 	targets.sort (a,b) -> b-a
# 	knight = targets[0]
# 	knightHops = makeKnightHops knight
# 	counts = []
# 	taken++
# 	state++

# newGame = () ->
# 	queen = 0
# 	queenHops = []
# 	knightHops = []
# 	targets = []
# 	state = 0
# 	knight = 0
# 	clicks = 0
# 	counts = []
# 	taken = 0
# 	start = new Date()

# moveKnight = (index) =>
# 	if queenHops.includes index then return
# 	col = c index
# 	row = r index
# 	dx = abs col - c knight
# 	dy = abs row - r knight
# 	if index in knightHops
# 		audio.play()
# 		knight = index
# 		knightHops = makeKnightHops knight
# 		clicks++
# 		if targets[taken] == knight
# 			taken++
# 			counts.push clicks
# 			clicks = 0
# 	if taken == targets.length
# 		results = ["Q#{Position queen}: #{sum(counts)} moves took #{(new Date()-start)/1000} seconds","Click Ok"]
# 		knightHops = []
# 		state = 2

# class Rect
# 	constructor : (@index, @x,@y, @w,@h, @col) ->
# 	draw : ->
# 		fill @col
# 		rect @x, @y, @w, @h
# 		if @index == 64
# 			fill 'black'
# 			textSize 0.5*W
# 			text "Ok", @x, @y
# 	inside : (x, y) -> abs(x-@x) <= W/2 and abs(y-@y) <= H/2
# 	click : -> 
# 		# audio.pause()
# 		if state==0 then placeQueen @index
# 		else if state==1 then moveKnight @index
# 		else if state==2 then newGame()
# 	drawPiece : (name) ->
# 		textSize 1.1 * W
# 		fill "black"
# 		if os=='Windows' then text name,@x,@y+0.1*H
# 		if os!='Windows' then text name,@x,@y+0.0*H
# 	drawQueenHop  : -> if r(queen)%2==0 and @index!=queen and @index in queenHops then ellipse @x, @y, 3*R
# 	drawKnightHop : -> if c(queen)%2==0 and @index in knightHops then ellipse @x, @y, 3*R
# 	text : (txt) ->
# 		textAlign CENTER, CENTER
# 		textSize 0.5*W
# 		fill 'black'
# 		text txt, @x, @y
# 	ring : =>
# 		noFill()
# 		push()
# 		strokeWeight 3
# 		stroke 'yellow'
# 		ellipse @x, @y, 5*R
# 		pop()

# setup = =>
# 	reSize()
# 	newGame()
# 	rectMode CENTER
# 	textAlign CENTER, CENTER
# 	createCanvas innerWidth, innerHeight

# Position = (index) -> "abcdefgh"[c index] + "12345678"[r index]

# info = ->
# 	fill 'black'
# 	textAlign CENTER, CENTER
# 	textSize 0.5*W
# 	temp = if state==0 then intro else results
# 	for result,i in temp
# 		text result,innerWidth//2, 10*H + i*H/2

# drawBoard = =>
# 	n = [64,64,65][state]
# 	rect.draw() for rect in rects.slice 0,n

# showLittera = (flag) =>
# 	col1 = "black"
# 	col2 = "white"
# 	textSize 0.5*W
# 	for i in range N
# 		x = W*(1.5+i) + marginx
# 		y = W*(N-1-i) + marginy
# 		col3 = if flag then [col2,col1][i%2] else col1
# 		noFill()
# 		if flag and i%2==0 then circle x, W*(N+1), 0.6*W
# 		fill col1
# 		if flag and i%2==0 then circle marginx+W/2, y,0.6*W
# 		text "abcdefgh"[i], x, W*(N+1)
# 		if i%2==0 then fill col3 else fill col1
# 		text "12345678"[i], marginx+W/2, y

# draw = =>
# 	background 128
# 	drawBoard()
# 	showLittera state==0
# 	info()

# 	textAlign CENTER, CENTER
# 	if state == 1
# 		rects[queen].drawPiece Queen
# 		rects[knight].drawPiece Knight

# 	textSize 0.55*W
# 	for i in range taken
# 		if targets[i] != knight
# 			rects[targets[i]].text counts[i]

# 	fill 'black'
# 	for i in queenHops
# 		rects[i].drawQueenHop()

# 	fill 'white'
# 	for i in knightHops
# 		rects[i].drawKnightHop()

# 	if state == 0
# 		for i in range(N*N)
# 			if not NOQUEEN.includes i
# 				rects[i].drawPiece(Queen)

# 	if state == 1
# 		rects[targets[taken]].ring()

# 	if state == 2
# 		rects[queen].drawPiece Queen
# 		rects[knight].drawPiece Knight

# mousePressed = ->
# 	if state == 2
# 		rect = rects[64]
# 		if rect.inside mouseX, mouseY then rect.click()
# 		# newGame()
# 		# return
# 	else
# 		for rect in rects
# 			if rect.inside mouseX, mouseY then rect.click()
