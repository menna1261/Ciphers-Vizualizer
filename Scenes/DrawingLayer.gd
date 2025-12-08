extends Node2D

var lines_to_draw = []

func _draw():
	draw_circle(Vector2(100,100), 20, Color.RED)

	print("==========Executing+++++++++")
	for L in lines_to_draw:
		draw_line(L.a, L.b, Color.RED, 2.0)


