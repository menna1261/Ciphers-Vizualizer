extends Control
@onready var li = $Li/Label
@onready var ri = $Ri/Label
@onready var li_1 = $"Li1+1/Label"
@onready var ri_1 = $"Ri1+1/Label"
@onready var li_1_s = $"Li1+1"
@onready var ri_1_s = $"Ri1+1"
@onready var round_number = $RoundNumber
@onready var round_key = $RoundKey
@onready var current_block = $CurrentBlock2
@onready var plain_text = $PlainText2
@onready var cipher_text = $CipherText2
@onready var key_text = $Key2

@onready var s_box_trapezoid = $DesTrapezoid
@onready var expantion_permutation = $DesTrapezoid2
@onready var xor_key = $DesXor
@onready var des_xor2 = $DesXor2
@onready var expand_arrow = $ShortArrow
@onready var xor_with_key_arrow = $ShortArrow2
@onready var s_box_arrow = $ShortArrow3
@onready var p_box_arrow = $ShortArrow4
@onready var xor_with_left_arrow = $ShortArrow5
@onready var to_right_arrow = $ShortArrow6
@onready var key_arrow = $ShortArrow7
@onready var long_line = $LongLine
@onready var long_arrow = $LongArrow
@onready var p_box = $PBox

var block_number = 1
var encrypted_text
var previous_size

# Test function
func _ready():
	previous_size = DisplayServer.window_get_size()
	DisplayServer.window_set_size(Vector2i(2500, 1800))
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen_size - window_size) / 2)
	if Global.PlainText.is_empty() || Global.KEY.is_empty():
		return	
	plain_text.text = Global.PlainText
	key_text.text = Global.KEY
	#var decrypted = await decrypt_text(encrypted, password)
	#print("Decrypted: ", decrypted)
	#print("\nMatch: ", message == decrypted)
		
# Hexadecimal to binary conversion
func hex2bin(s: String) -> String:
	var mp = {
		'0': "0000", '1': "0001", '2': "0010", '3': "0011",
		'4': "0100", '5': "0101", '6': "0110", '7': "0111",
		'8': "1000", '9': "1001", 'A': "1010", 'B': "1011",
		'C': "1100", 'D': "1101", 'E': "1110", 'F': "1111"
	}
	var bin_str = ""
	for i in range(s.length()):
		bin_str += mp[s[i].to_upper()]
	return bin_str

# Binary to hexadecimal conversion
func bin2hex(s: String) -> String:
	var mp = {
		"0000": '0', "0001": '1', "0010": '2', "0011": '3',
		"0100": '4', "0101": '5', "0110": '6', "0111": '7',
		"1000": '8', "1001": '9', "1010": 'A', "1011": 'B',
		"1100": 'C', "1101": 'D', "1110": 'E', "1111": 'F'
	}
	var hex_str = ""
	for i in range(0, s.length(), 4):
		var ch = s.substr(i, 4)
		hex_str += mp[ch]
	return hex_str

# Binary to decimal conversion
func bin2dec(binary: String) -> int:
	var decimal = 0
	var length = binary.length()
	for i in range(length):
		if binary[length - 1 - i] == '1':
			decimal += int(pow(2, i))
	return decimal

# Decimal to binary conversion (4-bit padded)
func dec2bin(num: int) -> String:
	var res = ""
	if num == 0:
		res = "0"
	else:
		while num > 0:
			res = str(num % 2) + res
			num = num / 2
	# Pad to multiple of 4
	while res.length() % 4 != 0:
		res = "0" + res
	return res

# Permute function to rearrange the bits
func permute(k: String, arr: Array, n: int) -> String:
	var permutation = ""
	for i in range(n):
		permutation += k[arr[i] - 1]
	return permutation

# Shifting the bits towards left by nth shifts
func shift_left(k: String, nth_shifts: int) -> String:
	var result = k
	for _i in range(nth_shifts):
		result = result.substr(1) + result[0]
	return result

# XOR of two binary strings
func xor_strings(a: String, b: String) -> String:
	var ans = ""
	for i in range(a.length()):
		if a[i] == b[i]:
			ans += "0"
		else:
			ans += "1"
	return ans

