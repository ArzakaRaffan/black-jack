extends Node2D

@onready var tween : Tween
@onready var card_sum: Label = $cardSum
@onready var hit_button: Button = $hitButton
@onready var pass_button: Button = $passButton
@onready var lose_label: Label = $loseLabel
@onready var win_label: Label = $winLabel
@onready var draw_label: Label = $drawLabel

var _spawn_pos = Vector2(1175, 420)
var firstCard_pos = Vector2(380, 430)
var secondCard_pos = Vector2(480, 430)
var thirdCard_pos = Vector2(580, 430)

const _1_CARD = preload("res://Codes/1_card.tscn")
const _2_CARD = preload("res://Codes/2_card.tscn")
const _3_CARD = preload("res://Codes/3_card.tscn")
const _4_CARD = preload("res://Codes/4_card.tscn")
const _5_CARD = preload("res://Codes/5_card.tscn")
const _6_CARD = preload("res://Codes/6_card.tscn")
const _7_CARD = preload("res://Codes/7_card.tscn")
const _8_CARD = preload("res://Codes/8_card.tscn")
const _9_CARD = preload("res://Codes/9_card.tscn")
const K_CARD = preload("res://Codes/k_card.tscn")
const Q_CARD = preload("res://Codes/q_card.tscn")

var cardList = [_1_CARD, _2_CARD, _3_CARD, _4_CARD, _5_CARD, _6_CARD, _7_CARD, _8_CARD, _9_CARD, K_CARD, Q_CARD]

var firstCard
var secondCard
var thirdCard
var fourthCard
var fifthCard


enum CardSort{
	FIRST,
	SECOND,
	THIRD,
	FOURTH,
	FIFTH
}

var currentCard = CardSort.FIRST

@onready var enemy_score: Label = $EnemyScore
var enemyScore = 0

func _ready() -> void:
	Global.cardSum = 0
	Global.lose = false
	buttons_settings(true)

	await instantiate_card(firstCard, 10, Vector2(400, 430))
	await instantiate_card(secondCard, 9, Vector2(500, 430))
	currentCard = CardSort.SECOND

	buttons_settings(false)

func card_anim(sprite, Moveposition: Vector2) -> void:
	tween.tween_property(sprite, "position", Moveposition, 1.5)
	await tween.finished

func _process(delta: float) -> void:
	if not Global.lose:
		card_sum.text = str(Global.cardSum)
	if Global.cardSum > 21 and not Global.lose:
		buttons_settings(true)
		await get_tree().create_timer(2.5).timeout
		tween.stop()
		Global.lose = true
		card_sum.hide()
		_on_lose_game()

func instantiate_card(card, batas: int, Cardposition: Vector2) -> void:
	tween = create_tween()
	var cardPicker: int = randi_range(0, batas)
	card = cardList[cardPicker].instantiate()
	cardList.pop_at(cardPicker)
	card.global_position = _spawn_pos
	get_parent().add_child(card)
	await card_anim(card, Cardposition)
	Global.cardSum += card.value

func _on_hit_button_pressed() -> void:
	match currentCard:
		CardSort.SECOND:
			buttons_settings(true)
			await instantiate_card(thirdCard, 8, Vector2(590, 430))
			currentCard = CardSort.THIRD
			buttons_settings(false)
		CardSort.THIRD:
			buttons_settings(true)
			await instantiate_card(fourthCard, 7, Vector2(680, 430))
			currentCard = CardSort.FOURTH
			buttons_settings(false)

func _on_lose_game() -> void:
	tween = create_tween()
	tween.tween_property(lose_label, "position", Vector2(485, 175), 1)
	await get_tree().create_timer(2).timeout
	_clear_scene()

func _on_win_game() -> void:
	tween = create_tween()
	tween.tween_property(win_label, "position", Vector2(485, 175), 1)
	await get_tree().create_timer(2).timeout
	_clear_scene()

func _on_draw_game() -> void:
	tween = create_tween()
	tween.tween_property(draw_label, "position", Vector2(485, 175), 1)
	await get_tree().create_timer(2).timeout
	_clear_scene()

func buttons_settings(status: bool) -> void:
	hit_button.disabled = status
	pass_button.disabled = status

func enemyScoreRandomizer():
	if Global.cardSum >= 17 and Global.cardSum < 22:
		var chance = randf_range(0,1)
		if chance >= 0 and chance <= 0.2:
			enemyScore = randi_range(21, 28)
		elif chance > 0.2 and chance <= 0.75:
			enemyScore = randi_range(16, 21)
		elif chance > 0.75:
			enemyScore = randi_range(19, 21)
	if Global.cardSum < 17:
		var chance = randf_range(0,1)
		if chance >= 0 and chance <= 0.25:
			enemyScore = randi_range(10, 15)
		elif chance > 0.25 and chance <= 0.75:
			enemyScore = randi_range(17, 19)
		elif chance > 0.75:
			enemyScore = randi_range(19, 21)
	

func _on_pass_button_pressed() -> void:
	buttons_settings(true)
	enemyScoreRandomizer()
	enemy_score.text = "ENEMY SCORE\n"+ str(enemyScore)
	enemy_score.show()
	await get_tree().create_timer(1.5).timeout
	card_sum.hide()
	enemy_score.hide()
	if enemyScore > 21 or (enemyScore < 21 and (enemyScore < Global.cardSum)):
		buttons_settings(true)
		_on_win_game()
	if enemyScore < 21 and (enemyScore > Global.cardSum):
		buttons_settings(true)
		_on_lose_game()
	if enemyScore == Global.cardSum:
		buttons_settings(true)
		_on_draw_game()
	if enemyScore == 21 and Global.cardSum != 21:
		buttons_settings(true)
		_on_lose_game()

func _clear_scene() -> void:
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			get_parent().remove_child(child)
	get_tree().change_scene_to_file("res://Codes/main_menu.tscn")
