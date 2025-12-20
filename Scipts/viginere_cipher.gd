extends Control

var previous_size
@export var Array2D = []
@onready var viginere_cell = preload("res://Scenes/viginere_cell.tscn")
@onready var grid = $ViginereGrid
@onready var halphabet = $Halphabet
@onready var valphabet = $Valphabet
@onready var key = $Panel/Key2
@onready var plain_text = $Panel/PlainText2
@onready var cipher_text = $Panel/CipherText2
const highlight_style = preload("res://Assets/new_style_box_flat.tres")
const found_style = preload("res://Assets/green_style_box_flat.tres")

func _ready() -> void:
	previous_size = DisplayServer.window_get_size()

	DisplayServer.window_set_size(Vector2i(2500, 1800))
	
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)
	_create_viginere()

func _create_viginere() ->void:
	_set_labels()
	for i in 26 :
		var hlabel = _create_alpha_label(Global.Alphabet[i],false)
		halphabet.add_child(hlabel)
		
		var vlabel = _create_alpha_label(Global.Alphabet[i],true)
		valphabet.add_child(vlabel)
		
		var k = i
		for j in 26 :
			var new_cell = viginere_cell.instantiate()
			new_cell.get_child(0).get_child(0).text = Global.Alphabet[k%26]
			k = k+1
			grid.add_child(new_cell)
	_create_Array2D()
func _create_Array2D():
	for i in 26 :
		Array2D.append([])
		for j in 26:
			Array2D[i].append(grid.get_child(i * 26 + j))

func _create_alpha_label(letter : String , isV :bool) -> Label :
	var label = Label.new()
	label.text = letter
	label.add_theme_font_size_override("font_size", 45)
	label.add_theme_font_override("font", load("res://Assets/Pixel Game.otf"))
	return label
	

func _set_labels()->void:
	if Global.KEY == "" or Global.PlainText == "" :
		return
	plain_text.text = Global.PlainText
	key.text = Global.KEY
	while key.text.length() < Global.PlainText.length() :
		key.text += Global.KEY
	key.text =  key.text.substr(0,Global.PlainText.length())

func _encrypt()->void:
	var col_index 
	var row_index
	for i in key.text.length():
		await get_tree().create_timer(0.5).timeout
		col_index = Global.AlphabetMap[key.text[i]]-1
		if plain_text.text[i] != " ":
			row_index = Global.AlphabetMap[plain_text.text[i]]-1
		halphabet.get_child(col_index).set("theme_override_colors/font_color", Color.YELLOW)
		valphabet.get_child(row_index).set("theme_override_colors/font_color", Color.YELLOW)
		#animate cell coloring
		for k in 26 :
			Array2D[row_index][k].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			Array2D[k][col_index].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			await get_tree().create_timer(0.1).timeout
		
		Array2D[row_index][col_index].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
		await get_tree().create_timer(0.2).timeout
		
		# reset cells
		for k in 26 :
				Array2D[row_index][k].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
				Array2D[k][col_index].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
							
		await get_tree().create_timer(0.5).timeout
		cipher_text.text +=Array2D[row_index][col_index].get_child(0).get_child(0).text
		halphabet.get_child(col_index).set("theme_override_colors/font_color", Color.WHITE)
		valphabet.get_child(row_index).set("theme_override_colors/font_color", Color.WHITE)
		
	#print(cipher_text.text)
	#for i in 26 :
		#for j in 26:
			#print(i)
			#print(j)
			#print(Array2D[i][j].get_child(0).get_child(0).text)
			#print("===============================")


func _decrypt()->void:
	plain_text.text=""
	var row_index
	for i in key.text.length():
		await get_tree().create_timer(0.5).timeout
		row_index = Global.AlphabetMap[key.text[i]]-1
		#halphabet.get_child(col_index).set("theme_override_colors/font_color", Color.YELLOW)
		valphabet.get_child(row_index).set("theme_override_colors/font_color", Color.YELLOW)
		
		#animate cell coloring
		var cipher_col
		for k in 26 :
			if Array2D[row_index][k].get_child(0).get_child(0).text == cipher_text.text[i]:
				cipher_col = k
				break
			Array2D[row_index][k].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			await get_tree().create_timer(0.1).timeout
		
		Array2D[row_index][cipher_col].get_child(0).get_child(0).set("theme_override_styles/normal", found_style)
		await get_tree().create_timer(0.1).timeout
		
		for k in range(row_index-1,-1,-1) :
			Array2D[k][cipher_col].get_child(0).get_child(0).set("theme_override_styles/normal", highlight_style)
			await get_tree().create_timer(0.1).timeout
		
		halphabet.get_child(cipher_col).set("theme_override_colors/font_color", Color.YELLOW)
		await get_tree().create_timer(0.5).timeout
		# reset cells
		for k in 26 :
			Array2D[row_index][k].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
			Array2D[k][cipher_col].get_child(0).get_child(0).set("theme_override_styles/normal",StyleBoxEmpty.new())
		
		await get_tree().create_timer(0.5).timeout
		plain_text.text +=halphabet.get_child(cipher_col).text
		halphabet.get_child(cipher_col).set("theme_override_colors/font_color", Color.WHITE)
		valphabet.get_child(row_index).set("theme_override_colors/font_color", Color.WHITE)
	

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CipherScene.tscn")
	DisplayServer.window_set_size(previous_size)
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)

func _on_encrypt_pressed() -> void:
	if Global.PlainText.is_empty() || Global.KEY.is_empty():
		print("ERROR: PlainText or KEY is empty!")
		return
	$Encrypt.disabled = true
	_encrypt()
	$Decrypt.disabled = false

func _on_decrypt_pressed() -> void:
	if Global.KEY.is_empty() || cipher_text.text.is_empty():
		print("ERROR: PlainText or KEY is empty!")
		return
	$Decrypt.disabled = true
	$Encrypt.disabled = true
	_decrypt()
	$Decrypt.disabled = false
	$Encrypt.disabled = false
