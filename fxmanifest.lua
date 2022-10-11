fx_version "bodacious"
game "gta5"

ui_page "index.html"
client_scripts {
	"@vrp/lib/utils.lua",
	"/client*"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"/server*"
}

files {
    "index.html",
	"style.css"
}