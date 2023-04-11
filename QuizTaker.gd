extends PanelContainer

@onready 
var _path : Label = $MarginContainer/VBoxContainer/HBoxContainer2/Path
@onready 
var _file_button : Button = $MarginContainer/VBoxContainer/HBoxContainer2/Browse
@onready
var _name : LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready
var _question_count : SpinBox = $MarginContainer/VBoxContainer/HBoxContainer3/SpinBox
@onready 
var _save_button : Button = $MarginContainer/VBoxContainer/HBoxContainer4/Button
@onready 
var _info_label : RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer4/Info
@onready 
var _questions : VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

@export
var question_node: PackedScene = preload("res://Question.tscn")

var _entire_path : String = ""

var open_file_dialog : FileDialog

func _ready():
	# uneditable until a file is selected
	_question_count.editable = false
	_name.editable = false
	_save_button.disabled = true

	get_viewport().gui_embed_subwindows = false
	open_file_dialog = FileDialog.new()
	open_file_dialog.file_mode= FileDialog.FILE_MODE_SAVE_FILE
	open_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	open_file_dialog.file_selected.connect(on_file_selected)
	_file_button.pressed.connect(on_file_button_pressed)

	add_child.call_deferred(open_file_dialog)

	_save_button.pressed.connect(save_file)



func on_file_button_pressed():
	open_file_dialog.popup_centered_ratio()
	pass

func on_file_selected(path: String):
	var is_valid : = check_if_valid(path)
	if (!is_valid):
		# show error message
		return
	enable_editing()
	_entire_path = path
	_path.text = path.get_file()
	save_file(false)
	log_success("File Loaded: %s" % _path.text)

func enable_editing():
	_question_count.editable = true
	_name.editable = true
	_save_button.disabled = false

func save_file(show_dialog: bool = true):
	var file: = FileAccess.open(_entire_path, FileAccess.WRITE)	
	var data : String = _name.text
	for child in _questions.get_children():
		data += "," + child.answer_field.text.strip_edges() if child.answer_field.text != "" else ", "
	file.store_string(data)
	file.close()
	if (show_dialog):
		log_success("File Saved: %s" % _path.text)

func log_info(message: String):
	_info_label.text = message
	_info_label.get_tree().create_timer(3).timeout.connect(clear_info)

func log_success(message: String):
	_info_label.bbcode_text = "[color=green]" + message + "[/color]"
	_info_label.get_tree().create_timer(3).timeout.connect(clear_info)

func log_error(message: String):
	_info_label.bbcode_text = "[color=red]" + message + "[/color]"
	_info_label.get_tree().create_timer(3).timeout.connect(clear_info)

func clear_info():
	_info_label.text = ""

func check_if_valid(path: String) -> bool:
	if path == _entire_path:
		return false 
	# check if file exists
	# if it doesnt then automatically true
	if (!FileAccess.file_exists(path)):
		# create a new file with the default number of questions
		var num_questions := _question_count.value
		_name.text = "Your Name Here"
		for child in _questions.get_children():
			child.queue_free()
		for i in range(num_questions):
			var question : = question_node.instantiate() as Question
			_questions.add_child(question)
			question.question_text.text = "Question %3d:" % (i+1)
		return true

	#  check if the file is in the valid format
	#  Name, answer1, answer2, answer3, answer4, ..., answerN
	# unasnwered Questions take up exactly one space
	var file := FileAccess.open(path, FileAccess.READ)
	var text:= file.get_as_text()
	file.close()
	if (text == ""):
		# TODO: log Error empty line
		log_error("empty line")
		return false
	var lines := text.split("\n")
	# remove empty lines
	for i in range(lines.size()-1, 0, -1):
		if (lines[i].is_empty()):
			lines.remove_at(i)

	if (lines.size() > 1):
		# TODO: log Error too many lines
		log_error("too many lines")
		return false
	
	var data: = lines[0].split(",")
	if (data.size() < 2):
		print("Incorrect format")
		return false

	for child in _questions.get_children():
		child.queue_free()

	var student_name :=	data[0]
	var num_questions := data.size() - 1
	for i in range(num_questions):
		var question : = question_node.instantiate() as Question
		_questions.add_child(question)
		question.answer_field.text = data[i+1].strip_edges()
		question.question_text.text = "Question %3d:" % (i+1)
		question.on_text_changed(data[i+1].strip_edges())

	_name.text = student_name
	_question_count.value = num_questions
	_path.text = path.get_file()
	
	return true 


