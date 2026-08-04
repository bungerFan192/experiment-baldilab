extends AnimatedSprite2D

var anger : int = 0
var gameTimer : float = 0.0
var answer : int
var score : int = 0

@export var gameOver : ColorRect
@export var mathText : Label
@export var scoreText : Label
@export var answerText : LineEdit

@export var sound : AudioStreamPlayer
@export var startSound : AudioStreamWAV
@export var happySounds : Array[AudioStreamWAV]

func playsound(audioStream : AudioStreamWAV):
	sound.stop()
	sound.stream = audioStream
	sound.play()

func random_shake(intensity=10) -> Vector2: return Vector2(randi_range(-intensity, intensity), randi_range(-intensity, intensity))

func new_round() -> void:
	var difficulty = (anger+1) * (gameTimer/2)
	var equation = randi_range(0, 1)
	# 0: addition
	# 1: subtraction
	var x : int = floor(difficulty+randi_range((anger+1)*0.5, (anger+1)*3))
	var y : int = ceil(difficulty+randi_range((anger+1)*1, (anger+1)*5))
	if equation == 0:
		answer = x+y
		mathText.text = str(x) + " + " + str(y)
	else:
		answer = y-x
		mathText.text = str(y) + " - " + str(x)
	answerText.text = ""

func _gameover() -> void:
	gameOver.show()
	
	var tw = create_tween()
	var loop = 50
	for index in range(0, loop): tw.tween_property(gameOver, "position", position-(Vector2(270, 480)/2)+random_shake(2*(loop-index)), 0.025)
	gameOver.position = Vector2(270, 480)
func _ready() -> void:
	scoreText.text = "score: 0"
	score = 0
	animation = "0"
	anger = 0
	gameTimer = 0
	gameOver.hide()
	playsound(startSound)
	new_round()

func _anger(how_much:int=1) -> void:
	anger += how_much
	sound.stop()
	gameTimer = 0
	
	var tw = create_tween()
	var loop = 15
	for index in range(0, loop): tw.tween_property(self, "position", position+random_shake(how_much*(loop-index)), 0.025)
	
	if anger >= 5: _gameover()

func _process(delta: float) -> void:
	gameTimer += delta

func _on_answer_submitted(text: String) -> void:
	if not text == "":
		if int(text) == answer: 
			score += abs(int(text))
			playsound(happySounds[randi_range(0, happySounds.size()-1)])
		else:
			score -= (anger+1)*5
			_anger(1)
		scoreText.text = "score: " + str(score)
		if anger < 5: animation = str(anger)
		new_round()
