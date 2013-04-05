all: components node_modules

components: node_modules component.json
	node_modules/bower/bin/bower install
	touch $@
node_modules: package.json
	npm install
	touch $@

clean:
	rm -Rf components node_modules