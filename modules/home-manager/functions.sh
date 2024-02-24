config() {
	# navigate to the config file for a specific app
	cd "$XDG_CONFIG_HOME/$1" || echo "$1 is not a valid config directory."
}

take() {
	mkdir -p "$1" && cd "$1"
}

r() {
	cd "$(git rev-parse --show-toplevel 2>/dev/null)"
}