# Tables
var initial_perm = [
	58, 50, 42, 34, 26, 18, 10, 2,
	60, 52, 44, 36, 28, 20, 12, 4,
	62, 54, 46, 38, 30, 22, 14, 6,
	64, 56, 48, 40, 32, 24, 16, 8,
	57, 49, 41, 33, 25, 17, 9, 1,
	59, 51, 43, 35, 27, 19, 11, 3,
	61, 53, 45, 37, 29, 21, 13, 5,
	63, 55, 47, 39, 31, 23, 15, 7
]

var exp_d = [
	32, 1, 2, 3, 4, 5, 4, 5,
	6, 7, 8, 9, 8, 9, 10, 11,
	12, 13, 12, 13, 14, 15, 16, 17,
	16, 17, 18, 19, 20, 21, 20, 21,
	22, 23, 24, 25, 24, 25, 26, 27,
	28, 29, 28, 29, 30, 31, 32, 1
]

var per = [
	16, 7, 20, 21,
	29, 12, 28, 17,
	1, 15, 23, 26,
	5, 18, 31, 10,
	2, 8, 24, 14,
	32, 27, 3, 9,
	19, 13, 30, 6,
	22, 11, 4, 25
]

var sbox = [
	[
		[14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
		[0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
		[4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
		[15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]
	],
	[
		[15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
		[3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
		[0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
		[13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]
	],
	[
		[10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
		[13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
		[13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
		[1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12]
	],
	[
		[7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
		[13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
		[10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
		[3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14]
	],
	[
		[2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
		[14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
		[4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
		[11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3]
	],
	[
		[12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
		[10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
		[9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
		[4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13]
	],
	[
		[4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
		[13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
		[1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
		[6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12]
	],
	[
		[13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
		[1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
		[7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
		[2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11]
	]
]

var final_perm = [
	40, 8, 48, 16, 56, 24, 64, 32,
	39, 7, 47, 15, 55, 23, 63, 31,
	38, 6, 46, 14, 54, 22, 62, 30,
	37, 5, 45, 13, 53, 21, 61, 29,
	36, 4, 44, 12, 52, 20, 60, 28,
	35, 3, 43, 11, 51, 19, 59, 27,
	34, 2, 42, 10, 50, 18, 58, 26,
	33, 1, 41, 9, 49, 17, 57, 25
]

var keyp = [
	57, 49, 41, 33, 25, 17, 9,
	1, 58, 50, 42, 34, 26, 18,
	10, 2, 59, 51, 43, 35, 27,
	19, 11, 3, 60, 52, 44, 36,
	63, 55, 47, 39, 31, 23, 15,
	7, 62, 54, 46, 38, 30, 22,
	14, 6, 61, 53, 45, 37, 29,
	21, 13, 5, 28, 20, 12, 4
]

var shift_table = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]

var key_comp = [
	14, 17, 11, 24, 1, 5,
	3, 28, 15, 6, 21, 10,
	23, 19, 12, 4, 26, 8,
	16, 7, 27, 20, 13, 2,
	41, 52, 31, 37, 47, 55,
	30, 40, 51, 45, 33, 48,
	44, 49, 39, 56, 34, 53,
	46, 42, 50, 36, 29, 32
]

func _modulate_sprites(sprite_list : Array , reset : bool , swap = false , swap_reset = false) -> void:
	if swap :
		sprite_list[0].modulate = Color.YELLOW
		sprite_list[1].modulate = Color.CORAL
		await get_tree().create_timer(0.1).timeout
	elif swap_reset : 
		sprite_list[0].modulate = Color.WHITE
		sprite_list[1].modulate = Color.WHITE
	else :
		for sprite in sprite_list :
			if reset :
				sprite.modulate = Color.WHITE
			else :
				sprite.modulate = Color("#b89ffd")
		if !reset :
			await get_tree().create_timer(0.1).timeout
	
		 
# Encrypt/Decrypt function
func des_encrypt(pt: String, rkb: Array, rk: Array, verbose: bool = true) -> String:
	current_block.text = unpad_text(hex_to_text(pt))
	var pt_bin = hex2bin(pt)
	
	# Initial Permutation
	pt_bin = permute(pt_bin, initial_perm, 64)
	if verbose:
		print("After initial permutation: ", bin2hex(pt_bin))
	
	# Splitting
	var left = pt_bin.substr(0, 32)
	var right = pt_bin.substr(32, 32)
	
	
	for i in range(16):
		round_number.text = str(block_number)+"."+str(i+1)
		li.text = bin2hex(left)		
		ri.text = bin2hex(right)
		round_key.text = rk[i]
	
		# Expansion D-box
		await _modulate_sprites([expand_arrow,expantion_permutation],false)
		var right_expanded = permute(right, exp_d, 48)
		_modulate_sprites([expand_arrow,expantion_permutation],true)
		
		
		# XOR with round key
		await _modulate_sprites([xor_with_key_arrow,key_arrow,xor_key,round_key],false)
		var xor_x = xor_strings(right_expanded, rkb[i])
		_modulate_sprites([xor_with_key_arrow,key_arrow,xor_key,round_key],true)
		
		# S-box substitution
		await _modulate_sprites([s_box_arrow,s_box_trapezoid],false)
		var sbox_str = ""
		for j in range(8):
			var row_bits = xor_x[j * 6] + xor_x[j * 6 + 5]
			var col_bits = xor_x[j * 6 + 1] + xor_x[j * 6 + 2] + xor_x[j * 6 + 3] + xor_x[j * 6 + 4]
			var row = bin2dec(row_bits)
			var col = bin2dec(col_bits)
			var val = sbox[j][row][col]
			sbox_str += dec2bin(val)
		_modulate_sprites([s_box_arrow,s_box_trapezoid],true)
		
		
		# Straight D-box permutation
		await _modulate_sprites([p_box_arrow,p_box],false)
		sbox_str = permute(sbox_str, per, 32)
		_modulate_sprites([p_box_arrow,p_box],true)
		
		
		# XOR with left
		await _modulate_sprites([xor_with_left_arrow,to_right_arrow,des_xor2,long_line],false)
		var result = xor_strings(left, sbox_str)
		_modulate_sprites([xor_with_left_arrow,to_right_arrow,des_xor2,long_line],true)
		
		await _modulate_sprites([long_arrow],false)
		_modulate_sprites([long_arrow],true)
		
		left = result
		
		li_1.text = bin2hex(left)		
		ri_1.text = bin2hex(right)		
		# Swap (except last round)
		if i != 15:
			await _modulate_sprites([li_1_s,ri_1_s],false,true)
			var temp = left
			left = right
			right = temp
		
		li_1.text = bin2hex(left)		
		ri_1.text = bin2hex(right)
		await _modulate_sprites([ri_1_s,li_1_s],false,true)
		_modulate_sprites([li_1_s,ri_1_s],false,false,true)
	
		if verbose:
			print("Round ", i + 1, ": ", bin2hex(left), " ", bin2hex(right), " ", rk[i])
	
	# Combination
	var combine = left + right
	
	# Final permutation
	var cipher_text = permute(combine, final_perm, 64)
	block_number+=1
	return cipher_text

# Generate round keys
func generate_keys(key_hex: String) -> Dictionary:
	var key_bin = hex2bin(key_hex)
	
	# Parity bit drop
	key_bin = permute(key_bin, keyp, 56)
	
	# Split
	var left = key_bin.substr(0, 28)
	var right = key_bin.substr(28, 28)
	
	var rkb = []  # Round keys in binary
	var rk = []   # Round keys in hex
	
	for i in range(16):
		# Shift left
		left = shift_left(left, shift_table[i])
		right = shift_left(right, shift_table[i])
		
		# Combine
		var combine_str = left + right
		
		# Compress from 56 to 48 bits
		var r_key = permute(combine_str, key_comp, 48)
		
		rkb.append(r_key)
		rk.append(bin2hex(r_key))
	
	return {"rkb": rkb, "rk": rk}

# Convert a single character to 2-digit hex
func char_to_hex(c: String) -> String:
	var code = c.unicode_at(0)
	var hex_chars = "0123456789ABCDEF"
	var high = code / 16
	var low = code % 16
	return hex_chars[high] + hex_chars[low]

# Convert 2-digit hex to character
func hex_to_char(h: String) -> String:
	var hex_chars = "0123456789ABCDEF"
	var high = hex_chars.find(h[0].to_upper())
	var low = hex_chars.find(h[1].to_upper())
	var code = high * 16 + low
	return String.chr(code)

# Convert text string to hex string
func text_to_hex(text: String) -> String:
	var hex_str = ""
	for i in range(text.length()):
		hex_str += char_to_hex(text[i])
	return hex_str

# Convert hex string to text string
func hex_to_text(hex_str: String) -> String:
	var text = ""
	for i in range(0, hex_str.length(), 2):
		var hex_pair = hex_str.substr(i, 2)
		text += hex_to_char(hex_pair)
	return text

# Pad text to multiple of 8 bytes using PKCS7 padding
func pad_text(text: String) -> String:
	var pad_length = 8 - (text.length() % 8)
	if pad_length == 0:
		pad_length = 8  # Always add padding
	for i in range(pad_length):
		text += String.chr(pad_length)
	return text

# Remove PKCS7 padding
func unpad_text(text: String) -> String:
	if text.length() == 0:
		return text
	var pad_length = text.unicode_at(text.length() - 1)
	if pad_length > 0 and pad_length <= 8:
		return text.substr(0, text.length() - pad_length)
	return text

# Encrypt normal text (handles any string)
func encrypt_text(plaintext: String, key_text: String, verbose: bool = true) -> String:
	cipher_text.text = ""
	# Prepare the key (pad or truncate to 8 characters)
	while key_text.length() < 8:
		key_text += "0"
	key_text = key_text.substr(0, 8)
	var key_hex = text_to_hex(key_text)
	
	# Pad plaintext
	var padded = pad_text(plaintext)
	
	# Generate keys once
	var keys = generate_keys(key_hex)
	
	# Encrypt each 8-byte block
	var cipher_hex = ""
	for i in range(0, padded.length(), 8):
		var block = padded.substr(i, 8)
		var block_hex = text_to_hex(block)
		var encrypted_bin = await des_encrypt(block_hex, keys.rkb, keys.rk, verbose)
		var encrypted_hex = bin2hex(encrypted_bin)
		cipher_hex += encrypted_hex
		cipher_text.text+=hex_to_text(encrypted_hex)
	
	return cipher_hex

# Decrypt back to normal text
func decrypt_text(cipher_hex: String, key_text: String, verbose: bool = true) -> String:
	if cipher_text.text.is_empty():
		return ""
	plain_text.text=""
	# Prepare the key
	while key_text.length() < 8:
		key_text += "0"
	key_text = key_text.substr(0, 8)
	var key_hex = text_to_hex(key_text)
	
	# Generate reversed keys
	var keys = generate_keys(key_hex)
	var rkb_rev = keys.rkb.duplicate()
	var rk_rev = keys.rk.duplicate()
	rkb_rev.reverse()
	rk_rev.reverse()
	
	# Decrypt each 16-hex-character block (= 8 bytes = 64 bits)
	var plaintext = ""
	for i in range(0, cipher_hex.length(), 16):
		var block_hex = cipher_hex.substr(i, 16)
		var decrypted_bin = await des_encrypt(block_hex, rkb_rev, rk_rev, verbose)
		var decrypted_hex = bin2hex(decrypted_bin)
		plaintext += hex_to_text(decrypted_hex)
		plain_text.text+=hex_to_text(decrypted_hex)
	
	# Remove padding
	plaintext = unpad_text(plaintext)
	return plaintext


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
	block_number = 1
	$Encrypt.disabled = true
	encrypted_text = await encrypt_text(Global.PlainText, Global.KEY)
	print("\nEncrypted (hex): ", encrypted_text)
	$Decrypt.disabled = false

func _on_decrypt_pressed() -> void:
	if Global.KEY.is_empty() || encrypted_text.is_empty():
		print("ERROR: PlainText or KEY is empty!")
		return
	block_number = 1
	$Decrypt.disabled = true
	$Encrypt.disabled = true
	var decrypted = await decrypt_text(encrypted_text, Global.KEY)
	print("\nEncrypted (hex): ", decrypted)
	$Decrypt.disabled = false
	$Encrypt.disabled = false
