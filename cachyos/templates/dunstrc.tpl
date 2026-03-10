[global]
    monitor = 0
    follow = keyboard
    width = 350
    offset = (10, 10)
    origin = top-right
    notification_limit = 3
    timeout = 5
    font = JetBrainsMono Nerd Font 11
    corner_radius = 8
    frame_width = 2
    frame_color = "{{ accent }}"
    separator_color = frame
    padding = 10
    horizontal_padding = 12
    layer = overlay
    mouse_left_click = do_action, close_current
    mouse_right_click = close_current
    mouse_middle_click = close_all

[urgency_low]
    background = "{{ background }}"
    foreground = "{{ foreground }}"
    frame_color = "{{ color8 }}"

[urgency_normal]
    background = "{{ background }}"
    foreground = "{{ foreground }}"
    frame_color = "{{ accent }}"

[urgency_critical]
    background = "{{ background }}"
    foreground = "{{ foreground }}"
    frame_color = "{{ color1 }}"
    timeout = 0
