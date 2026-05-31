extends CanvasLayer

@onready var text_label = $Panel/RichTextLabel
@onready var start_button = $Panel/Button

var full_text = """
Godina je 2147.

Roboti su okupirali Varaždin.
Vještica i Svećenik vladaju Starim gradom i trgom.

Porazi njihove snage i oslobodi grad.

Sretno, operativče.
"""

func _ready():
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	text_label.text = full_text
	text_label.visible_characters = 0

	start_button.disabled = true

	show_text()

func show_text():
	for i in range(full_text.length() + 1):
		text_label.visible_characters = i
		await get_tree().create_timer(0.03, true, false, true).timeout

	start_button.disabled = false

func _on_button_pressed():
	get_tree().paused = false
	hide()
