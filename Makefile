.PHONY: all
all: index.html dist/xws.min.js

src/xws_data_%.coffee: src/cards-common.coffee src/xws_validate.coffee src/make_data_%.coffee
	node_modules/.bin/coffee -p $^ | node > $@

dist/xws.js: src/xws_data_pilots.coffee src/xws_data_upgrades.coffee src/xws_validate.coffee
	node_modules/.bin/coffee -cj $@ $^

dist/xws.min.js: dist/xws.js
	node_modules/.bin/uglifyjs $^ --screw-ie8 -o $@ -c

index.html: src/index.jade
	node_modules/.bin/jade --pretty --no-debug --out . $<
