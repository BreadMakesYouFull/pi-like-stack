.PHONY: all
all: # Export all customizer presets as stl
	grep -E '^        "' pi_like_stack.json | grep -Eo '[A-Za-z_0-9]*' | xargs -I% openscad -o stl/%.stl -p pi_like_stack.json -P % pi_like_stack.scad
