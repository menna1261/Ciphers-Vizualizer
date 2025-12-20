extends Control
@onready var ceaser_node = $CeaserCircle
@onready var cell = preload("res://Scenes/ceaser_cell.tscn")
@onready var key = $Panel/Key2
@onready var plain_text = $Panel/PlainText2
@onready var cipher_text = $Panel/CipherText2
const highlight_style = preload("res://Assets/new_style_box_flat.tres")
const found_style = preload("res://Assets/green_style_box_flat.tres")
const required_style = preload("res://Assets/required.tres")
var previous_size

func _ready() -> void:
	previous_size = DisplayServer.window_get_size()

	DisplayServer.window_set_size(Vector2i(2500, 1800))
	
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)
	_create_ceaser()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CipherScene.tscn")
	DisplayServer.window_set_size(previous_size)
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)



func _create_ceaser()->void :
	var start_position = ceaser_node.position
	var radius = 450
	for i in 26 :
		var new_cell = cell.instantiate()
		new_cell.get_child(0).get_child(0).text = Global.Alphabet[i].to_upper();
		var angel = (2*PI*i)/26
		var x = radius*cos(angel)+70
		var y = radius*sin(angel)+70
		new_cell.position = Vector2i(x,y)
		ceaser_node.add_child(new_cell)
	key.text = Global.KEY
	plain_text.text = Global.PlainText
	
func _encrypt(text : String)->void :
	cipher_text.text=""
	var k = int(Global.KEY)
	for i in Global.PlainText.length():
		var index = Global.AlphabetMap[Global.PlainText[i]]-1
		ceaser_node.get_child(index).get_child(0).get_child(0).set("theme_override_styles/normal", required_style)
		for j in range(k):
			var cell_index = (index + j) % 26  
			if(cell_index == index) :
				continue
			ceaser_node.get_child(cell_index).get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			await get_tree().create_timer(0.3).timeout
		ceaser_node.get_child(index+k).get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
		cipher_text.text+=ceaser_node.get_child(index+k).get_child(0).get_child(0).text
		await get_tree().create_timer(0.3).timeout
		
		for j in range(k):
			var cell_index = (index + j) % 26  
			ceaser_node.get_child(cell_index).get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
		ceaser_node.get_child(index+k).get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())


func _decrypt(text : String)->void :
	plain_text.text = ""
	var k = int(Global.KEY)
	for i in cipher_text.text.length():
		var index = Global.AlphabetMap[cipher_text.text[i].to_lower()]-1
		ceaser_node.get_child(index).get_child(0).get_child(0).set("theme_override_styles/normal", required_style)
		for j in range(k):
			var cell_index = (index - j+26) % 26  
			if(cell_index == index) :
				continue
			ceaser_node.get_child(cell_index).get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			await get_tree().create_timer(0.2).timeout
		var plain_index = (index - k + 26) % 26
		ceaser_node.get_child(plain_index).get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
		plain_text.text+=ceaser_node.get_child(plain_index).get_child(0).get_child(0).text
		await get_tree().create_timer(0.3).timeout
		
		for j in range(k):
			var cell_index = (index - j + 26) % 26  
			ceaser_node.get_child(cell_index).get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
		ceaser_node.get_child(plain_index).get_child(0).get_child(0).set("theme_override_styles/normal", StyleBoxEmpty.new())


func _on_encrypt_pressed() -> void:
	_encrypt(Global.PlainText)
	$Decrypt.disabled = false


func _on_decrypt_pressed() -> void:
	_decrypt(cipher_text.text)
