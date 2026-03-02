"$schema" = 'https://starship.rs/config-schema.json'

format = """
$hostname $directory $git_branch$git_status$nodejs$rust$golang$php$fill$time
$cmd_duration$character"""

[cmd_duration]
disabled = true

[fill]
symbol = ' '

[hostname]
ssh_only = false
style = "fg:{{ accent }}"
format = '[\[](fg:{{ color8 }})[@$hostname]($style)[\]](fg:{{ color8 }})'

[directory]
style = "fg:{{ color4 }}"
format = '[\[](fg:{{ color8 }})[$path]($style)[\]](fg:{{ color8 }})'
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "

[git_branch]
symbol = ""
style = "fg:{{ color2 }}"
format = '[on](fg:{{ color8 }}) [$symbol $branch]($style)'

[git_status]
style = "fg:{{ color1 }}"
format = '([$all_status$ahead_behind]($style) )'
stashed = '≡'
staged = '[+$count](fg:{{ color2 }})'
modified = '[~$count](fg:{{ color3 }})'
untracked = '[?$count](fg:{{ color4 }})'
deleted = '[-$count](fg:{{ color1 }})'
ahead = '⇡$count'
behind = '⇣$count'
conflicted = '✖'

[nodejs]
symbol = ""
style = "fg:{{ color3 }}"
format = ' [\[](fg:{{ color8 }})[$symbol $version]($style)[\]](fg:{{ color8 }})'

[rust]
symbol = ""
style = "fg:{{ accent }}"
format = ' [\[](fg:{{ color8 }})[$symbol $version]($style)[\]](fg:{{ color8 }})'

[golang]
symbol = ""
style = "fg:{{ color6 }}"
format = ' [\[](fg:{{ color8 }})[$symbol $version]($style)[\]](fg:{{ color8 }})'

[php]
symbol = ""
style = "fg:{{ color5 }}"
format = ' [\[](fg:{{ color8 }})[$symbol $version]($style)[\]](fg:{{ color8 }})'

[time]
disabled = false
time_format = "%R"
style = "fg:{{ color8 }}"
format = ' $time'

[os]
disabled = false
style = "fg:{{ accent }}"
format = '[$symbol]($style)'

[os.symbols]
Alpine = " "
Amazon = " "
Android = " "
Arch = "󰣇 "
Artix = "󰣇 "
CentOS = " "
Debian = "󰣚 "
EndeavourOS = " "
Fedora = "󰣛 "
Gentoo = "󰣨 "
Linux = "󰌽 "
Macos = "󰀵 "
Manjaro = " "
Mint = "󰣭 "
Pop = " "
Raspbian = "󰐿 "
Redhat = "󱄛 "
RedHatEnterprise = "󱄛 "
SUSE = " "
Ubuntu = "󰕈 "
Windows = "󰍲 "
