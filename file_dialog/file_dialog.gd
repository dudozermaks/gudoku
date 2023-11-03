extends FileDialog

func _ready():
	# On Android one can't access other folder besides user:// without special permissions, as far as I know.
	if OS.get_name() in ["Android", "iOS"]:
		access = FileDialog.ACCESS_USERDATA
