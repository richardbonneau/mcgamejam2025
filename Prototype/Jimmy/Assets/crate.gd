extends StaticBody3D
class_name Crate

var times_hit = 0

func hit():
	times_hit+=1
	if times_hit == 1:
		$CrateFull.hide()
		$BrokenCrate.show()
	elif times_hit > 1:
		queue_free()
