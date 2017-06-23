-- zmienna width podawana z zewnątrz

height_to_width = 0.75
height = height_to_width * width

high_window = height > 200

title = high_window and "High window" or "Not so high window"