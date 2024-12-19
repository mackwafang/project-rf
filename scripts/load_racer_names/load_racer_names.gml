function load_racer_names() {
	var filename = "random_first_names.csv";
	if (file_exists(filename)) {
		var fd = file_text_open_read(filename);
		if (fd == -1) {
			print_warning("In load_racer_names(): ");
			return false;
		}
		
		var l = [];
		while (!file_text_eof(fd)) {
			var name = file_text_readln(fd);
			name = string_trim_end(name);
			
			array_push(l, name);
		}
		
		return l;
	}
}