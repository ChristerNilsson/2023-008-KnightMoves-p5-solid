# p5 
# solid

# Använd solid för att hålla datastrukturen uppdaterad.
# Använd p5 för att rita upp den.

import {log,range,signal} from '../js/utils.js'

S = 50
N = 8
r = (i) => i // N
c = (i) => i % N
NOQUEENS = [3,4,10,13,17,18,19,20,21,22,24,26,29,31,32,34,37,39,41,42,43,44,45,46,50,53,59,60]
acc =0

class Board
	constructor : -> @values = _.map range(N*N), (i) => {i, ri:r(i), ci:c(i)}
	draw : =>
		for {i,ri,ci} in @values
			fill if (ri+ci) % 2 then 'darkgray' else 'lightgray'
			rect S*ci, S*ri, S, S

class Count
	constructor : -> @value = 0
	update : => @value++

class Counts
	constructor : -> @values = []
	draw : =>
		fill 'black'
		textSize 0.5*S
		for i in range @values.length
			ix = targets().values[i]
			col = c ix
			row = r ix
			text @values[i], S/2+S*col, S/2+S*row+0.05*S
	update : =>
		@values.push count().value + 1
		setCount new Count

class Knight
	constructor : (@value) ->
	draw : =>
		fill 'black'
		text '♘', S/2+S*c(@value), S/2+S*r(@value)+0.1*S

class KnightHops
	constructor :  ->
		k = knight().value
		ts = targets().values
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
		fill 'white'
		for i in @values
			circle S/2+S*c(i), S/2+S*r(i), S/4
	click : =>
		for index in @values
			if inside index
				setKnight new Knight index
				setKnightHops new KnightHops
				if index == target().value
					counts().update()
					target().update targets().values[counts().values.length+1]
					if counts().values.length == targets().values.length-1 then setState new State 2
				else
					count().update()

class Queen
	constructor : (@value) -> 
	draw : =>
		fill 'black'
		text '♛', S/2+S*c(@value), S/2+S*r(@value)+0.1*S
	click : => if inside @value then setState new State 0

class Queens
	constructor : -> @values = _.filter range(N*N), (i) -> not NOQUEENS.includes i
	draw : =>
		fill 'black'
		for i in @values
			text '♛', S/2+S*c(i), S/2+S*r(i)
	click : =>
		for index in @values
			if inside index
				setCount new Count
				setCounts new Counts
				setQueen new Queen index
				setQueenHops new QueenHops
				setTargets new Targets
				setKnight new Knight targets().values[counts().values.length]
				setTarget new Target targets().values[counts().values.length+1]
				setKnightHops new KnightHops
				setState new State 1

class QueenHops
	constructor : ->
		@queen =  queen().value
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
		fill 'black'
		for i in @values
			if i != @queen then circle S/2+S*c(i), S/2+S*r(i), S/4 #, S/2

class State
	constructor : (@value) ->

class Target
	constructor : (@value) ->
	draw : =>
		push()
		stroke 'yellow'
		strokeWeight 3
		noFill()
		circle S/2+S*c(@value), S/2+S*r(@value), S/2
		pop()
	update : () => @value = targets().values[counts().values.length+1]

class Targets
	constructor : -> @values = range(N*N).filter (i) => i not in queenHops().values

inside = (index) ->
	ci = c index
	ri = r index
	S*ci < mouseX < S*ci+S and S*ri < mouseY < S*ri+S

[count,setCount] = signal new Count
[counts,setCounts] = signal new Counts
[state, setState] = signal new State 0
[board, setBoard] = signal new Board
[queen, setQueen] = signal new Queen 0
[queens, setQueens] = signal new Queens
[queenHops, setQueenHops] = signal new QueenHops
[targets, setTargets] = signal new Targets
[target, setTarget] = signal new Target targets().values[1]
[knight, setKnight] = signal new Knight 34
[knightHops, setKnightHops] = signal new KnightHops

rita = =>
	background 'gray'
	textSize 50
	if state().value==0 then ops = [board,queens]
	if state().value==1 then ops = [board,queen,queenHops,knight,target,counts,knightHops]
	if state().value==2 then ops = [board,queen,queenHops,knight,counts]
	op().draw() for op in ops

window.mousePressed = =>
	start = new Date()
	[queens,knightHops,queen][state().value]().click()
	rita()
	acc += new Date()-start
	log acc

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

# audio = new Audio 'shortclick.mp3'

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
