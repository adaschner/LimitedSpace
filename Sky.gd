extends Node2D

var newCloud = load("res://cloud.tscn")
var cloud = []; var speed = -2; var rnd = 0

func _ready():
	var offset = 0
	for c in range(6):
		cloud.append(newCloud.instantiate())
		if rnd < 300: rnd = randf_range(310, 501)
		else: rnd = randf_range(100, 291)
		cloud[c].position = Vector2(720+offset, rnd)
		offset += 300
		add_child(cloud[c])
	set_process(true)

func _process(delta):
	for c in range(6): cloud[c].position = cloud[c].position + Vector2(speed, 0)
	if cloud[5].position.x < 720:
		remove_child(cloud[0])
		cloud[0] = newCloud.instantiate()
		if rnd < 300: rnd = randf_range(310, 501)
		else: rnd = randf_range(100, 291)
		cloud[0].position = Vector2(720 + 300, rnd)
		add_child(cloud[0])
		cloud.push_back(cloud[0]); cloud.pop_front()
