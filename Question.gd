extends HBoxContainer

class_name Question

@onready 
var question_text :Label= $Number
@onready 
var answer_field: LineEdit = $LineEdit

var number_re : RegEx = RegEx.new()

func _ready():
	number_re.compile("^\\-?[0-9]+$")
	answer_field.text_changed.connect(on_text_changed)

	pass


func on_text_changed(new_text: String):
	if (new_text.is_empty()):
		question_text.add_theme_color_override("font_color", Color.WHITE)
		print("empty")
	elif(validate_answer(new_text)):
		question_text.add_theme_color_override("font_color", Color.GREEN)
	else:
		question_text.add_theme_color_override("font_color", Color.RED)
	pass

func validate_answer(answer: String) -> bool:
	var number_match : RegExMatch = number_re.search(answer.strip_edges())
	if number_match:
		return true
	return false


func is_valid() -> bool:
	return validate_answer(answer_field.text)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
